<?php

namespace MySqlTool {

    require_once __DIR__ . "/MySqlToolExeption.php";

    use MySqlTool\MySqlToolDatabaseException;
    use MySqlTool\MySqlToolMethodException;

    class MySqlToolCall {

        private $params;
        private $link;
        public $lastSQL;
        private $procedure;
        private $parser = [];
        private $result = null;
        public $setEmptyStringsToNull = true;
        public $autoClose = true;

        private $outs = null;
        private $qList = null;

        public function __construct(\mysqli $link) {
            $this->link = $link;
            $this->params = array();
        }
        
        public function procedure($name) {
            $this->procedure = $name;
            return $this;
        }
        
        public function result($key = "all") {
            if ($key == "all") {
                return [
                    "outs" =>$this->outs,
                    "queries" =>$this->qList
                ];
            } elseif ($key == "outs") {
                return $this->outs;
            } elseif ("queries") {
                return $this->qList;
            } elseif (is_string($key)) {
                if (is_array($this->outs) && (array_key_exists($key,$this->outs)) ) {
                    return $this->outs[$key];
                } else {
                    throw new MySqlToolMethodException("There is no such kind an out like '$key'",1003,__METHOD__);
                }
            } elseif ( is_int($key) ) {
                if (is_array($this->qList) && (isset($this->qList[$key])) ) {
                    return $this->qList[$key];
                } else {
                    throw new MySqlToolMethodException("There is no such kind a query like '$key'",1002,__METHOD__);
                }
            } else {
                throw new MySqlToolMethodException("Result parameter must be a string for outs or integer for queries",1001,__METHOD__);
            }
        }
        
        private function cast($value,$type) {
            if ($type=="json") {
                return json_decode($value, true);
            } elseif ($type == "time") {
                return strtotime($value);
            } elseif ($type == "bool") {
                return ( trim($value) == "1" ? true : false);
            } elseif ($type == "int") {
                return intval($value);
            } elseif ($type=="float") {
                return floatval($value);
            } else {
                return $value;
            }
        }

        public function get($path,$type="string") {            
            $arr = explode(">", str_replace(["[",".","]"], [">",">",""], $path) );
            //var_dump($arr);
            $d = $this->result;
            for ($i = 0; $i < count($arr); $i++) {
                $oname = trim($arr[$i]);
                if (isset($d[$oname])) {
                    $d = $d[$oname];
                } else {                    
                    return null;
                }
            }
            return $this->cast($d, $type);            
        }

        public function setParser($field, callable $fnc) {
            $this->parser[$field] = $fnc;
        }

        public function in($value, $quotes = true) {
            $prm = array(
                "type" => "IN",
                "name" => false,
                "value" => $value,
                "quotes" => $quotes === false ? false : true
            );
            array_push($this->params, $prm);
            return $this;
        }

        public function out($name, $value = null, $quotes = true) {
            $prm = array(
                "type" => "OUT",
                "name" => $name,
                "value" => $value,
                "quotes" => $quotes === false ? false : true
            );
            array_push($this->params, $prm);
            return $this;
        }

        private function valToStr($val, $quotes) {
            if (is_null($val)) {
                return "NULL";
            } elseif ((is_object($val)) || (is_array($val))) {
                return "'" . json_encode($val, JSON_UNESCAPED_UNICODE) . "'";
            } elseif ($val === false) {
                return "0";
            } elseif ($val === true) {
                return "1";
            } elseif (($val === "") && ($this->setEmptyStringsToNull )) {
                return "NULL";
            } else {
                if ($quotes) {
                    //echo "**$val**";
                    return "'" . mysqli_escape_string($this->link, $val) . "'";
                } else {
                    return $val;
                }
            }
        }

        private function generateSQL($procedure, &$isThereOut = false) {
            $set = "";
            $prms = "";
            $select = "";

            for ($i = 0; $i < count($this->params); $i++) {
                if ($i > 0) {
                    $prms .= ",";
                }
                if ($this->params[$i]["type"] === "IN") {
                    $prms .= $this->valToStr($this->params[$i]["value"], $this->params[$i]["quotes"]);
                } elseif ($this->params[$i]["type"] === "OUT") {
                    if (strlen($set) > 0) {
                        $set .= ",";
                        $select .= ",";
                    }
                    $set .= "@" . $this->params[$i]["name"] . "=" . $this->valToStr($this->params[$i]["value"], $this->params[$i]["quotes"]);
                    $select .= "@" . $this->params[$i]["name"] . " AS " . $this->params[$i]["name"];
                    $prms .= "@" . $this->params[$i]["name"];
                }
            }

            $SQL = "CALL " . $procedure . "( " . $prms . " )";
            if (strlen($set) > 0) {
                $isThereOut = true;
                $SQL = "SET " . $set . ";\n"
                        . $SQL . ";\n"
                        . "SELECT " . $select . ";";
            } else {
                $isThereOut = false;
            }

            $this->lastSQL = $SQL;
            return $SQL;
        }

        public function mysqli_call($procedure, &$error_code, &$error_text, &$isThereOut) {

            $queries = [];

            if (!mysqli_multi_query($this->link, $this->generateSQL($procedure, $isThereOut))) {                
                $error_code = mysqli_errno($this->link);
                $error_text = mysqli_error($this->link);
                return false;
            }

            while (true == true) {
                $r = mysqli_store_result($this->link);

                if ($r instanceof \mysqli_result) {
                    /*$fields = \mysqli_fetch_fields($r);
                    print_r($fields);*/
                    array_push($queries, $r);                    
                } elseif (mysqli_errno($this->link) != 0) {
                    $error_code = mysqli_errno($this->link);
                    $error_text = mysqli_error($this->link);
                    return false;
                } else {
                    //?
                }
                if (mysqli_more_results($this->link)) {
                    mysqli_next_result($this->link);
                } else {
                    break;
                }
            }
            return $queries;
        }

        private function mysqli_exec($sql, $type, &$error_code, &$error_text) {            
            $s = "";
            $j = 0;
            for ($i = 0; $i < strlen($sql); $i++) {
                if ($sql[$i] == "?") {
                    if (isset($this->params[$j]))
                            $s .= $this->valToStr($this->params[$j]["value"], $this->params[$j]["quotes"]);
                    else $s .= "NULL";
                    $j++;
                } else {
                    $s .= $sql[$i];
                }
            }
            $this->lastSQL = $s;
            //echo $this->lastSQL;

            $query = mysqli_query($this->link, $this->lastSQL);           
            if ($query instanceof \mysqli_result) {                
                if (mysqli_num_rows($query) < 0) {
                    return null;
                }
                mysqli_data_seek($query, 0);                
                if ($type == "array") {
                    $arr = array();
                    while ($row = mysqli_fetch_assoc($query)) {
                        array_push($arr, $row);
                    }
                    return $arr;
                } else {
                    $row = mysqli_fetch_array($query);
                    if ($type == "orginal") {
                        return $row[0];
                    } elseif ($type == "int") {
                        return intval($row[0]);
                    } elseif ($type == "float") {
                        return floatval($row[0]);
                    } else {
                        return null;
                    }
                }
            } elseif ($query == true) {
                return mysqli_affected_rows($this->link);
            } else {

                $error_code = mysqli_errno($this->link);
                $error_text = mysqli_error($this->link);
                return false;
            }
        }

        public function exec($sql, $type = "orginal") {
            $error_code = $error_text = null;

            $r = $this->mysqli_exec($sql, $type, $error_code, $error_text);

            $this->params = array();
            if ($this->autoClose) mysqli_close($this->link);

            if ((is_null($error_code)) && (is_null($error_text))) {
                return $r;
            } else {
                throw new MySqlToolDatabaseException($error_text, $error_code, $this->lastSQL);
            }
        }

        public function call() {
            $error_code = $error_text = null;
            $isThereOut = false;
            $queries = $this->mysqli_call($this->procedure, $error_code, $error_text, $isThereOut);


            if ($queries === false) {
                if ($this->autoClose) mysqli_close($this->link);
                throw new MySqlToolDatabaseException($error_text, $error_code, $this->lastSQL);
            }

            $this->params = array();
            $qList = [];
            $outs = [];
            for ($i = 0; $i < count($queries); $i++) {
                $list = [];
                mysqli_data_seek($queries[$i], 0);
                if (($i == count($queries) - 1) && ($isThereOut)) {
                    $outs = mysqli_fetch_assoc($queries[$i]);
                } else {
                    while ($row = mysqli_fetch_assoc($queries[$i])) {
                        $row2 = [];
                        foreach( $row as $field => $value ) {
                            if ( isset($this->parser[$field]) ) {
                                $row2[$field] = $this->parser[$field]($value);
                            } else {
                                $row2[$field] = $value;
                            }
                        }
                        array_push($list, $row2);
                    }
                    array_push($qList, $list);
                }
                mysqli_free_result($queries[$i]);
            }
            
            $this->outs = $outs;
            $this->qList = $qList;

            if ($this->autoClose) mysqli_close($this->link);
            return $this;
        }

    }

}