<?php

namespace MongoTools {

    use Exception;
    use \SessionHandlerInterface;
    use \MongoDB\Collection;
    use \MongoDB\BSON\UTCDateTime;
    use \MongoDB\BSON\ObjectId;

    class MongoSession implements SessionHandlerInterface {
        private Collection $coll;
        private int $life = 0;

        private static bool $initialized = false;
        public static string $lastErrorMessage = "";

        private static function getClientInfo(&$agent,&$address) : void {
            $agent = "";
            $address = "";
            if ( isset($_SERVER) ) {
                if ( isset($_SERVER['HTTP_USER_AGENT']) ) {
                    $agent = trim($_SERVER['HTTP_USER_AGENT']);
                }
                if (isset($_SERVER["HTTP_X_FORWARDED_FOR"])) {
                    $address = trim(explode(",",$_SERVER["HTTP_X_FORWARDED_FOR"])[0]);
                } elseif ( isset($_SERVER["HTTP_X_REAL_IP"]) ) {
                    $address = trim($_SERVER["HTTP_X_REAL_IP"]);
                } elseif ( isset($_SERVER["REMOTE_ADDR"]) ) {
                    $address = trim($_SERVER["REMOTE_ADDR"]);
                }
            }
        }

        public static function init(Collection $coll, int $lifeTime = 1 * 60) : void {
            if ( self::$initialized ) {
                throw new Exception("This method has already been performed");
            } elseif ( isset($_SESSION) ) {
                throw new Exception("Session has already started");
            }
            $name = $coll->getCollectionName();
            $coll->createIndexes([
                [ "key"=>[ "time"=>1], "name"=>$name."_index_1" ],
                [ "key"=>[ "expires"=>1, "active"=>1 ], "name"=>$name."_index_2" ],
                [ "key"=>[ "user_id"=>1, "active"=>1 ], "name"=>$name."_index_3" ]
            ]);
            session_set_save_handler(new MongoSession($coll,$lifeTime*1000), false);
            ini_set('session.gc_maxlifetime', $lifeTime);
            session_set_cookie_params($lifeTime);
            session_start();
            self::$initialized = true;
        }

        public static function clinetValidate(Collection $coll,&$reason) : bool {
            if ( !self::$initialized ) {
                throw new Exception(__CLASS__."::init function must be called first" );
            }
            self::getClientInfo($agent,$address);
            $session_id = session_id();

            $result = $coll->findOne([ "_id"=> new ObjectId($session_id), "active"=>true ],[ "sort" => ["time"=>-1] ]);
            if ( !is_null($result) ) {
                if ( $result["address"] == $address ) {
                    if ( $result["agent"] == $agent ) {
                        $reason = "OK";
                        return true;
                    } else {
                        $reason = "WRONG AGENT";
                    }
                } else {
                    $reason = "WRONG ADDRESS";
                }
            } else {
                $reason = "NO RECORD";
            }
            return false;
        }

        public static function userCount(Collection $coll,string $user_id) : int {
            if ( !self::$initialized ) {
                throw new Exception(__CLASS__."::init function must be called first" );
            }
            return $coll->countDocuments(["user_id"=>$user_id, "active"=>true]);
        }

        public static function setUserID(Collection $coll,string $user_id) : void {
            if ( !self::$initialized ) {
                throw new Exception(__CLASS__."::init function must be called first" );
            }
            $id = session_id();
            if ( $id === false ) {
                throw new Exception( "session_id not found" );
            }
            
            $result = $coll->updateOne([
                "_id"=> new ObjectId($id),
                "active"=>true
            ],[
                '$set'=>[
                    "user_id" => $user_id
                ]
            ]);
            if ( $result->getMatchedCount() == 0 ) {
                throw new Exception( "Session ID not found. It may have already been deactivated." );
            }
        } 

        public function __construct(Collection $coll,int $life)
        {
            $this->coll = $coll;
            $this->life = $life;
        }

        private function inactivate(string $id = "") : int {
            $t = new UTCDateTime(); // '$$NOW'
            $aggr = [
                [ '$set' => [
                        "duration"=>[ '$subtract'=>[ $t,'$last_modified' ] ],
                        "active" => false,
                        "end" => $t
                    ]
                ]
            ];
            if (!empty($id)) {
                $result = $this->coll->updateOne([
                    '_id' => new ObjectId($id),
                    "active"=>true
                ],$aggr);
                return $result->getMatchedCount();
            } else {
                $result = $this->coll->updateMany(
                    ['$expr' => [ '$lt'=> [ [ '$add'=> ['$last_modified','$life'] ], $t ] ], "active"=>true ],$aggr
                );
                return $result->getMatchedCount();
            }
        }

        public function open($savePath, $sessionName) : bool {

            $this->gc( intval(ini_get('session.gc_maxlifetime')) );

            return true;
        }

        public function close() : bool {
            return true;
        }

        public function read(string $id) : string {
            $_id = new ObjectId($id);
            $result = $this->coll->findOne([ "_id"=> $_id, "active"=>true ]);
            if ( !is_null($result) && !empty($result) && $result["raw"] ) {
                return (string)$result["raw"];
            } else {
                return "";
            }
        }  

        public function write($id, $data) : bool {
            if ( !empty($data) ) {
                $fields = [
                    "raw" => $data,
                    "data"=> isset($_SESSION) ? $_SESSION : null,
                    "last_modified" =>new UTCDateTime(),
                    "active" => true
                ];         
                try {
                    $result = $this->coll->updateOne(["_id"=> new ObjectId($id)], [ '$set'=>$fields ]);
                    if ( $result->getMatchedCount() > 0 ) {
                        return true;
                    } else {
                        self::$lastErrorMessage = __FUNCTION__."::"." _id ($id) not found in collection";
                        return false;
                    }
                } catch(Exception $ex) {
                    self::$lastErrorMessage = __FUNCTION__.":: ".$ex->getMessage();
                    return false;
                }            
            } else {
                return $this->destroy($id);
            }
            
        }

        public function destroy($id) : bool {
            try {
                $this->inactivate($id);
            } catch(Exception $ex) {
                self::$lastErrorMessage = __FUNCTION__.":: ".$ex->getMessage();
                return false;
            }            
            return true;
        }

        public function create_sid() : string {
            self::getClientInfo($agent,$address);
            $insert = [
                "user_id"=>null,
                "data" => [],
                "raw" => "",
                "life" => $this->life,
                "begin" => new UTCDateTime(),
                "last_modified" => null,
                "end" => null,
                "duration" => 0,
                "agent" => $agent,
                "address" => $address,
                "active" => true
            ];
            $result = $this->coll->insertOne($insert);
            return (string)$result->getInsertedId();
        }

        public function validate_sid(string $id): bool {
            $c = $this->coll->countDocuments([ "_id"=>new ObjectId($id) ]);
            return $c > 0;
        }

        public function gc($maxlifetime) : int {
            $c = 0;
            try {
                $c = $this->inactivate();              
            } catch(Exception $ex) {
                self::$lastErrorMessage = $ex->getMessage();
                return 0;
            }
            return $c;
        }
    }
}
