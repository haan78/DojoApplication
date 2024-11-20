<?php

use MySqlTool\MySqlStmt;

require_once "./lib/MySqlTool/MySqlToolCall.php";
require_once "./lib/MySqlTool/MySqlStmt.php";

MySqlStmt::$closeConnection = TRUE;

function mysqlilink(): mysqli {
    $c = @mysqli_connect(
        $GLOBALS["DB"]["host"] ?? "",
        $GLOBALS["DB"]["user"]?? "dojosensei",
        $GLOBALS["DB"]["password"]?? "",
        $GLOBALS["DB"]["database"]?? "dojo",
        $GLOBALS["DB"]["port"]?? 3306
    );
    if ($c) {
        mysqli_report(MYSQLI_REPORT_STRICT);
        return $c;
    } else {
        throw new Exception("DB Error  / ".mysqli_connect_error());
    }
}

function create_identity(int $uye_id, string $username,&$ad,&$code) : void {    
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $outs = $p->procedure("uye_kimlik_olustur")->
                out("code")->
                out("ad")->
                in($username)->
                in($uye_id < 1 ? null : $uye_id)->
                call()->
                result("outs");
    $ad = $outs["ad"];
    $code = $outs["code"];
}

function reset_password(string $code, string $password) : void {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $p->procedure("uye_kimlik_degistir")->in($code)->in($password)->call();
}

function validate(string $username, string $password, string $type) {    
    $sql = "SELECT ad,durum,uye_id,dosya_id FROM uye
                WHERE FIND_IN_SET(durum,?) > 0 AND
                    email = ? AND parola = IF(LENGTH(parola)<=6,?, MD5(?) )";    
    $list = "none";
    if ($type == "mobile") {
        $list = "admin,super-admin";
    } elseif ($type == "web") {
        $list = "active,admin,super-admin";
    }
    return MySqlStmt::queryOne(mysqlilink(),$sql,[$list,$username,$password,$password]);
}

function uye(int $uye_id) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    return $p->procedure("uye_bilgi")->in($uye_id)->call()->result("queries");
}

function uye_listele(string $durumlar) : array {        
    $sql = "SELECT u.uye_id,u.ad,u.dosya_id,(SELECT seviye FROM uye_seviye WHERE uye_id = u.uye_id ORDER BY tarih DESC LIMIT 1) as seviye
    ,SUM(IF(ut.uye_tahakkuk_id is NULL,0,1)) as odenmemis_aidat_syisi,
    SUM( COALESCE(ut.borc,0) ) as odenmemis_aidat_borcu,
    (SELECT uy.tarih FROM uye_yoklama uy WHERE uy.uye_id = u.uye_id ORDER BY uy.tarih DESC LIMIT 1 ) AS son_keiko,
    (SELECT count(*) FROM  uye_yoklama uy WHERE uy.uye_id  = u.uye_id AND uy.tarih >= DATE_ADD(CURRENT_DATE,INTERVAL -3 MONTH)) as son3Ay
    FROM uye u
    LEFT JOIN uye_tahakkuk ut ON ut.uye_id = u.uye_id and ut.muhasebe_id  is null
    WHERE FIND_IN_SET(u.durum,?)
    GROUP BY u.uye_id,u.ad,u.cinsiyet,u.dosya_id,u.durum,u.ekfno,u.email,seviye"; 
    return MySqlStmt::query(mysqlilink(),$sql,[$durumlar]);
}

function uyeImage(int $uye_id):stdClass {
    $sql = "SELECT d.icerik as icerik, d.file_type FROM uye u LEFT JOIN dosya d ON d.dosya_id = u.dosya_id WHERE u.uye_id = ?";
    $result = MySqlStmt::queryOne(mysqlilink(),$sql,[$uye_id]);
    if (!is_null($result)) {
        return $result;
    } else {
        throw new Exception("No data");
    }
}

function sabitler() {
    $sql = "SELECT tahakkuk_id,tanim,tutar FROM tahakkuk;
    SELECT yoklama_id,tanim FROM yoklama;
    SELECT muhasebe_tanim_id,tanim,tur FROM muhasebe_tanim";  
    $result = MySqlStmt::multiQuery(mysqlilink(),$sql);
    $data = [
        "tahakkuklar"=>$result[0],
        "yoklamalar" =>$result[1],
        "muhasebe_tanimlar" => $result[2]
    ];
    return $data;
}

function password(int $uye_id, string $old, string $new) {    
    $sql = "UPDATE uye SET parola = MD5(?) WHERE parola =  IF(LENGTH(parola)<=6,?, MD5(?) ) AND uye_id = ?";
    return MySqlStmt::query(mysqlilink(),$sql,[$new,$old,$old,$uye_id]);
}

function seviye_ekle($uye_id,string $seviye, string $tarih, string $aciklama) {
    $sql = "INSERT INTO uye_seviye ( uye_id,tarih,aciklama, seviye ) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE tarih = VALUES(tarih), aciklama = VALUES(aciklama)";
    return MySqlStmt::query(mysqlilink(),$sql,[$uye_id,$tarih,$aciklama,$seviye]);
}

function seviye_sil($uye_id,string $seviye) {
    $sql = "DELETE FROM uye_seviye WHERE uye_id = ? AND seviye = ?";  
    return MySqlStmt::query(mysqlilink(),$sql,[$uye_id,$seviye]);
}

function uye_eke($uye_id,$ad,$tahakkuk_id,$email,$cinsiyet,$dogum,$ekfno,$durum) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $outs = $p->procedure("uye_ekle")->out("uye_id",$uye_id)->out("parola")->in($tahakkuk_id)
    ->in($ad)->in($email)->in($cinsiyet)->in($dogum)->in($ekfno)->in($durum)->call()->result("outs");
    return $outs["uye_id"];
}

function uploadUyeFoto(int $uye_id) {
    $sql = "CALL uye_foto(?,?,?)";
    $fpn = array_keys($_FILES)[0] ?? "";
    if ($fpn) {
        $fotofile = $_FILES[$fpn];
        $path = $fotofile["tmp_name"];
        $mimetype = $fotofile['type'];        
        $img = imagecreatefromjpeg($path);
            list($w, $h) = getimagesize($path);
            if ( $w > $h ) {
                $img = imagerotate($img,-90,0);
            }
            ob_start();
            imagejpeg($img);
            $img64 = base64_encode(ob_get_clean());
            return MySqlStmt::query(mysqlilink(),$sql,[$uye_id,$img64,"image/jpeg"]);
    } else {
        throw new Exception("Dosya gonderilmemis");
    }
    
}

function uye_eposta_onkayit(int $uye_id,string &$ad,string &$email,string &$code,string &$parola):void { //coklu
    $sqlSel = "SELECT ad,email,parola FROM uye WHERE uye_id = ?";
    $sqlIns = "INSERT INTO uye_kimlik_degisim (uye_id,anahtar,email) VALUES (?,?,?) ON DUPLICATE KEY UPDATE anahtar = VALUES(anahtar), email = values(email)";
    MySqlStmt::$closeConnection = FALSE;
    $mysqli = mysqlilink();
    try {
        $row = MySqlStmt::queryOne($mysqli,$sqlSel,[$uye_id]);
        if ($row) {
            $code = uniqid(date('ymdHis'));
            $email = $row->email;
            $ad = $row->ad;     
            $parola = $row->parola;       
            MySqlStmt::query($mysqli,$sqlIns,[$uye_id,$code,$email]);            
        } else {
            throw new Exception("On Kayit bulunamadi");
        }
    } catch (Exception $err) {
        throw $err;
    } finally {
        $mysqli->close();
    }
}

function uye_eposta_onay(string $code) : void { //coklu   
    $sqlSel = "SELECT uye_id FROM uye_kimlik_degisim WHERE anahtar = ? AND TIME_TO_SEC(TIMEDIFF(NOW(), COALESCE(degisme,olusma))) <= 86400";
    $sqlUp = "UPDATE uye SET durum = 'active' WHERE durum = 'registered' AND uye_id = ?";
    MySqlStmt::$closeConnection = FALSE;
    $mysqli = mysqlilink();
    try {
        $row = MySqlStmt::queryOne($mysqli,$sqlSel,[$code]);
        if (!is_null($row)) {
            MySqlStmt::query($mysqli,$sqlUp,[$row->uye_id]);
        } else {
            throw new Exception("Kayit bulunamadi");
        }
    } catch(Exception $err) {
        throw $err;
    } finally {
        $mysqli->close();
    }
}

function uye_yoklama_eklesil(int $yoklama_id, int $uye_id, string $tarih) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    return $p->procedure("uye_yoklama_eklesil")->in($yoklama_id)->in($uye_id)->in($tarih)->call()->result("queries");
}

function yoklamalar() {
    $sql = "SELECT uy.tarih,uy.yoklama_id,y.tanim,COUNT(1) AS sayi  FROM  uye_yoklama uy 
	INNER JOIN yoklama y ON y.yoklama_id = uy.yoklama_id
	WHERE uy.tarih >= DATE_ADD(CURRENT_DATE(), INTERVAL -10 YEAR)
	GROUP BY uy.tarih,uy.yoklama_id,y.tanim ORDER BY uy.tarih DESC";    
    return MySqlStmt::query(mysqlilink(),$sql);
}

function yoklamaliste(int $yoklama_id, string $tarih) {
    $sql = "SELECT u.uye_id,u.ad,IF(uy.yoklama_id IS NOT NULL,1,0) as katilim FROM uye u 
    LEFT JOIN uye_yoklama uy ON uy.uye_id = u.uye_id and uy.yoklama_id = ? AND uy.tarih = ? 
    WHERE (u.durum NOT IN ('passive','registered') OR uy.yoklama_id IS NOT NULL) ORDER BY u.ad ASC";    
    return MySqlStmt::query(mysqlilink(),$sql,[$yoklama_id,$tarih]);
}

function uyetahakkuklist(int $uye_id) {
    $sql = "SELECT ut.uye_tahakkuk_id,CAST(ut.yil AS UNSIGNED) as yil, ut.ay, ut.tahakkuk_tarih,ut.borc, t.tanim, ut.tahakkuk_id,
    m.`tutar` as odeme_tutar,m.`tarih` as odeme_tarih, m.muhasebe_id, m.aciklama,m.kasa,
     y.tanim as yoklama, ut.yoklama_id,
     (SELECT 
     	GROUP_CONCAT(DISTINCT uy.tarih ORDER BY uy.tarih ASC SEPARATOR ',') 
     		FROM uye_yoklama uy
     			WHERE uy.uye_id = ut.uye_id AND MONTH(uy.tarih) = ut.ay AND YEAR(uy.tarih) = ut.yil AND uy.yoklama_id = ut.yoklama_id ) as keikolar
    FROM `uye_tahakkuk` ut 
    LEFT JOIN `tahakkuk` t ON t.`tahakkuk_id` = ut.`tahakkuk_id`
    LEFT JOIN `muhasebe` m ON m.`muhasebe_id` = ut.`muhasebe_id`
    LEFT JOIN yoklama y on y.yoklama_id = ut.yoklama_id 
	    WHERE ut.uye_id = ? ORDER BY tahakkuk_tarih DESC";
    return MySqlStmt::query(mysqlilink(),$sql,[$uye_id]);
}

function uyedigerodemelist(int $uye_id) {
    $sql = "SELECT m.muhasebe_id, m.tarih, m.kasa, mt.tanim, m.muhasebe_tanim_id, m.aciklama, m.tutar, m.belge
            FROM muhasebe m LEFT JOIN uye_tahakkuk ut ON ut.muhasebe_id = m.muhasebe_id
            INNER JOIN muhasebe_tanim mt ON mt.muhasebe_tanim_id = m.muhasebe_tanim_id AND mt.tur = 'GELIR' and mt.muhasebe_tanim_id <> 9
            WHERE m.uye_id = ? AND ut.uye_tahakkuk_id  IS NULL ORDER BY m.tarih DESC";    
    return MySqlStmt::query(mysqlilink(),$sql,[$uye_id]);
}

function uyeharcamalist(int $uye_id) {
    $sql = "SELECT m.muhasebe_id, m.tarih, m.kasa, mt.tanim, m.muhasebe_tanim_id, m.aciklama, m.tutar, m.belge 
            FROM muhasebe m LEFT JOIN uye_tahakkuk ut ON ut.muhasebe_id = m.muhasebe_id
            INNER JOIN muhasebe_tanim mt ON mt.muhasebe_tanim_id = m.muhasebe_tanim_id AND mt.tur = 'GIDER'
            WHERE m.uye_id = ? AND ut.uye_tahakkuk_id  IS NULL ORDER BY m.tarih DESC";    
    return MySqlStmt::query(mysqlilink(),$sql,[$uye_id]);
}

function aidat_odeme_al(int $uye_id, int $yoklama_id, string $tarih, int $yil, int $ay, string $kasa, float $tutar, string $aciklama, string $tahsilatci) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $result = $p->procedure("aidat_odeme_al")->in($uye_id)->in($yoklama_id)->in($tarih)->in($yil)->in($ay)->in($kasa)->in($tutar)->in($aciklama)->in($tahsilatci)->call()->result("queries");
    return intval($result[0][0]["muhasebe_id"]);
}

function aidat_odeme_sil(int $muhasebe_id) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $p->procedure("aidat_odeme_sil")->in($muhasebe_id)->call();
    return true;
}

function aidat_sil(int $uye_tahakkuk_id) {
    $sql = "DELETE FROM uye_tahakkuk WHERE uye_tahakkuk_id = ? AND muhasebe_id IS NULL";
    return MySqlStmt::query(mysqlilink(),$sql,[$uye_tahakkuk_id]);
}

function muhasebe_duzelt(int $muhasebe_id, int $uye_id, string $tarih, float $tutar, string $kasa, int $muhasebe_tanim_id,string $aciklama, $belge, string $tahsilatci) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    //muhasebe_id, uye_id, tarih,tutar,kasa, muhasebe_tanim_id bigint , in p_aciklama varchar(255), in p_tahsilatci varchar(80)
    $outs = $p->procedure("muhasebe_esd")
        ->out("muhasebe_id",$muhasebe_id > 0 ? $muhasebe_id : null )
        ->in($uye_id > 0 ? $uye_id : null )
        ->in($tarih)
        ->in($tutar)
        ->in($kasa)
        ->in($muhasebe_tanim_id)
        ->in($aciklama)
        ->in($belge)
        ->in($tahsilatci)        
        ->call()
        ->result("outs");
    return intval($outs["muhasebe_id"]);
}

function muhasebe_sil(int $muhasebe_id) {
    $sql = "DELETE FROM muhasebe WHERE muhasebe_id = ? AND muhasebe_tanim_id <> 9";
    return MySqlStmt::query(mysqlilink(),$sql,[$muhasebe_id]);
}

function kyu_oneri() {
    $sql = "SELECT q.ad,q.sinav,q.sayi FROM (SELECT u.uye_id, u.ad,u.dogum_tarih, us.seviye,
	CONCAT(CAST(LEFT(us.seviye,1) AS UNSIGNED) - 1,' KYU') as sinav,
	COUNT(1) as sayi FROM uye u 
	INNER JOIN uye_seviye us ON us.uye_id = u.uye_id
	LEFT JOIN uye_seviye us2 ON us2.uye_id = u.uye_id AND us2.tarih > us.tarih
	INNER JOIN seviye s ON s.seviye = us.seviye AND s.deger < 7
	INNER JOIN uye_yoklama uy ON uy.uye_id = u.uye_id AND uy.tarih >= DATE_ADD( DATE(NOW()), INTERVAL -3 MONTH ) 
		WHERE u.durum in ('active','admin','super-admin') and us2.uye_seviye_id IS NULL
			GROUP BY u.uye_id, u.ad, u.dogum_tarih, us.seviye HAVING sayi > 8 ORDER BY us.seviye DESC, u.dogum_tarih DESC) q";
    return MySqlStmt::query(mysqlilink(),$sql);
}

function rapor_gelirgider() {
    $sql = "SELECT YEAR(m.tarih) as _yil, MONTH(m.tarih) as _ay, SUM( IF(mt.tur = 'GELIR',m.tutar,0) ) as gelir,
    SUM( IF(mt.tur = 'GELIR' and m.muhasebe_tanim_id = 9,m.tutar,0) ) as aidat,
    SUM( IF(mt.tur = 'GIDER',m.tutar,0) ) as gider FROM muhasebe m
    inner join muhasebe_tanim mt on mt.muhasebe_tanim_id  = m.muhasebe_tanim_id
    GROUP BY _yil,_ay HAVING _yil >= YEAR(CURDATE()) - 10
    order by _yil asc, _ay asc";    
    return MySqlStmt::query(mysqlilink(),$sql);
}

function rapor_aylikyoklama(int $yoklama_id) {    
    $sql = "SELECT YEAR(q.tarih) as _yil, MONTH(q.tarih) as _ay, ROUND(avg(sayi),2) as ortalama, MAX(sayi) as ust, MIN(sayi) as alt, COUNT(*) as keiko
     from (
        SELECT count(*) as sayi,uy.tarih  from uye_yoklama uy where uy.yoklama_id = COALESCE(?,uy.yoklama_id) group by uy.tarih
        ) q GROUP BY _yil,_ay HAVING _yil >= YEAR(CURDATE()) - 10 order by _yil asc, _ay asc";
    $yid = $yoklama_id > 0 ? $yoklama_id : "NULL";
    return MySqlStmt::query(mysqlilink(),$sql,[$yid]);
}

function rapor_seviye() {
    $sql = "SELECT q.seviye,q.erkek_sayi, q.kadin_sayi,(q.erkek_sayi + q.kadin_sayi) as genel_sayi,
    IF(q.erkek_sayi > 0, ROUND(q.erkek_yas / q.erkek_sayi,2 ),0) as erkek_ort
    ,IF(q.kadin_sayi > 0, ROUND(q.kadin_yas / q.kadin_sayi,2 ),0) as kadin_ort
    ,IF(q.kadin_sayi + q.erkek_sayi > 0, ROUND( (q.kadin_yas + q.erkek_yas) / (q.kadin_sayi + q.erkek_sayi),2 ),0) as genel_ort
    FROM (		
    SELECT s.seviye,s.deger
    ,COALESCE(sum(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'ERKEK'),0) as erkek_sayi
    ,COALESCE(sum(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'KADIN'),0) as kadin_sayi
    ,COALESCE(sum(if(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'ERKEK', YEAR(FROM_DAYS(DATEDIFF(now(),u.dogum_tarih))),0 )),0) as erkek_yas
    ,COALESCE(sum(if(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'KADIN',YEAR(FROM_DAYS(DATEDIFF(now(),u.dogum_tarih))),0)),0) as kadin_yas
    FROM seviye s 
        left join uye_seviye us on s.seviye = us.seviye
        left join uye_seviye _us on _us.uye_id = us.uye_id and _us.tarih > us.tarih
        left join uye u on u.uye_id = us.uye_id
            WHERE s.deger >=5 and _us.uye_seviye_id is null group by s.seviye,s.deger
            UNION ALL
    SELECT 'Altı' as seviye, 0 as deger     
    ,COALESCE(sum(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'ERKEK'),0) as erkek_sayi
    ,COALESCE(sum(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'KADIN'),0) as kadin_sayi
    ,COALESCE(sum(if(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'ERKEK', YEAR(FROM_DAYS(DATEDIFF(now(),u.dogum_tarih))),0 )),0) as erkek_yas
    ,COALESCE(sum(if(u.durum in ('active','admin','super-admin') and u.cinsiyet = 'KADIN',YEAR(FROM_DAYS(DATEDIFF(now(),u.dogum_tarih))),0)),0) as kadin_yas
    FROM seviye s 
        left join uye_seviye us on s.seviye = us.seviye
        left join uye_seviye _us on _us.uye_id = us.uye_id and _us.tarih > us.tarih
        left join uye u on u.uye_id = us.uye_id
            WHERE s.deger < 5 and _us.uye_seviye_id is null GROUP by seviye order by deger desc ) q";
    return MySqlStmt::query(mysqlilink(),$sql);
}

function rapor_seviyebildirim() {
    $sql = "SELECT u.ad, u.ekfno, u.dogum_tarih, us.seviye, us.tarih, us.aciklama FROM uye u inner join uye_seviye us on us.uye_id = u.uye_id 
    left join uye_seviye _us on _us.uye_id = us.uye_id and _us.tarih > us.tarih 
    INNER join seviye s on s.seviye = us.seviye and s.deger >= 7
    where _us.uye_seviye_id is null and u.durum in ('active','admin','super-admin') order by s.deger desc, us.tarih asc, u.dogum_tarih asc";
    return MySqlStmt::query(mysqlilink(),$sql);
}

function rapor_gelirgider_detay(string $baslangic, string $bitis) {
    $sql = "SELECT 
    m.tarih,mt.tanim,mt.tur,u.ad,tutar,m.kasa,m.tahsilatci,m.aciklama
    FROM muhasebe m
    left JOIN muhasebe_tanim mt on mt.muhasebe_tanim_id  = m.muhasebe_tanim_id
    left join uye u on u.uye_id = m.uye_id 
    WHERE m.tarih between date(?) and date(?) ORDER BY m.tarih DESC";
    return MySqlStmt::query(mysqlilink(),$sql,[$baslangic,$bitis]);
}

function rapor_geneluyeraporu() {
    $sql = "SELECT u.uye_id,u.ad,u.email,u.cinsiyet,u.dogum_tarih,u.ekfno,u.durum,t.tanim as tahakkuk
    ,us.seviye, us.tarih as sinav_tarih,COALESCE(tah.borc,0) as borc_tutar,COALESCE(tah.sayi,0) borc_sayi,
    COALESCE(yok.sayi,0) as devam_sayi,yok.ilk,yok.son
    FROM uye u
    left join tahakkuk t on t.tahakkuk_id = u.tahakkuk_id 
    left join uye_seviye us on us.uye_id = u.uye_id 
    left join uye_seviye _us on _us.uye_id = us.uye_id and _us.tarih > us.tarih
    left join (select ut.uye_id,sum(borc) as borc, count(*) as sayi from uye_tahakkuk ut where ut.muhasebe_id is null group by ut.uye_id) tah on tah.uye_id = u.uye_id
    left join (select uy.uye_id,max(uy.tarih) son,min(uy.tarih) ilk, count(*) sayi from uye_yoklama uy group by uy.uye_id) yok on yok.uye_id = u.uye_id
    WHERE _us.uye_seviye_id is null and u.durum in ('active','admin','super-admin')";
    return MySqlStmt::query(mysqlilink(),$sql);
}

function tahsilatci_list(string $baslangic, string $bitis) {
    $sql = "SELECT DISTINCT tahsilatci FROM muhasebe WHERE tarih BETWEEN DATE(?) AND DATE(?) ORDER BY tahsilatci ASC";
    return MySqlStmt::query(mysqlilink(),$sql,[$baslangic, $bitis]);
}

function rapor_eldentahsilat(string $tahsilatci, string $baslangic, string $bitis) {
    $sql = "SELECT 
	u.ad,
	m.tarih,
	m.tutar,
	mt.tanim,	
	m.ay,
	m.yil,
    m.aciklama,
	coalesce(m.degisme,m.olusma) as zaman    
FROM muhasebe m
 inner join muhasebe_tanim mt on mt.muhasebe_tanim_id  = m.muhasebe_tanim_id 
 left join uye u on u.uye_id = m.uye_id 
WHERE (m.tarih BETWEEN DATE(?) AND DATE(?)) and kasa = 'Elden' and  COALESCE(m.tahsilatci,'-') = ?";
    return MySqlStmt::query(mysqlilink(),$sql,[$baslangic, $bitis, $tahsilatci]);
}

function yoklama10listesi(int $yoklama_id) {
    $sql = "SELECT uy.tarih, IF((SELECT COUNT(1) FROM uye_shiai us WHERE us.tur = 'TAKIM' AND us.tarih = uy.tarih AND us.yoklama_id = uy.yoklama_id)>0,1,0) AS macyaipmis
    FROM uye_yoklama uy WHERE uy.yoklama_id = ? GROUP BY uy.yoklama_id,uy.tarih ORDER BY uy.tarih DESC LIMIT 10";
    return MySqlStmt::query(mysqlilink(),$sql,[$yoklama_id]);
}

function maccalismasi_listesi(int $yoklama_id, string $tarih ) {
    $sql = "SELECT uy.uye_id,u.ad, us.seviye,us.tarih,u.cinsiyet,CAST(DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), u.dogum_tarih)), '%Y') AS UNSIGNED) AS yas
	FROM uye_yoklama uy
	INNER JOIN uye u ON u.uye_id = uy.uye_id
	INNER JOIN uye_seviye us ON us.uye_id = uy.uye_id
	LEFT JOIN uye_seviye _us ON _us.uye_id = us.uye_id AND _us.tarih > us.tarih 
		WHERE _us.uye_seviye_id IS NULL AND uy.yoklama_id = ? AND uy.tarih = ?";

    return MySqlStmt::query(mysqlilink(),$sql,[$yoklama_id, $tarih]);    
}

function maccalismasi_kayit(array $data) {    
    $sql = "INSERT INTO uye_shiai 
        (sira, yoklama_id, aka, shiro, tur, tarih, aka_ippon, shiro_ippon, aka_hansoku, shiro_hansoku)
        VALUES 
        (?, ?, ?, ?, ?, ?, ? , ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
        sira = VALUES(sira), aka_ippon = VALUES(aka_ippon), shiro_ippon = VALUES(shiro_ippon), aka_hansoku = VALUES(aka_hansoku), shiro_hansoku = VALUES(shiro_hansoku)";
    return MySqlStmt::repeatedQuery(mysqlilink(),$sql,$data);
}

function maccliasmasi_tumunusil(string $tarih, int $yoklama_id, string $tur) {
    $sql = "DELETE FROM uye_shiai WHERE tarih = ? AND yoklama_id = ? AND tur = ?";
    return MySqlStmt::query(mysqlilink(),$sql,[$tarih,$yoklama_id,$tur]);
}

function rapor_maccalismasi() {
    $sql = "SELECT q.uye_id,q.ad,q.cinsiyet,
    SUM(IF(q.sonuc = 'G',1,0)) AS galibiyet,
    SUM(IF(q.sonuc = 'M',1,0)) AS maglubiyet,
    SUM(IF(q.sonuc = 'B',1,0)) AS beraberlik,
    SUM(q.aldigi) AS alinansayi, 
    SUM(q.verdigi) AS verilensayi,
    COUNT(*) macsayisi,
    (SELECT count(*) FROM  uye_yoklama uy WHERE uy.uye_id  = q.uye_id AND uy.tarih >= DATE_ADD(CURRENT_DATE,INTERVAL -3 MONTH)) as son3Ay
    FROM (
    SELECT u.uye_id,u.ad,u.cinsiyet,
    COALESCE(IF(us.shiro = u.uye_id,LENGTH(us.shiro_ippon),LENGTH(us.aka_ippon)),0) as aldigi,
    COALESCE(IF(us.shiro <> u.uye_id,LENGTH(us.shiro_ippon),LENGTH(us.aka_ippon)),0) as verdigi,
    COALESCE(IF(us.shiro = u.uye_id,us.shiro_hansoku,us.aka_hansoku),0) AS hansoku,
    
    CASE 
        WHEN us.shiro = u.uye_id AND LENGTH(COALESCE(us.shiro_ippon,'')) > LENGTH(COALESCE(us.aka_ippon,'')) THEN 'G'
        WHEN us.shiro = u.uye_id AND LENGTH(COALESCE(us.shiro_ippon,'')) < LENGTH(COALESCE(us.aka_ippon,'')) THEN 'M'
        WHEN us.aka = u.uye_id AND LENGTH(COALESCE(us.shiro_ippon,'')) < LENGTH(COALESCE(us.aka_ippon,'')) THEN 'G'
        WHEN us.aka = u.uye_id AND LENGTH(COALESCE(us.shiro_ippon,'')) > LENGTH(COALESCE(us.aka_ippon,'')) THEN 'M'
        ELSE 'B'
    END as sonuc
    
    FROM uye u
    inner JOIN uye_shiai us ON (us.aka = u.uye_id OR us.shiro = u.uye_id) AND us.tarih >=DATE_ADD(CURRENT_DATE,INTERVAL -3 MONTH)
    WHERE u.durum IN ('active','admin','super-admin') ) q GROUP BY q.uye_id, q.ad, q.cinsiyet
    ORDER BY cinsiyet,galibiyet DESC,maglubiyet ASC, macsayisi DESC, son3Ay DESC, alinansayi DESC, verilensayi ASC, hansokuort ASC";

    return MySqlStmt::query(mysqlilink(),$sql);
}

function maccalismasi_kisibazli(int $uye_id) {
    $sql = "SELECT 
	k.ad as aka,
	b.ad as shiro,
	us.tarih,
	us.tur,
	us.aka_ippon,
	us.shiro_ippon,
	us.aka_hansoku,
	us.shiro_hansoku,
	CASE 
		WHEN us.aka = ? AND COALESCE(LENGTH(us.aka_ippon),0) > COALESCE(LENGTH(us.shiro_ippon),0) THEN 'G'
		WHEN us.aka = ? AND COALESCE(LENGTH(us.aka_ippon),0) < COALESCE(LENGTH(us.shiro_ippon),0) THEN 'M'
		WHEN us.shiro = ? AND COALESCE(LENGTH(us.aka_ippon),0) < COALESCE(LENGTH(us.shiro_ippon),0) THEN 'G'
		WHEN us.shiro = ? AND COALESCE(LENGTH(us.aka_ippon),0) > COALESCE(LENGTH(us.shiro_ippon),0) THEN 'M'
		ELSE 'B'
	END AS sonuc
FROM uye_shiai us
inner join uye k on k.uye_id = us.aka
INNER join uye b on b.uye_id = us.shiro 
WHERE us.tarih >=DATE_ADD(CURRENT_DATE,INTERVAL -3 MONTH) 
AND ( us.aka = ? OR us.shiro = ? ) ORDER BY tarih DESC";
    return MySqlStmt::query(mysqlilink(),$sql,[$uye_id,$uye_id,$uye_id,$uye_id,$uye_id,$uye_id]);

}

