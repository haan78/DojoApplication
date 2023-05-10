
SET GLOBAL log_bin_trust_function_creators = 1;

DROP DATABASE IF EXISTS dojo;
CREATE DATABASE dojo DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci;

DROP USER IF EXISTS 'dojosensei'@'%';
CREATE USER 'dojosensei'@'%' IDENTIFIED BY 'UUmFxv@2C67&27Ckf_3Gv';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON dojo.* TO 'dojosensei'@'%';
