<?php

namespace MySqlTool {

    require_once __DIR__ . "/MySqlToolExeption.php";

    use MySqlTool\MySqlToolDatabaseException;

    class MySqlToolTable
    {
        private $link;
        private $table;
        private $fields;
        public $lastSQL;

        public function __construct(\mysqli $link,$table)
        {
            $this->link = $link;
            $this->table = $table;
            $this->fields = $this->getFields($this->link,$this->table);
        }

        private function getTypeDetails($typestr, &$type, &$size, &$decimal)
        {
            preg_match('/([A-Za-z]+)\s*\(([0-9]+)\)|([A-Za-z]+)/is', $typestr, $match);
            if ($match[1] == "") {
                $size = 0;
                $decimal = 0;
                $type = trim($match[2]);
            } else {
                $type = trim($match[1]);
                $arr = explode(",", $match[2]);
                $size = (isset($arr[0]) ? intval($arr[0]) : 0);
                $decimal = (isset($arr[1]) ? intval($arr[1]) : 0);
            }
        }

        private function getFields($link, $table)
        {
            $fResult = mysqli_query($link, "SHOW FULL COLUMNS FROM " . $table);
            if (!$fResult) {
                throw new  MySqlToolDatabaseException(mysqli_error($link),mysqli_errno($link),$this->lastSQL);
            }
            $arr = [];
            while ($row = mysqli_fetch_assoc($fResult)) {
                $fn = trim(strtolower($row['Field']));
                $this->getTypeDetails($row["Type"], $type, $size, $decimal);
                $arr[$fn] = [
                    "name" => $fn,
                    "type" => $type,
                    "size" => $size,
                    "decimal" => $decimal,
                    "nullable" => ($row["Type"] == "NO" ? false : true),
                    "unique" => ((($row["Key"] == 'PRI') || ($row["Key"] == 'UNI')) ? true : false),
                    "default" => $row["Default"]
                ];
            }
            return $arr;
        }

        private function adaptedValue($link, $v, $fi)
        {

            if (!is_null($v)) {
                if ($fi["type"] == "bit") {
                    return ($v ? "1" : "0");
                } elseif ($fi["type"] == "json") {
                    return "'" . json_encode($v) . "'";
                } else {
                    return "'" . mysqli_escape_string($link, $v) . "'";
                }
            } else {
                return "NULL";
            }
        }

        private function sqlInsert($link, $table,$fields, $data)
        {            
            $names = "";
            $values = "";
            $update = "";
            $i = 0;
            foreach ($data as $name => $value) {
                if (isset($fields[$name])) {
                    $attr = $fields[$name];
                    $comma = ($i > 0 ? ',' : '');
                    $names .= $comma . $name;
                    $values .= $comma . $this->adaptedValue($link, $value, $attr);
                    $update .= $comma . "$name = VALUES( $name )";
                    $i++;
                }
            }

            $this->lastSQL = "INSERT INTO $table ( $names ) VALUES ( $values ) ON DUPLICATE KEY UPDATE $update";
            if (mysqli_query($link, $this->lastSQL)) {
                return mysqli_insert_id($link);
            } else {
                throw new MySqlToolDatabaseException(mysqli_error($link),mysqli_errno($link),$this->lastSQL);
            }
        }

        private function sqlDelete($link, $table,$fields,$data)
        {
            $condition = "";
            $i = 0;
            foreach ($data as $name => $value) {
                if (isset($fields[$name])) {
                    $attr = $fields[$name];
                    $condition .= ($i > 0 ? 'AND' : '') . " $name = " . $this->adaptedValue($link, $value, $attr);
                    $i++;
                }
            }
            if ($condition != "") {
                $this->lastSQL = "DELETE FROM $table WHERE $condition";
                if (!mysqli_query($link, $this->lastSQL)) {
                    throw new MySqlToolDatabaseException(mysqli_error($link),mysqli_errno($link),$this->lastSQL);
                }
            } else {
                throw new MySqlToolMethodException("No Condition",2001,__METHOD__);
            }
        }

        private function sqlSelect($link, $table,$fields,$conditions,$limit) {
            $sql = "SELECT * FROM $table WHERE 1=1";
            if ( is_array($conditions) ) {
                for( $i=0; $i<count($conditions); $i++ ) {
                    $field = $conditions[$i]["field"];                
                    if ( isset($fields[$field]) ) {
                        $value = $this->adaptedValue($link,$conditions[$i]["value"],$fields[$field]);
                        $operator = ( isset( $conditions[$i]["operator"] ) ? $conditions[$i]["operator"] : "=" );
                        $condition = ( isset( $conditions[$i]["condition"] ) ? $conditions[$i]["condition"] : "AND" );
                        $sql.= " $condition $field $operator $value";
                    }
                }
            }            
            $sql.=" LIMIT 0,$limit";

            $this->lastSQL = $sql;
            $result = mysqli_query($link,$this->lastSQL);
            
            if ( $result !== FALSE ) {
                $arr = [];
                while( $row = mysqli_fetch_assoc($result) ) {                    
                    array_push($arr,$row);
                }
                return $arr;
            } else {
                throw new MySqlToolDatabaseException(mysqli_error($link),mysqli_errno($link),$this->lastSQL);
            }
        }
        public function insert($data) {
            return $this->sqlInsert($this->link,$this->table,$this->fields,$data);
        }

        public function delete($data) {
            $this->sqlDelete($this->link,$this->table,$this->fields,$data);
        }

        public function select($conditions = false,$limit = 1000) {
            return $this->sqlSelect($this->link,$this->table,$this->fields,$conditions,$limit);
        }

    }
}
