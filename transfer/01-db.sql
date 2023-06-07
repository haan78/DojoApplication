SET GLOBAL log_bin_trust_function_creators = 1;

DROP DATABASE IF EXISTS dojo;
CREATE DATABASE dojo DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci;

DROP USER IF EXISTS dojosensei@localhost;
CREATE USER dojosensei@localhost;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON dojo.* TO dojosensei@localhost;

SET NAMES utf8mb4 COLLATE utf8mb4_turkish_ci;

USE dojo;

