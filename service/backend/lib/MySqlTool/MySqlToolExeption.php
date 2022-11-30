<?php
namespace MySqlTool {
    class MySqlToolDatabaseException extends \Exception {
        private $sql;

        public function __construct($message, $code = 0, $sql = "", \Exception $previous = null) {
            parent::__construct($message, $code, $previous);
            $this->sql = $sql;
        }

        public function __toString() {
            return __CLASS__ . ": [{$this->code}]: {$this->message} SQL: $this->sql";
        }

        public function getSql() {
            return $this->sql;
        }
    }

    class MySqlToolMethodException extends \Exception {
        private $method;

        public function __construct($message, $code = 0, $method = "", \Exception $previous = null) {
            parent::__construct($message, $code, $previous);
            $this->method = $method;
        }

        public function __toString() {
            return __CLASS__ . ": [{$this->code}]: {$this->message} Method: $this->method";
        }

        public function getMethod() {
            return $this->method;
        }
    }
}