<?php
namespace MySqlTool {

use Exception;

class MySqlToolConnection {
        private static array $defaultOptions = [
            "timeout"=>20,
            "host"=>"localhost",
            "user"=>"root",
            "password"=>null,
            "database"=>null,
            "port"=>false,
            "charset"=>"utf8",
            "ssl_use"=> false,
            "ssl_key" => null,
            "ssl_certificate" => null,
            "ssl_ca_certificate" => null,
            "ssl_ca_path"=>null,
            "ssl_cipher" => null,
            "strict" => true
        ];

        private static function getAllOptions(?array $options) : object {
            $op = self::$defaultOptions;
            if ( !is_null($options) ) {
                $keys = array_keys($op);
                for($i=0; $i<count($keys); $i++ ) {
                    $key = $keys[$i];
                    if ( array_key_exists($key,$options) ) {
                        $op[$key] = $options[$key];
                    }
                }
            }
            return (object)$op;
        }

        public static function setDefault(string $name, $value) :  void {
            if ( array_key_exists($name,self::$defaultOptions) ) {
                self::$defaultOptions[$name] = $value;
            } else {
                throw new Exception("There is no such kind a property like $name");
            }
        }

        public static function getDefaults() :array {
            return self::$defaultOptions;
        }
    
        public static function link(?array $options = null) {
    
            $o = self::getAllOptions($options);
    
            if ($o->strict) {
                mysqli_report(MYSQLI_REPORT_STRICT | MYSQLI_REPORT_ERROR);
            }
            $link = mysqli_init();
            mysqli_options($link, MYSQLI_OPT_CONNECT_TIMEOUT,$o->timeout);
            if ( $o->ssl_use ) {
                mysqli_options($link, MYSQLI_OPT_SSL_VERIFY_SERVER_CERT,true);
                mysqli_ssl_set($link,$o->ssl_key,$o->ssl_certificate,$o->ssl_ca_certificate,$o->ssl_ca_path,$o->ssl_cipher);
            }
            mysqli_real_connect($link,$o->host,$o->user,$o->password,$o->database,$o->port);        
            mysqli_set_charset($link, $o->charset);
            return $link;
        }
    
        public static function version(?array $options) {
            $link = self::link($options);
            $ver = ""; 
            try {
                $result = mysqli_query($link,"SELECT VERSION()");
                if ($row = mysqli_fetch_array($result)) {
                    $ver = $row[0];
                }
            } finally {
                mysqli_close($link);
            }
            return $ver;
    
        }
    }
}