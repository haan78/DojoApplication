CREATE USER dojosensei@'%' IDENTIFIED BY '[parola]';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON dojo.* TO dojosensei@'%';