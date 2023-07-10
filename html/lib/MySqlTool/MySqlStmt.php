<?php

namespace MySqlTool {

    use DateTime;
    use mysqli;
    use mysqli_result;
    use mysqli_stmt;
    use mysqli_sql_exception;

    class MySqlStmt {

        public static bool $closeConnection = FALSE;
        
        public static function resultToArray(mysqli_result $result) : array {
            $arr = array();
            while ($row = $result->fetch_object()) {
                array_push($arr,$row);
            }
            $result->free();
            return $arr;
        }

        public static function stmtResult(mysqli_stmt $stmt) {
            $result = null;
            if ($stmt->execute()) {
                $result = $stmt->get_result();
                if ( $result ) {
                    $result = (array)self::resultToArray($result);
                } else {
                    $result = (int)mysqli_stmt_affected_rows($stmt);
                }
            } else {
                throw new \Exception(mysqli_stmt_error($stmt)." / ".mysqli_stmt_errno($stmt));
            }            
            return $result;
        }

        public static function sqlToStmt(mysqli $conn,string $sql,array $params = []) : mysqli_stmt {
            $stmt = $conn->prepare($sql);
            
            if ($stmt) {
                $types = "";
                $plist = [];
                foreach($params as $key => $value) {
                    if (is_null($value)) {
                        $types.= "s";
                        array_push($plist,$value);
                    } elseif (is_double($value) || is_float($value)) {
                        $types.= "d";
                        array_push($plist,$value);
                    } elseif (is_int($value)) {
                        $types.= "i";
                        array_push($plist,$value);                                            
                    } elseif (is_string($value)) {
                        $types.= "s";
                        array_push($plist,empty(trim($value)) ? null : $value);
                    } elseif ($value instanceof DateTime) {
                        $types.= "s";
                        array_push($plist,$value->format("Y-m-d H:i:s"));
                    } elseif (is_array($value) | is_object($value)) {
                        $types.= "s";
                        array_push($plist,json_encode($value));
                    } else {
                        $types.= "s";
                        array_push($plist,$value);
                    }
                }
                if ($types) {
                    $stmt->bind_param($types,...$plist);
                }                
                return $stmt;
            } else {
                throw new \Exception(mysqli_error($conn)." / ".mysqli_errno($conn));
            }
        }

        public static function query(mysqli $conn, string $sql, array $params = []) {
            $arr = [];
            $stmt = null;
            try {
                $stmt = self::sqlToStmt($conn, $sql, $params);
                $arr = self::stmtResult($stmt);
            } catch (\Exception $err) {
                throw $err;
            } finally {
                if ( !is_null($stmt) ) {
                    $stmt->close();
                }
                if ( static::$closeConnection ) {
                    $conn->close();
                }
            }            
            return $arr;
        }

        public static function queryOne(mysqli $conn, string $sql, array $params = []) {  
            $arr = self::query($conn,$sql,$params);
            return is_array($arr) && count($arr) > 0 ? $arr[0] : null;
        }

        public static function multiQuery(mysqli $conn,string $sql,array $params = []):array {    
            function sqlGenerate(mysqli $conn,$sql,array $params):string {   
                function valToStr(mysqli $conn,$val) {                  
                    if (is_null($val)) {
                        return "NULL";
                    } elseif ($val === false) {
                        return "0";
                    } elseif ($val === true) {
                        return "1";
                    }elseif ($val instanceof DateTime) {
                        return $val->format('Y-m-d H:i:s');
                    } elseif (is_string($val)) {
                        if (trim($val) == "") {
                            return "NULL";
                        } else {
                            return "'" . mysqli_escape_string($conn, $val) . "'";
                        }                
                    } elseif ((is_object($val)) || (is_array($val))) {
                        return "'" . json_encode($val, JSON_UNESCAPED_UNICODE) . "'";
                    } else {
                        return "$val";
                    }
                }     
                $nsql = preg_replace_callback("/\{[a-zA-Z_$][a-zA-Z_0-9]+\}/",function($m) use($params,$conn){
                    $name = substr($m[0],1,strlen($m[0])-2);
                    if (array_key_exists($name,$params)) {
                        return valToStr($conn,$params[$name]);
                    } else {
                        throw new \Exception("Parameter $name not found");
                    }             
                },$sql);
                return $nsql;
            }
            $results = array();
            try {
                if (mysqli_multi_query($conn, empty($params) ? $sql : sqlGenerate($conn,$sql,$params) )) {            
                    do {
                        $result = $conn->store_result();
                        if ($result instanceof mysqli_result) {
                            array_push($results,self::resultToArray($result));                        
                        }
                    } while ($conn->next_result());                
                } else {
                    throw new mysqli_sql_exception(mysqli_error($conn),mysqli_errno($conn));
                }
            } catch (\Exception $err) {
                throw $err;
            } finally {
                if (self::$closeConnection) {
                    $conn->close();
                }                
            }            
            return $results;
        }

        public static function repeatedQuery(mysqli $conn,string $sql,array $params = []):array {
            $conn->begin_transaction();
            $ex = null;
            $arr = [];
            for($i=0; $i<count($params); $i++) {                
                $stmt = null;
                try {
                    $stmt = self::sqlToStmt($conn,$sql,$params[$i]);
                    array_push($arr,self::stmtResult($stmt));
                } catch (\Exception $err) {                    
                    $ex = $err;
                    break;
                } finally {
                    if ( !is_null($stmt) ) {
                        $stmt->close();
                    }
                }
            }
            if (is_null($ex)) {
                $conn->commit();
            } else {
                $conn->rollback();
            }
            if (self::$closeConnection) {
                $conn->close();
            }
            if (!is_null($ex)) {
                throw $ex;
            }
            return $arr;
        }
    }
}