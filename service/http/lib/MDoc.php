<?php

namespace MDoc {

    class Cursor {

        public static string $DEFAULT_TIMEZONE = "";
        public static string $DEFAUTL_DATETIEM_FORMAT = \DateTime::ISO8601;

        private \MongoDB\Driver\Cursor $cursor;
        private string $timezone;
        public function __construct(\MongoDB\Driver\Cursor $cursor) {
            $this->self::$DEFAULT_TIMEZONE ?? date_default_timezone_get();
            $this->cursor = $cursor;
        }

        public static function cast($doc,string $timezone = "UTC") {
            if ( $doc instanceof  \MongoDB\Model\BSONDocument || $doc instanceof  \MongoDB\Model\BSONArray) {
                $arr = [];
                foreach($doc as $key => $value) {
                    $arr[$key] = self::cast($value,$timezone);
                }
                return $arr;                
            } elseif ( $doc instanceof \MongoDB\BSON\ObjectId ) {
                return (string)$doc;
            } elseif ( $doc instanceof \MongoDB\BSON\UTCDateTime ) {
                $dt = $doc->toDateTime();
                $dt->setTimezone(new \DateTimeZone( $timezone ));
                return $dt->format(self::$DEFAUTL_DATETIEM_FORMAT);
            } else {
                return $doc;
            }
        }

        public function asArray(?callable $fnc) : array {
            $arr = [];
            $it = new \IteratorIterator($this->cursor);
            $it->rewind();
            while ($doc = $it->current()) {
                $obj = self::cast($doc,$this->timezone);
                array_push($arr,(is_null($fnc) ? $fnc($obj) : $obj ));
                $it->next();
            }
            return $arr;
        }
    }

    class ValidationHandler {
        private $value;
        private array $path;

        public function __construct($value, array $path) {
            $this->value = $value;
            $this->path = $path;
        }
        public final function abort(string $message = ""): void {
            $msg = "" . (count($this->path) > 0 ? "/" : "") . implode("/", $this->path) . "  $message";
            throw new \Exception($msg);
        }

        public function getValue() {
            return $this->value;
        }

        public function getPath(): array {
            return $this->path;
        }
    }

    class Document {
        private function get($data, $key, &$value): bool {
            if (is_array($data) && array_key_exists($key, $data)) {
                $value = $data[$key];
            } elseif (is_object($data) && property_exists($data, $key)) {
                $value = get_object_vars($data)[$key];
            } else {
                return false;
            }
            return true;
        }

        private function isISO8601Date(string $date, string $format = 'Y-m-d') {            
            $d = \DateTime::createFromFormat($format, $date);
            // The Y ( 4 digits year ) returns TRUE for any integer with any number of digits so changing the comparison from == to === fixes the issue.
            if ($d && $d->format($format) === $date) {
                $t = strtotime($date . "T00:00:00.000Z") * 1000;
                return new \MongoDB\BSON\UTCDateTime($t);
            } else {
                return null;
            }
        }

        private function isISO8601DateTime(string $datetime, string $format = \DateTime::ISO8601): ?\MongoDB\BSON\UTCDateTime {
            $dt = \DateTime::createFromFormat($format, $datetime);
            // The Y ( 4 digits year ) returns TRUE for any integer with any number of digits so changing the comparison from == to === fixes the issue.
            if ($dt && $dt->format($format) === $datetime) {
                return new \MongoDB\BSON\UTCDateTime($dt);
            } else {
                return null;
            }
        }

        protected function is_list($value): bool {
            return is_array($value) && ($value === [] || (array_keys($value) === range(0, count($value) - 1)));
        }

        protected function is_stack($value): bool {
            return (is_object($value) || (is_array($value) && (!empty($value) && (array_keys($value) !== range(0, count($value) - 1)))));
        }

        private function callValidator(?callable $validator, string $test, $value, array $path, string &$error): bool {
            if (!is_null($validator) && !empty($test)) {
                $vh = new ValidationHandler($value, $path);
                try {
                    call_user_func_array($validator, [$test, $vh]);
                } catch (\Exception $ex) {
                    $error = $ex->getMessage();
                    return false;
                }
            }
            return true;
        }

        private function getPrimitive($value, string $type, &$castValue): bool {
            if ($type == "any") {
                $castValue = $value;
                return true;
            } elseif ($type == "date" && is_string($value)) {
                $castValue = $this->isISO8601Date($value);
                return !is_null($castValue);
            } elseif ($type == "datetime" && is_string($value)) {
                $castValue = $this->isISO8601DateTime($value);
                return !is_null($castValue);
            } elseif ($type == "bool" && is_bool($value)) {
                $castValue = $value;
                return true;
            } elseif ($type == "id") {
                if (is_string($value) && $value != "") {
                    $castValue = new \MongoDB\BSON\ObjectId($value);
                    return true;
                } elseif (!$value) {
                    $castValue = new \MongoDB\BSON\ObjectId();
                    return true;
                }
            } elseif ($type == "int" && is_integer($value)) {
                $castValue = $value;
                return true;
            } else if ($type == "num" && (is_numeric($value))) {
                $castValue = $value;
                return true;
            } elseif (($type == "str" || $type == "string") && is_string($value)) {
                $castValue = $value;
                return true;
            }
            $castValue = null;
            return false;
        }

        public function toMongo($data, array $structure, ?callable $validator): array {
            $error = "";
            $out = [];
            if ($this->validate($data, $structure, $validator, [], $out, $error)) {
                if (!isset($out["_id"])) {
                    $out["_id"] = new \MongoDB\BSON\ObjectId();
                }
                return $out;
            } else {
                throw new \Exception($error);
            }
        }

        private function validate($data, array $structure, ?callable $validator, array $path, array &$out = [], string &$error = ""): bool {
            if ($this->is_stack($data)) {
                foreach ($structure as $key => $def) {
                    $naulable = false;
                    $type = "";
                    if (!isset($def["type"])) {
                        $naulable = true;
                        $type = "any";
                    } elseif ($def["type"][0] == "?") {
                        $type = substr($def["type"], 1);
                        $naulable = true;
                    } else {
                        $type = $def["type"];
                    }
                    $test = isset($def["test"]) ? $def["test"] : "";
                    $of = isset($def["of"]) ? $def["of"] : null;
                    if ($this->get($data, $key, $value)) {
                        if (is_null($value)) {
                            if ($naulable) {
                                $out[$key] = null;
                            } else {
                                $error = "/$key can not be null";
                                return false;
                            }
                        } elseif ($type == "object" || $type == "array") {
                            if ($type == "object" && $this->is_stack($value)) {
                                $sub = [];
                                $err = "";
                                if ($this->validate($value, $of, $validator, array_merge($path, [$key]), $sub, $err)) {
                                    if (!$this->callValidator($validator, $test, $sub, $path, $error)) {
                                        $error = "/$key$error";
                                        return false;
                                    }
                                    $out[$key] = $sub;
                                } else {
                                    $error = "/$key$err";
                                    return false;
                                }
                            } else if ($type == "array" && $this->is_list($value)) {
                                $out[$key] = [];
                                foreach ($value as $ind => $item) {
                                    if (is_array($of)) {
                                        $sub = [];
                                        $err = "";
                                        if ($this->validate($item, $of, $validator, array_merge($path, [$key, $ind]), $sub, $err)) {
                                            if (!$this->callValidator($validator, $test, $sub, $path, $error)) {
                                                $error = "/$key$error";
                                                return false;
                                            }
                                            $out[$key][$ind] = $sub;
                                        } else {
                                            $error = "/$key[$ind]$err";
                                            return false;
                                        }
                                    } else {
                                        if ($this->getPrimitive($item, $of, $castitem)) {
                                            if (!$this->callValidator($validator, $test, $castitem, $path, $error)) {
                                                $error = "/$key[$ind]$error";
                                                return false;
                                            }
                                            $out[$key][$ind] = $castitem;
                                        } else {
                                            $error = "/$key[$ind] type does not match to $of";
                                            return false;
                                        }
                                    }
                                }
                            } else {
                                $error = "/$key must be a key array or object";
                                return false;
                            }
                        } elseif ($this->getPrimitive($value, $type, $castValue)) {
                            if (!$this->callValidator($validator, $test, $castValue, $path, $error)) {
                                $error = "/$key$error";
                                return false;
                            }
                            $out[$key] = $castValue;
                        } else {
                            $error = "/$key type does not match to $type";
                            return false;
                        }
                    } else {
                        $error = "/$key not exist";
                        return false;
                    }
                }
            } else {
                $error = "Data must be key array or object";
                return false;
            }
            return true;
        }
    }

    class Schema {
        protected static final function toMongo($data, array $structure, ?callable $validator = null): array {
            return (new Document())->toMongo($data, $structure, $validator);
        }
    }

    class CodeBuilder {

        private static function parse(\SimpleXMLElement $xml): array {
            $result = [];
            $count = $xml->count();
            $type = (string)$xml->attributes()["type"];
            $test = (string)$xml->attributes()["test"];
            if ($count > 0) {
                $result["of"] = [];
                foreach ($xml as $name => $elm) {
                    $result["of"][$name] = self::parse($elm);
                }
            } else {
                $of = (string)$xml->attributes()["of"];
                if ($of) {
                    $result["of"] = $of;
                }
            }
            if ($test) {
                $result["test"] = $test;
            }
            if ($type) {
                $result["type"] = $type;
            }
            return $result;
        }

        private static function var_export_min(array $var) {
            $toImplode = array();
            foreach ($var as $key => $value) {
                $toImplode[] = var_export($key, true) . '=>' . (is_array($value) ? self::var_export_min($value) : var_export($value, true));
            }
            $code = 'array(' . implode(',', $toImplode) . ')';
            return $code;
        }

        public static function load(string $xmlfile): string {
            
            $root = simplexml_load_file($xmlfile, "\SimpleXMLElement", LIBXML_NOCDATA);
            $namespace = (string)$root->attributes()["namespace"];
            if ($root instanceof \SimpleXMLElement) {
                $classname = (string)$root->getName();
                $strmethods = "";
                foreach ($root as $doc) {
                    if ($doc instanceof \SimpleXMLElement) {
                        $docname = (string)$doc->getName();
                        $docroot = self::parse($doc);
                        if (isset($docroot["of"]) && is_array($docroot["of"])) {
                            //$strarr = var_export($docroot["of"],true);
                            $strarr =  self::var_export_min($docroot["of"]);
                            $strmethods .=
                            "    public static final function $docname(\$data, ?callable \$validator = null): array {\n".
                            "        \$structure = $strarr;\n".
                            "        return self::toMongo(\$data,\$structure,\$validator);\n".
                            "    }\n\n";                            
                        } else {
                            throw new \Exception("Document $docname must have at least one child element");
                        }
                    } else {
                        throw new \Exception("Unsupported document type " . (string)$doc);
                    }
                }
                $strclass =
                "class $classname extends \MDoc\Schema {\n".
                "$strmethods".
                "}";                
                if ($namespace) {
                    $content = "<?php\n\nnamespace $namespace {\n$strclass\n}";                    
                } else {
                    $content = "<?php\n$strclass\n";
                }
                
            } else {
                throw new \Exception("File read error $xmlfile");
            }
            return $content;
        }
    }
}
