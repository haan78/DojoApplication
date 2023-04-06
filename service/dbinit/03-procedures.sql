##SET GLOBAL log_bin_trust_function_creators = 1;
USE dojo;

DELIMITER ;;

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

CREATE PROCEDURE `dojo`.`uye_bilgi`(
        IN `p_uye_id` BIGINT
    )
BEGIN
	SELECT 
    	u.`ad`,u.`cinsiyet`,u.`dosya_id`,u.`durum`,u.`ekfno`,u.`email`,u.`tahakkuk_id`,t.tanim  as "tahakkuk",u.dogum_tarih,
        (SELECT count(*) FROM  uye_yoklama uy WHERE uy.uye_id  = u.uye_id AND uy.tarih >= DATE_ADD(CURRENT_DATE,INTERVAL -3 MONTH)) as son3Ay,
        d.`file_type`,d.`icerik` as img64  	
    FROM uye u 
    INNER JOIN `tahakkuk` t ON t.`tahakkuk_id` = u.`tahakkuk_id`
    LEFT JOIN dosya d ON d.`dosya_id` = u.`dosya_id`
    WHERE u.`uye_id` = p_uye_id;
    
    SELECT 
    us.`uye_seviye_id`,us.`aciklama`,us.`tarih`,us.`seviye`
    FROM `uye_seviye` us INNER JOIN seviye s ON s.`seviye` = us.`seviye` 
    WHERE us.`uye_id` = p_uye_id
    ORDER BY s.`deger` DESC;
    
   SELECT uy.tarih,y.yoklama_id , y.tanim  
  	FROM uye_yoklama uy inner JOIN yoklama y on y.yoklama_id  = uy.yoklama_id WHERE uy.uye_id  = p_uye_id
  		ORDER BY uy.tarih DESC;
END;;

CREATE PROCEDURE `dojo`.`uye_kimlik_degistir`(in p_anahtar varchar(255), in p_parola varchar(255))
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
	
END;;


CREATE PROCEDURE `dojo`.`uye_ekle`(
        INOUT `p_uye_id` BIGINT,
        OUT `p_parola` VARCHAR(10),
        IN `p_tahakkuk_id` BIGINT,
        IN `p_ad` VARCHAR(255),
        IN `p_email` VARCHAR(255),
        IN `p_dosya` LONGBLOB,
        IN `p_cinsiyet` ENUM('ERKEK','KADIN'),
        IN `p_dogum_tarih` DATE,
        IN `p_ekfno` VARCHAR(20),
        IN `p_durum` VARCHAR(20)
    )
BEGIN
	START TRANSACTION;
    if p_uye_id is null then
    
    	INSERT INTO dosya ( tablo,tablo_id,icerik ) VALUES ('UYE',0,p_dosya);
    	SET @did = LAST_INSERT_ID();
    	
    	SET @_pass = parola_uret(6);
    	INSERT INTO uye ( `ad`,`durum`,`cinsiyet`,dogum_tarih,`dosya_id`,`ekfno`,`email`,`email`, `tahakkuk_id`, parola )
    		VALUES ( p_ad, p_durum, p_cinsiyet,p_dogum_tarih, @did, p_ekfno, p_email, p_tahakkuk_id,MD5(@_pass) );
        set p_uye_id = LAST_INSERT_ID();
        
       	#uye seviye ekle 7 kyu        
        insert into `uye_seviye` ( `uye_seviye`.`aciklama`,`uye_seviye`.`tarih`,`uye_seviye`.`uye_id`,`uye_seviye`.`seviye` )
        	VALUES ( 'Yeni Uye',DATE('1952-03-14'),p_uye_id,'7 KYU' ); 
        set p_parola = @_pass;
       	
    else
    	SET @did = NULL;
    	SELECT dosya_id INTO @did FROM uye WHERE uye_id = p_uye_id;
    	IF @did IS NULL THEN
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member not found', MYSQL_ERRNO = 1001;
    	END IF;
    	UPDATE uye u 
        	SET u.`ad` = p_ad, u.`cinsiyet` = p_cinsiyet, u.`durum` = p_durum, u.`ekfno` = ekfno, u.`email` = p_email, 
        	u.`tahakkuk_id` = p_tahakkuk_id
            	WHERE u.`uye_id` = p_uye_id;
        UPDATE dosya d SET d.icerik = p_dosya WHERE d.dosya_id = @did;       
	end if;
    
    
    COMMIT;
END;;

CREATE FUNCTION `dojo`.`parola_uret`(
        `length` TINYINT
    ) RETURNS varchar(100) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci
	READS SQL DATA DETERMINISTIC 
BEGIN
  SET @returnStr = '';
 
  SET @allowedChars = 'abzcudefygtijpmnk1234h56789-.';
  SET @i = 0;

  WHILE (@i < length) DO
    SET @returnStr = CONCAT(@returnStr, SUBSTRING(@allowedChars, FLOOR(RAND() * LENGTH(@allowedChars) + 1), 1));
    SET @i = @i + 1;
  END WHILE;

  RETURN @returnStr;
END;;

CREATE PROCEDURE `dojo`.`uye_yoklama_eklesil`(in p_yoklama_id bigint, in p_uye_id bigint, in p_tarih date )
BEGIN
	declare c int(11) DEFAULT  0;
	declare cay int(11) DEFAULT  0;
	declare tah bigint default 0;
	declare b decimal(14,2) default 0;

	
	SELECT count(1) into c from uye_yoklama uy where uy.yoklama_id = p_yoklama_id and uy.uye_id = p_uye_id and uy.tarih = p_tarih;
	SELECT count(1) into cay from uye_yoklama uy
		where uy.yoklama_id = p_yoklama_id and uy.uye_id = p_uye_id 
			and year(uy.tarih) = year(p_tarih) and MONTH(uy.tarih) = MONTH(p_tarih);	

	START TRANSACTION; 

	if coalesce(c,0) = 0 then
		INSERT into uye_yoklama ( yoklama_id, uye_id, tarih ) values ( p_yoklama_id,p_uye_id,p_tarih );
		if cay = 0 then
			SELECT u.tahakkuk_id,t.tutar into tah,b from uye u inner join tahakkuk t on t.tahakkuk_id  = u.tahakkuk_id
				WHERE u.uye_id = p_uye_id;
			insert into uye_tahakkuk ( uye_id,tahakkuk_id,borc,tahakkuk_tarih,yil,ay,yoklama_id )
				values (p_uye_id,tah,b,p_tarih,year(p_tarih),month(p_tarih),p_yoklama_id);
		end if;
		SELECT 1 as result;
	else
		DELETE  from uye_yoklama WHERE yoklama_id = p_yoklama_id and uye_id = p_uye_id and tarih = p_tarih;
		if cay = 1  then
			DELETE FROM uye_tahakkuk 
				WHERE uye_id = p_uye_id 
					AND yoklama_id = p_yoklama_id 
					AND ay = MONTH(uy.tarih) 
					AND yil = YEAR(p_tarih)
					AND muhasebe_id IS NULL;
		end if;
		SELECT -1 as result;
	end if;
	
	COMMIT;
	
END;;

CREATE PROCEDURE dojo.aidat_odeme_sil(in p_muhasebe_id bigint)
BEGIN
	declare utid bigint default null;
	SELECT ut.uye_tahakkuk_id into utid FROM uye_tahakkuk ut WHERE ut.muhasebe_id = p_muhasebe_id limit 1;
	if utid is not null then
		start transaction;
		DELETE FROM muhasebe WHERE muhasebe_id = p_muhasebe_id and muhasebe_tanim_id = 9;
		if ROW_COUNT() > 0 then	
			UPDATE uye_tahakkuk ut set ut.muhasebe_id = NULL WHERE ut.muhasebe_id = p_muhasebe_id;
			commit;
		else
			rollback;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kayit silinemdei', MYSQL_ERRNO = 1002;
		end if;		
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ilgili tahakkuk bulunamadi', MYSQL_ERRNO = 1001;
	end if;
	
END;;


CREATE PROCEDURE dojo.aidat_odeme_al(in p_uye_id bigint, in p_yoklama_id bigint, in p_tarih date, in p_yil smallint, in p_ay tinyint , in p_kasa varchar(20), in p_tutar decimal(14,2), in p_aciklama varchar(255), in p_tahsilatci varchar(80) )
BEGIN
	declare utid bigint default null;
	declare tid bigint default null;
	declare muhid bigint default null;	
	
	SELECT ut.uye_tahakkuk_id,ut.muhasebe_id into utid,muhid FROM uye_tahakkuk ut 
			WHERE ut.uye_id = p_uye_id AND ut.yoklama_id = p_yoklama_id AND ut.ay = p_ay AND ut.yil = p_yil LIMIT 1;

	START TRANSACTION;
	
	if muhid is null then
		INSERT into muhasebe ( uye_id, tarih, tutar, kasa, aciklama, muhasebe_tanim_id, tahsilatci, ay, yil  )
			values (p_uye_id, p_tarih, p_tutar, p_kasa, p_aciklama, 9, p_tahsilatci, p_ay, p_yil );
		SET muhid = LAST_INSERT_ID();
	else
		UPDATE muhasebe m 
			SET m.tarih = p_tarih, m.tutar = p_tutar, m.kasa = p_kasa, m.aciklama = p_aciklama, m.tahsilatci = p_tahsilatci, m.ay = p_ay, m.yil = p_yil
				WHERE m.muhasebe_id = muhid;
	end if;

	if utid is not null then
		UPDATE uye_tahakkuk ut SET ut.muhasebe_id = muhid, ut.borc = p_tutar  WHERE ut.uye_tahakkuk_id = utid;
	else
		SELECT u.tahakkuk_id into tid FROM uye u WHERE u.uye_id  = p_uye_id;
		INSERT into uye_tahakkuk (uye_id,tahakkuk_id,borc,tahakkuk_tarih,muhasebe_id,yil,ay,yoklama_id)
			VALUES(p_uye_id, tid, p_tutar, p_tarih, muhid, p_yil, p_ay, p_yoklama_id );
	end if;
	COMMIT;
	SELECT muhid AS muhasebe_id;
END;;

CREATE PROCEDURE dojo.muhasebe_esd(inout p_muhasebe_id bigint, in p_uye_id bigint, in p_tarih date, in p_tutar decimal(14,2), in p_kasa varchar(20), in p_muhasebe_tanim_id bigint , in p_aciklama varchar(255), in p_belge varchar(50), in p_tahsilatci varchar(80))
BEGIN
	if p_muhasebe_tanim_id = 9 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aidatlar degisiklik buradan yapilamaz', MYSQL_ERRNO = 1001;
	end if;
	
	if p_belge is not null then
		SET @c = null;
		SELECT count(1) into @c from muhasebe m WHERE m.belge LIKE p_belge and m.muhasebe_id = COALESCE(p_muhasebe_id, m.muhasebe_id);
		if COALESCE(@c,0) > 0 then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bu belge kodu daha once kullanilmis', MYSQL_ERRNO = 1002;
		end if;
	end if;

	if p_muhasebe_id is not null and p_tutar is null then
		DELETE from muhasebe WHERE muhasebe_id = p_muhasebe_id and muhasebe_tanim_id <> 9;
	elseif p_muhasebe_id is null and p_tutar is not null then
		
		insert into muhasebe ( uye_id, tarih, tutar, kasa, aciklama, muhasebe_tanim_id, belge, tahsilatci )
			values (p_uye_id, p_tarih, p_tutar, p_kasa, p_aciklama, p_muhasebe_tanim_id, p_belge, p_tahsilatci );
		SET p_muhasebe_id = last_insert_id();
	elseif p_muhasebe_id is not null and p_tutar is not null then
		update muhasebe m set m.tarih = p_tarih, m.tutar = p_tutar, m.kasa = p_kasa, 
			m.aciklama = p_aciklama, m.muhasebe_tanim_id = p_muhasebe_tanim_id, 
			m.tahsilatci = p_tahsilatci, m.belge = p_belge
			WHERE m.muhasebe_id  = p_muhasebe_id and m.muhasebe_tanim_id <> 9;
	end if;
	
END;;


DELIMITER ;

