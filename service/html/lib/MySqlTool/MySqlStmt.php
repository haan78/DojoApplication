<?php

namespace MySqlTool {

    use DateTime;
    use mysqli;
    use mysqli_result;
    use mysqli_stmt;
    use stdClass;

    class MySqlStmt {
        public static function resultToArray(mysqli_result $result) : array {
            $arr = array();
            while ($row = $result->fetch_object()) {
                array_push($arr,$row);
            }
            $result->free();
            return $arr;
        }

        public static function stmtToArray(mysqli_stmt $stmt) : array {
            if ($stmt->execute()) {
                $result = $stmt->get_result();
                if ( $result ) {
                    $arr = self::resultToArray($result);
                } else {
                    throw new \Exception("Stmt has no result");
                }
            } else {
                throw new \Exception(mysqli_stmt_error($stmt)." / ".mysqli_stmt_errno($stmt));
            }
            
            return $arr;
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

        public static function query(mysqli $conn, string $sql, array $params = []) : array {
            $stmt = self::sqlToStmt($conn, $sql, $params);
            $arr = self::stmtToArray($stmt);
            $stmt->close();
            return $arr;
        }

        public static function queryOne(mysqli $conn, string $sql, array $params = []) {            
            $stmt = self::sqlToStmt($conn, $sql, $params);            
            $arr = self::stmtToArray($stmt);            
            $stmt->close();
            if ( count($arr) > 0 ) {
                return $arr[0];

            } else {
                return null;
            }
        }

        public static function execute(mysqli $conn, string $sql, array $params = []) :int {
            $stmt = self::sqlToStmt($conn, $sql, $params);
            if (!$stmt->execute()) {
                throw new \Exception(mysqli_stmt_error($stmt)." / ".mysqli_stmt_errno($stmt));
            }
            $num = mysqli_stmt_affected_rows($stmt);
            $stmt->close();
            return $num;
        }

    }
}