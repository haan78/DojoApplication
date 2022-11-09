<?php 

namespace MongoTools {

use stdClass;

class Cast {
        public static bool $LOCAL_TIME_ZONE = false;
        public static string $DATE_TIME_FORMAT = "Y-m-d\TH:i:s.000\Z"; //c
        public static function toISODate(string $iso,bool $justdate=true) {
            if ($justdate) {
                //die($iso."  ".substr($iso,0,10));
                $t = strtotime(substr($iso,0,10)."T00:00:00.000Z")*1000;
                return new  \MongoDB\BSON\UTCDateTime($t);
            } else {
                $t = ( strtotime($iso))*1000;
                return new  \MongoDB\BSON\UTCDateTime($t);
            }

            
        }
        public static function toUTCDateTime(?\DateTime $dt = null)  : \MongoDB\BSON\UTCDateTime {
            if ( is_null($dt) ) {
                return new \MongoDB\BSON\UTCDateTime();
            } else {
                return new \MongoDB\BSON\UTCDateTime($dt);
            }            
        }

        public static function toDateTime(\MongoDB\BSON\UTCDateTime $mdt) : \DateTime {
            //echo "[".(string)$mdt."] ";
            $dt = $mdt->toDateTime();            
            if ( self::$LOCAL_TIME_ZONE) {
                //echo date_default_timezone_get();
                $dt->setTimeZone(new \DateTimeZone( date_default_timezone_get() ));                
            } else {
                $dt->setTimeZone(new \DateTimeZone( "UTC" ));
            }            
            
            return $dt;
        }

        private static function convert($v) {
            if ( $v instanceof  \MongoDB\Model\BSONDocument) {
                return self::toObject($v);
            } elseif ( $v instanceof \MongoDB\BSON\ObjectId ) {
                return $v->__toString();
            } elseif ( $v instanceof \MongoDB\BSON\UTCDateTime ) {
                return self::toDateTime($v)->format(self::$DATE_TIME_FORMAT);
            } elseif ( $v instanceof \MongoDB\Model\BSONArray ) {
                return self::transerArray($v);
            } else {
                return $v;
            }
        }



        public static function toObject(\MongoDB\Model\BSONDocument $doc) : object {
            $row = (array)$doc;
            foreach( $row as $k => $v ) {                
                $row[$k] = self::convert($v);
            }            
            return (object)$row;
        }

        public static function toTable(\MongoDB\Driver\Cursor $cursor, ?callable $fnc = null) : array {
            $list = [];
            $it = new \IteratorIterator($cursor);
            $it->rewind();
            while ($doc = $it->current()) {
                $row = self::convert($doc);
                if ( is_null($fnc) ) {
                    array_push($list, $row);                    
                } else {
                    array_push($list, $fnc($row));
                }               
                $it->next();
            }
            return $list;
        }

        public static function toStdObject(\MongoDB\Driver\Cursor $cursor, ?callable $fnc = null) : stdClass {
            $objarr = [];
            $it = new \IteratorIterator($cursor);
            $it->rewind();
            while ($doc = $it->current()) {
                $row = self::convert($doc);
                //var_dump($row);
                if ( property_exists($row,"_id") ) {
                    $_id = $row->_id;
                    if ( is_null($fnc) ) {
                        $objarr[$_id] = $row;
                    } else {
                        $objarr[$_id] = $fnc($row);
                    }
                    unset($objarr[$_id]->_id);
                }             
                $it->next();
            }
            return (object)$objarr;
        }

        public static function transerArray(\MongoDB\Model\BSONArray $arr,?callable $fnc = null) {
            $list = [];
            for($i=0; $i<count($arr); $i++ ) {
                $doc = $arr[$i];
                if ( !is_null($fnc) ) {
                    array_push($list, $fnc($doc));
                } else {
                    array_push($list, self::convert($doc));
                }
            }
            return $list;
        }

		public static function toRegex(string $regex,string $flags = "") : \MongoDB\BSON\Regex  {
            return new \MongoDB\BSON\Regex($regex,$flags);
        }
		
        public static function toObjectId(string $_id) : \MongoDB\BSON\ObjectId {
            return new \MongoDB\BSON\ObjectId( trim($_id) );
        }

        public static function toClient(string $connectionString) : \MongoDB\Client {
            return new \MongoDB\Client($connectionString);
        }
    }

    class Get {
        public static function matchedCount(\MongoDB\UpdateResult $result) : int {
            return $result->getMatchedCount();
        }
    }

    class Collection {
        public static function add(\MongoDB\Database $db ,string $name, $data,bool $upsert = true) : string {
            $d = null;
            $_id = null;
            if ( $data instanceof stdClass ) {
                $d = (array)$data;
            } else {
                $d = $data;
            }            
            if (is_array($d)) {
                foreach($d as $k => $v) {
                    if ( is_string($v) && preg_match('/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/',$v) ) {
                        $d[$k] = new  \MongoDB\BSON\UTCDateTime(strtotime($v)*1000);
                    }                    
                }
            }

            if ( array_key_exists("_id",$d)  ) {
                if ( is_string( $d["_id"] ) && !empty($d["_id"]) ) {
                    $_id = Cast::toObjectId($d["_id"]);
                }
                
                unset($d["_id"]);
            }

            if (is_null($_id)) {

                $res = $db->selectCollection($name)->insertOne($d);
                return (string)$res->getInsertedId();
            } else {
                $res = $db->selectCollection($name)->updateOne([ '_id'=>$_id ],[ '$set'=> $d],[ "upsert" => $upsert ]);
                return (string)$_id;
            }            
        }

        public static function remove(\MongoDB\Database $db ,string $name, string $_id) {
            return $db->selectCollection($name)->deleteOne( [ "_id" => Cast::toObjectId($_id) ] )->isAcknowledged();
        }
    }
}