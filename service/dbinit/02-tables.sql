USE dojo;

SET NAMES utf8mb4;

CREATE TABLE dosya (
  dosya_id bigint NOT NULL AUTO_INCREMENT,
  tablo enum('UYE','MUHASEBE') CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  tablo_id bigint DEFAULT NULL,
  icerik longblob NOT NULL,
  file_type varchar(20) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  olusma timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisme timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (dosya_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;


CREATE TABLE muhasebe (
  muhasebe_id bigint NOT NULL AUTO_INCREMENT,
  uye_id bigint DEFAULT NULL,
  tarih date NOT NULL,
  tutar decimal(14,2) NOT NULL,
  kasa varchar(20) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  aciklama varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  dosya_id bigint DEFAULT NULL,
  tanim varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  tahsilatci varchar(80) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  olusma timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisme timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  ay tinyint DEFAULT NULL,
  yil year DEFAULT NULL,
  PRIMARY KEY (muhasebe_id),
  KEY muhasebe_idx2 (tarih)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;


CREATE TABLE seviye (
  seviye char(5) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  deger int NOT NULL,
  PRIMARY KEY (seviye)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;
INSERT INTO seviye VALUES 
    ('1 DAN',10),('1 KYU',7),('2 DAN',20),('2 KYU',6),('3 DAN',40),('3 KYU',5),('4 DAN',80),('4 KYU',4),('5 DAN',160),
    ('5 KYU',3),('6 DAN',320),('6 KYU',2),('7 DAN',640),('7 KYU',1);

CREATE TABLE tahakkuk (
  tahakkuk_id bigint NOT NULL AUTO_INCREMENT,
  tanim varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  tutar decimal(14,2) DEFAULT NULL,
  olusma timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisme timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (tahakkuk_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;
INSERT INTO tahakkuk (tahakkuk_id,tanim,tutar) VALUES (1,'Tam Aidat',250.00),(2,'Öğrenci Aidat',200.00);

CREATE TABLE uye (
  uye_id bigint NOT NULL AUTO_INCREMENT,
  tahakkuk_id bigint NOT NULL,
  ad varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  email varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  dosya_id bigint NOT NULL COMMENT 'uye fotografi',
  cinsiyet enum('ERKEK','KADIN') CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  dogum_tarih date NOT NULL,
  ekfno varchar(20) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  durum enum('active','passive','admin','super-admin','pre-registration','registered') CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  seviye char(6) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  parola varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  olusma timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisme timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (uye_id),
  UNIQUE KEY ad (ad),
  UNIQUE KEY email (email)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;

CREATE TABLE uye_kimlik_degisim (
  uye_id bigint NOT NULL,
  email varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  anahtar varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  olusma timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisme timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (uye_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;

CREATE TABLE uye_seviye (
  uye_seviye_id bigint NOT NULL AUTO_INCREMENT,
  tarih date NOT NULL,
  aciklama varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci DEFAULT NULL,
  uye_id bigint NOT NULL,
  seviye char(6) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  olusum timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisim timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (uye_seviye_id),
  UNIQUE KEY uye_seviye_idx1 (uye_id,seviye)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;

CREATE TABLE uye_tahakkuk (
  uye_tahakkuk_id bigint NOT NULL AUTO_INCREMENT,
  uye_id bigint NOT NULL,
  tahakkuk_id bigint NOT NULL,
  borc decimal(14,2) NOT NULL,
  tahakkuk_tarih date NOT NULL,
  muhasebe_id bigint DEFAULT NULL,
  yil year DEFAULT NULL,
  ay smallint DEFAULT NULL,
  olusma timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisme timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  yoklama_id bigint DEFAULT NULL,
  PRIMARY KEY (uye_tahakkuk_id),
  KEY uye_tahakkuk_idx1 (uye_id,tahakkuk_id) USING BTREE,
  KEY uye_tahakkuk_idx2 (muhasebe_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;

CREATE TABLE uye_yoklama (
  uye_id bigint NOT NULL,
  yoklama_id varchar(45) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  tarih date NOT NULL,
  olusma timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  degisme timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY ind_uye_yoklama_1 (uye_id,yoklama_id,tarih)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;

CREATE TABLE yoklama (
  yoklama_id bigint NOT NULL AUTO_INCREMENT,
  tanim varchar(255) CHARACTER SET utf8 COLLATE utf8_turkish_ci NOT NULL,
  PRIMARY KEY (yoklama_id),
  UNIQUE KEY tanim_UNIQUE (tanim)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_turkish_ci;
INSERT INTO yoklama VALUES (1,'MTA');
