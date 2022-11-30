USE dojo;

DELIMITER ;;
CREATE  FUNCTION `parola_uret`(
        `length` TINYINT
    ) RETURNS varchar(100) CHARSET utf8mb3 COLLATE utf8_turkish_ci
BEGIN
  SET @returnStr = '';
 
  SET @allowedChars = 'abzcudefygtijpmnk1234h56789-.';
  SET @i = 0;

  WHILE (@i < length) DO
    SET @returnStr = CONCAT(@returnStr, SUBSTRING(@allowedChars, FLOOR(RAND() * LENGTH(@allowedChars) + 1), 1));
    SET @i = @i + 1;
  END WHILE;

  RETURN @returnStr;
END ;;

CREATE  PROCEDURE `muhasebe_sil`(
        IN `p_muhasebe_id` BIGINT
    )
BEGIN
	START TRANSACTION;
	DELETE FROM `muhasebe` WHERE `muhasebe`.`muhasebe_id` = p_muhasebe_id;
    DELETE FROM `dosya` WHERE `dosya`.`tablo` = 'MUHASEBE' and `dosya`.`tablo_id` = p_muhasebe_id;
    UPDATE `uye_tahakkuk` ut set ut.`muhasebe_id` = null WHERE ut.`muhasebe_id` = p_muhasebe_id;
    COMMIT;

END ;;

CREATE  PROCEDURE `parola_degistir`(
        IN `p_uye_id` BIGINT,
        IN `p_parola` VARCHAR(10),
        IN `p_parola_eski` VARCHAR(10)
    )
BEGIN
	
	UPDATE uye u SET u.`parola` = MD5(p_parola) WHERE u.`uye_id` = p_uye_id AND parola = IF(LENGTH(u.parola)<=6,p_parola_eski,MD5(p_parola_eski));
	IF ROW_COUNT() < 1 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Old password is wrong', MYSQL_ERRNO = 1001;
	END IF;
END ;;

CREATE  PROCEDURE `uye_bilgi`(
        IN `p_uye_id` BIGINT
    )
BEGIN
	SELECT 
    	u.`ad`,u.`cinsiyet`,u.`dosya_id`,u.`durum`,u.`ekfno`,u.`email`,u.`tahakkuk_id`,t.tanim  as "tahakkuk",u.dogum_tarih ,d.`icerik` as img64,
    	(SELECT count(*) FROM  uye_yoklama uy WHERE uy.uye_id  = u.uye_id AND uy.tarih >= DATE_ADD(CURRENT_DATE,INTERVAL -3 MONTH)) as son3Ay 
    FROM uye u 
    INNER JOIN `tahakkuk` t ON t.`tahakkuk_id` = u.`tahakkuk_id`
    LEFT JOIN dosya d ON d.`dosya_id` = u.`dosya_id`
    WHERE u.`uye_id` = p_uye_id;
    
    SELECT 
    us.`uye_seviye_id`,us.`aciklama`,us.`tarih`,us.`seviye`
    FROM `uye_seviye` us INNER JOIN seviye s ON s.`seviye` = us.`seviye` 
    WHERE us.`uye_id` = p_uye_id
    ORDER BY s.`deger` DESC;
    
    SELECT ut.`uye_tahakkuk_id`,ut.`yil`,ut.`ay`,ut.`tahakkuk_tarih`,ut.`borc`,t.tanim , m.`tutar` as odeme_tutar,m.`tarih` as odeme_tarih, m.muhasebe_id,
     y.tanim as yoklama, ut.yoklama_id,
     (SELECT 
     	GROUP_CONCAT(DISTINCT uy.tarih ORDER BY uy.tarih ASC SEPARATOR ',') 
     		FROM uye_yoklama uy
     			WHERE uy.uye_id = ut.uye_id AND MONTH(uy.tarih) = ut.ay AND YEAR(uy.tarih) = ut.yil AND uy.yoklama_id = ut.yoklama_id ) as keikolar
    FROM `uye_tahakkuk` ut 
    LEFT JOIN `tahakkuk` t ON t.`tahakkuk_id` = ut.`tahakkuk_id`
    LEFT JOIN `muhasebe` m ON m.`muhasebe_id` = ut.`muhasebe_id`
    LEFT JOIN yoklama y on y.yoklama_id = ut.yoklama_id 
	    WHERE ut.`uye_id` = p_uye_id ORDER BY tahakkuk_tarih DESC;
    
   SELECT uy.tarih,y.yoklama_id , y.tanim  FROM uye_yoklama uy inner JOIN yoklama y on y.yoklama_id  = uy.yoklama_id WHERE uy.uye_id  = p_uye_id;
END;;

CREATE  PROCEDURE `uye_dogrula`(
        IN `p_durum` VARCHAR(20),
        IN `p_email` VARCHAR(255),
        IN `p_parola` VARCHAR(10)
    )
BEGIN
	SELECT u.`uye_id`,u.`ad`,u.`seviye` FROM uye u WHERE u.`durum` = p_durum AND u.`email` = p_email AND u.`parola` = MD5(p_parola);
END ;;

CREATE  PROCEDURE `uye_duzelt`(

        IN p_uye_id bigint,

        IN p_tahakkuk_id BIGINT,

        IN p_ad VARCHAR(255),

        IN p_dosya_id BIGINT,

        IN p_cinsiyet ENUM('ERKEK','KADIN'),

        IN p_ekfno varchar(20),

        IN p_dogum_tarih DATE,

        IN p_durum enum('active','passive','admin','super-admin')

    )
BEGIN	

	START TRANSACTION;

   

   	UPDATE uye u 

   		SET u.ad = p_ad, u.dosya_id  = p_dosya_id, 

   			u.cinsiyet = p_cinsiyet, u.dogum_tarih = p_dogum_tarih, u.tahakkuk_id  = p_tahakkuk_id,

   			u.ekfno = p_ekfno   			

   				WHERE u.uye_id = p_uye_id;

   

   	DELETE FROM dosya WHERE tablo = 'UYE' and tablo_id = p_uye_id and dosya_id <> p_dosya_id;

   	UPDATE `dosya` d set d.tablo = 'UYE', d.tablo_id = p_uye_id WHERE d.dosya_id = p_uye_id;

   	COMMIT;

END ;;

CREATE  PROCEDURE `uye_ekle`(
        INOUT `p_uye_id` BIGINT,
        OUT `p_parola` VARCHAR(10),
        IN `p_tahakkuk_id` BIGINT,
        IN `p_ad` VARCHAR(255),
        IN `p_email` VARCHAR(255),
        IN `p_dosya_id` BIGINT,
        IN `p_cinsiyet` ENUM('ERKEK','KADIN'),
        IN `p_dogum_tarih` DATE,
        IN `p_ekfno` VARCHAR(20),
        IN `p_durum` VARCHAR(20)
    )
BEGIN
	START TRANSACTION;
    if p_uye_id is null then    
    	SET @_pass = parola_uret(6);
    	INSERT INTO uye ( `ad`,`durum`,`cinsiyet`,dogum_tarih,`dosya_id`,`ekfno`,`email`,`email`, `tahakkuk_id`, `seviye`,parola )
    		VALUES ( p_ad, p_durum, p_cinsiyet,p_dogum_tarih, p_dosya_id, p_ekfno, p_email, p_tahakkuk_id,'07 KYU',MD5(@_pass) );
        set p_uye_id = LAST_INSERT_ID();
        #uye seviye ekle 7 kyu

        DELETE FROM `uye_seviye` WHERE uye_id = p_uye_id;
        insert into `uye_seviye` ( `uye_seviye`.`aciklama`,`uye_seviye`.`tarih`,`uye_seviye`.`uye_id`,`uye_seviye`.`seviye` )
        	VALUES ( 'Yeni giris',DATE(now()),p_uye_id,'07 KYU' ); 
        set p_parola = @_pass;
    else
    	UPDATE uye u 
        	SET u.`ad` = p_ad, u.`cinsiyet` = p_cinsiyet, `u`.`dosya_id` = p_dosya_id, 
            	u.`durum` = p_durum, u.`ekfno` = ekfno, u.`email` = p_email, u.`tahakkuk_id` = p_tahakkuk_id
            	WHERE u.`uye_id` = p_uye_id;
	end if;
    
    delete from `dosya` where `dosya`.`tablo` = 'UYE' and `dosya`.`tablo_id` = p_uye_id and `dosya`.`dosya_id` <> p_dosya_id;
    update `dosya` d set d.`tablo` = 'UYE', d.`tablo_id` = p_uye_id WHERE d.`dosya_id` = p_dosya_id;
    
    COMMIT;
END ;;

CREATE  PROCEDURE `uye_kimlik_degistir`(in p_anahtar varchar(255), in p_parola varchar(255))
BEGIN
	declare _email varchar(100) default null;
	declare uid bigint default null;
  
	SELECT ukd.email, ukd.uye_id into _email,uid FROM  uye_kimlik_degisim ukd  
		WHERE  ukd.anahtar = p_anahtar and ukd.olusma >= DATE_ADD(CURRENT_TIMESTAMP, INTERVAL -24 HOUR ) LIMIT 1;
	
	IF uid is not null and _email is not null THEN 
		UPDATE uye u SET u.email = _email, u.parola = if(p_parola is null,u.parola,MD5(p_parola)), 
		u.durum = if(u.durum = 'pre-registration','registered',u.durum) 
			WHERE u.uye_id = uid;
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Degisim kaydi bulunamiyor', MYSQL_ERRNO = 1001;
	end if;
	
END ;;

CREATE PROCEDURE `dojo`.`uye_kimlik_olustur`(out p_anahtar varchar(255),out p_ad varchar(255), in p_email varchar(100), in p_uye_id bigint)
BEGIN
	DECLARE uid bigint default null;
	DECLARE d varchar(20) default null;

	if p_uye_id is null then
		SELECT u.uye_id, u.ad, u.durum into uid,p_ad,d FROM uye u WHERE u.email = p_email LIMIT 1;
	else
		SELECT u.uye_id, u.ad, u.durum into uid,p_ad,d FROM  uye u WHERE u.uye_id = p_uye_id LIMIT 1;
	end if;

	if uid is not null then
		if d <> 'passive' then
			set p_anahtar = uuid();
			INSERT INTO uye_kimlik_degisim (uye_id,anahtar,email) VALUES (uid,p_anahtar,p_email) 
    			ON DUPLICATE KEY UPDATE anahtar = VALUES(anahtar), email = values(email);
    	else
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Membership is passive', MYSQL_ERRNO = 1001;
    	end if;
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email is not recorded', MYSQL_ERRNO = 1001;
	end if;
END;;

CREATE  PROCEDURE `uye_liste`(
        OUT `p_total` BIGINT,
        IN `p_start` BIGINT,
        IN `p_limit` BIGINT,
        IN `p_ara` VARCHAR(255),
        IN `p_durum` VARCHAR(255),
        IN `p_siralama_yon` ENUM('asc','desc'),
        IN `p_siralama_saha` VARCHAR(20)
    )
BEGIN
	declare s bigint default COALESCE(p_start,0);
    declare l bigint default COALESCE(p_limit,999999999);
	
    SELECT SQL_CALC_FOUND_ROWS u.`uye_id`,u.`ad`,u.`cinsiyet`,`u`.`dosya_id`,u.`durum`,u.`ekfno`,u.`email`,u.`seviye`, us.`tarih`, s.`deger`,t.`tanmim` as "tahakkuk"
        ,SUM(IF(ut.`muhasebe_id` is NULL,1,0)) as odenmemis_aidat_syisi,
        SUM(IF(ut.`muhasebe_id` is NULL ,ut.`borc`,0)) as odenmemis_aidat_borcu,
        (SELECT uy.`tarih` FROM `uye_yoklama` uy WHERE uy.`uye_id` = u.`uye_id` ORDER BY uy.`tarih` DESC LIMIT 1 ) AS son_keiko
    	FROM uye u
        INNER JOIN `tahakkuk` t on `t`.`tahakkuk_id` = u.`tahakkuk_id`
        INNER JOIN `uye_seviye` us ON us.`seviye` = u.`seviye` AND us.`uye_id` = u.`uye_id`
        INNER JOIN `seviye` s ON s.`seviye` = u.`seviye`
        LEFT JOIN `uye_tahakkuk` ut ON ut.`uye_id` = u.`uye_id`
        	WHERE 
            	( u.ad LIKE CONCAT('%',COALESCE(p_ara,''),'%')  ) AND
                ( FIND_IN_SET(u.`durum`,COALESCE(p_durum,'')) )
        		GROUP BY u.`uye_id`,u.`ad`,u.`cinsiyet`,`u`.`dosya_id`,u.`durum`,u.`ekfno`,u.`email`,u.`seviye`, us.`tarih`, s.`deger`,t.`tanmim`
                	ORDER BY IF(p_siralama_yon = 'asc' or p_siralama_yon is null,
                    (CASE p_siralama_yon
                    WHEN 'seviye' THEN CONCAT(LPAD((1000-s.`deger`),4,'0'),'-',DATE(us.tarih))
                    WHEN 'ad' THEN u.ad
                    WHEN 'borc' THEN odenmemis_aidat_borcu
                    WHEN 'keiko' THEN son_keiko
                    ELSE 0
                    END)
                    ,0) ASC, IF(p_siralama_yon = 'desc',
                    (CASE p_siralama_yon
                    WHEN 'seviye' THEN CONCAT(LPAD((1000-s.`deger`),4,'0'),'-',DATE(us.tarih))
                    WHEN 'ad' THEN u.ad
                    WHEN 'borc' THEN odenmemis_aidat_borcu
                    WHEN 'keiko' THEN son_keiko
                    ELSE 0
                    END)
                    ,0) DESC
        		LIMIT s,l;
    
    SET p_total = FOUND_ROWS();
END ;;

CREATE  PROCEDURE `uye_muhasebe`(
        OUT `p_muhasebe_id` BIGINT,
        IN `p_tanim` VARCHAR(255),
        IN `p_tutar` DECIMAL(14,2),
        IN `p_tarih` DATE,
        IN `p_kasa` VARCHAR(20),
        IN `p_uye_id` BIGINT,
        IN `p_aciklama` VARCHAR(255),
        IN `p_dosya_id` BIGINT,
        IN `p_tahsilatci` VARCHAR(80)
    )
BEGIN
	declare _mid bigint DEFAULT null;
	START TRANSACTION;
    
    insert into `muhasebe` ( uye_id,`aciklama`, `dosya_id`, `kasa`, `tanim`, `tarih`, `tutar`,tahsilatci )
    	VALUES (p_uye_id,p_aciklama, p_dosya_id, p_kasa, p_tanim, p_tarih, p_tutar,p_tahsilatci);

    set _mid = LAST_INSERT_ID();
    if p_dosya_id is not null then
        delete from `dosya` where `dosya`.`tablo` = 'MUHASEBE' and `dosya`.`tablo_id` = _mid and `dosya`.`dosya_id` <> p_dosya_id;
    	update `dosya` d set d.`tablo` = 'MUHASEBE', d.`tablo_id` = _mid WHERE d.`dosya_id` = p_dosya_id;
    end if;    
    COMMIT;
    SET p_muhasebe_id = _mid;
END ;;

CREATE  PROCEDURE `uye_odeme`(
        IN `p_uye_tahakkuk_id` BIGINT,
        IN `p_tarih` DATE,
        IN `p_tutar` DECIMAL(14,2),
        IN `p_dosya_id` BIGINT,
        IN `p_aciklama` VARCHAR(255),
        IN `p_kasa` VARCHAR(20)
    )
BEGIN
	DECLARE _uid bigint DEFAULT null;
    DECLARE _mid BIGINT DEFAULT null;
    DECLARE _t varchar(255) default null;
    SELECT ut.`uye_id`,t.`tanmim` into _uid, _t
    	FROM `uye_tahakkuk` ut 
        INNER JOIN `tahakkuk` t ON t.`tahakkuk_id` = ut.`tahakkuk_id`
        	WHERE ut.`uye_tahakkuk_id` = p_uye_tahakkuk_id;
	START TRANSACTION;
	
    insert into `muhasebe` ( uye_id,`aciklama`, `dosya_id`, `kasa`, `tanim`, `tarih`, `tutar` )
    	VALUES (_uid,p_aciklama, p_dosya_id, p_kasa, _t, p_tarih, p_tutar);
    
    set _mid = LAST_INSERT_ID();
        
    update `uye_tahakkuk` ut set ut.`muhasebe_id` = _mid where ut.`uye_tahakkuk_id` = p_uye_tahakkuk_id;
    
    COMMIT;
END ;;

CREATE  PROCEDURE `uye_onkayit`(

		OUT p_anahtar varchar(255),

        IN `p_tahakkuk_id` BIGINT,

        IN `p_ad` VARCHAR(255),

        IN `p_email` VARCHAR(255),

        IN `p_dosya_id` BIGINT,

        IN `p_cinsiyet` ENUM('ERKEK','KADIN'),

        IN `p_dogum_tarih` DATE

    )
BEGIN

	DECLARE uid bigint DEFAULT 0;

	START TRANSACTION;

	

    INSERT INTO uye ( ad,durum, cinsiyet, dogum_tarih, dosya_id, email, tahakkuk_id, seviye )

    	VALUES ( p_ad, 'pre-registration', p_cinsiyet,p_dogum_tarih, p_dosya_id, p_email, p_tahakkuk_id,'07 KYU');

    

    SET uid = LAST_INSERT_ID();
   	

   	INSERT INTO `uye_seviye` ( aciklama, tarih, uye_id, seviye )

   		VALUES ( 'Yeni giris',DATE(now()),uid,'07 KYU' );

   

   	UPDATE `dosya` d set d.`tablo` = 'UYE', d.`tablo_id` = p_uye_id WHERE d.`dosya_id` = uid;

   

   	set p_anahtar = uuid();

    INSERT INTO uye_kimlik_degisim (uye_id,anahtar,email) VALUES (uid,p_anahtar,p_email) 

    ON DUPLICATE KEY UPDATE anahtar = VALUES(anahtar), email = values(email);

    

    COMMIT;

END ;;

CREATE  PROCEDURE `uye_seviye_esd`(
        INOUT `p_uye_seviye_id` BIGINT,
        IN `p_uye_id` BIGINT,
        IN `p_seviye` CHAR(5),
        IN `p_tarih` DATE,
        IN `p_aciklama` VARCHAR(255)
    )
BEGIN
	START TRANSACTION;
    if p_uye_seviye_id is null then
    	INSERT INTO `uye_seviye` ( uye_id,tarih,aciklama, seviye )
    		VALUES (p_uye_id,p_tarih,p_aciklama,p_seviye);
    elseif p_uye_seviye_id is not null and p_seviye is null then
    	DELETE FROM uye_seviye WHERE uye_seviye_id = p_uye_seviye_id;
    elseif p_uye_seviye_id is not null and p_seviye is not null then
    	UPDATE `uye_seviye` us SET us.`aciklama` = p_aciklama, us.`seviye` = p_seviye, us.`tarih` = p_tarih
        	WHERE us.`uye_seviye_id` = p_uye_seviye_id;
    end if;
        
    COMMIT;
END ;;

CREATE  PROCEDURE `uye_tahakkuk_tahsilat`(
        IN `p_uye_tahakkuk_id` BIGINT,
        IN `p_kasa` VARCHAR(20),
        IN `p_tarih` DATE,
        IN `p_tutar` DECIMAL(14,2),
        IN `p_aciklama` VARCHAR(255),
        IN `p_dosya_id` BIGINT,
        IN `p_tahsilatci` VARCHAR(80)
    )
BEGIN
	DECLARE _mid bigint DEFAULT null;
    declare _tan VARCHAR(255) default null;
    DECLARE uid bigint DEFAULT null;

    select uy.`muhasebe_id`,`t`.`tanmim`,uy.`uye_id` into _mid,_tan,uid from `uye_tahakkuk` uy
    	INNER JOIN tahakkuk t on `t`.`tahakkuk_id` = uy.`tahakkuk_id`
     		WHERE uy.`uye_tahakkuk_id` = p_uye_tahakkuk_id;
    
    if _tan is null then
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Uye bulunamadi', MYSQL_ERRNO = 1001;
    end if;
    
    if _mid is not null then
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bu borc zaten odenmis', MYSQL_ERRNO = 1002;
    end if;
    
    CALL `uye_muhasebe`(_mid,_tan,p_tutar,p_tarih,p_kasa,uid,p_aciklama,p_dosya_id,p_tahsilatci);
    
    if _mid is null then
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Odeme kaydi yapilamiyor', MYSQL_ERRNO = 1003;
    end if;
            
    update `uye_tahakkuk` ut set ut.`muhasebe_id` = _mid WHERE ut.`uye_tahakkuk_id` = p_uye_tahakkuk_id;
        
    COMMIT;
    
END ;;

CREATE  PROCEDURE `uye_yoklama_ekle`(
        IN `p_uye_id` BIGINT,
        IN `p_yoklama_id` BIGINT,
        IN `p_tarih` DATE
    )
BEGIN
	declare _tt decimal(14,2) default null;
    declare _tid decimal(14,2) default null;
    declare say int(11) default 0;
    declare _yil year default year(p_tarih);
    declare _ay smallint default month(p_tarih);
    
    select u.`tahakkuk_id`, t.`tutar` into _tid,_tt 
    	from uye u
        inner join `tahakkuk` t on t.`tahakkuk_id` = `u`.`tahakkuk_id`
        	where u.uye_id = p_uye_id;
            
    if _tid is not null then
        select count(*) into say from uye_tahakkuk ut where ut.uye_id = p_uye_id and ut.tahakkuk_id = _tid and ut.yil = _yil and ut.ay = _ay;
	end if;
    
    START TRANSACTION;
    
    insert into uye_yoklama ( uye_id, yoklama_id,tarih ) values (p_uye_id, p_yoklama_id,p_tarih);
	if coalesce(say,0) = 0 and coalesce(tt,0) and _tid is not null > 0 then
		insert into uye_tahakkuk ( uye_id,tahakkuk_id,borc,tahakkuk_tarih,yil,ay,yoklama_id ) values (p_uye_id, _tid, _tt, p_tarih,_yil,_ay,p_yoklama_id);
    end if;
   
   update uye u set u.durum = 'active' where u.uye_id = p_uye_id and u.durum = 'registered'; 
    
    COMMIT;
    

END ;;

CREATE  PROCEDURE `uye_yoklama_sil`(
        IN `p_uye_id` BIGINT,
        IN `p_yoklama_id` BIGINT,
        IN `p_tarih` DATE
    )
BEGIN
	declare say int(11) default 0;   
    declare _yil year default year(p_tarih);
    declare _ay smallint default month(p_tarih);
    declare _tid BIGINT DEFAULT null;
    
    SELECT u.`tahakkuk_id` into _tid FROM uye u WHERE u.`uye_id` = p_uye_id;

    START TRANSACTION;
	delete from uye_yoklama where uye_id = p_uye_id and yoklama_id = p_yoklama_id and tarih = p_tarih;
    
    select count(*) into say from uye_yoklama where uye_id = p_uye_id and yoklama_id = p_yoklama_id and ( year(tarih) = _yil and month(tarih) = _ay );
    
    if coalesce(say,0) = 0 and _tid is not null then
		delete from uye_tahakkuk ut 
			where ut.`muhasebe_id` is null and ut.uye_id = p_uye_id and ut.tahakkuk_id = _tid and ut.yil = _yil and ut.ay = _ay and yoklama_id  = p_yoklama_id;
    end if;
    
    COMMIT;
END ;;

DELIMITER ;

