<?php
if (PHP_SAPI != 'cli') {
    die("Works only CLI mode");
}
require_once __DIR__ . "/vendor/autoload.php";
require_once __DIR__ . "/lib/MongoTools/Tools.php";
require_once "./uyequery.php";

function mysqlconn(string $cs): mysqli {
    $arr = explode('|', $cs);
    $c = mysqli_connect(
        (isset($arr[0]) && trim($arr[0]) ? trim($arr[0]) : "localhost"),
        (isset($arr[1]) && trim($arr[1]) ? trim($arr[1]) : "root"),
        (isset($arr[2]) && trim($arr[2]) ? trim($arr[2]) : ""),
        (isset($arr[3]) && trim($arr[3]) ? trim($arr[3]) : ""),
        (isset($arr[4]) && trim($arr[4]) ? trim($arr[4]) : 3306)
    );
    if ($c) {
        mysqli_report(MYSQLI_REPORT_STRICT);
        return $c;
    } else {
        throw new Exception("Mysql Connection error");
    }
}
function mongoconn(string $cs): \MongoDB\Client {
    return new \MongoDB\Client($cs);
}

function uye_ve_baglantililar(string $myconstr,string $mongoconstr): void {

    function getSqlVals(array $varr) : string {
        $res = "";
        for($i=0; $i<count($varr); $i++) {
            $v = $varr[$i];
            if ($i> 0) {
                $res.=",";
            }
            if (is_null($v) || (is_string($v) && empty(trim($v))) ) {
                $res .= "NULL";
            } elseif (is_string($v)) {
                $res.="'$v'";
            } else {
                $res.=$v;
            }
        }
        return $res;
    }

    $mongo = mongoconn($mongoconstr);
    $mysql = mysqlconn($myconstr);

    //$cursor = $mongo->selectDatabase("dojo")->selectCollection("uye")->find([],["limit"=>1]);
    $cursor = $mongo->selectDatabase("dojo")->selectCollection("uye")->aggregate( uyequery() );

    $bucket = $mongo->selectDatabase("dojo")->selectGridFSBucket([
        "bucketName" => "dosya"
    ]);

    mysqli_query($mysql,"TRUNCATE TABLE uye");
    mysqli_query($mysql,"TRUNCATE TABLE dosya");
    mysqli_query($mysql,"TRUNCATE TABLE uye_seviye");
    mysqli_query($mysql,"TRUNCATE TABLE uye_yoklama");
    mysqli_query($mysql,"TRUNCATE TABLE uye_tahakkuk");
    
    $hatali = [];
    $it = new \IteratorIterator($cursor);    
    $it->rewind();    
    while ($doc = $it->current()) {
        $ad = $doc["ad"];
        $tahakkuk_id = ($doc["ogrenci"] ? 2 : 1);
        $email = $doc["email"];
        $cinsiyet = $doc["cinsiyet"];
        $dogum_tarih = ($doc["dogum"] ? $doc["dogum"]->toDateTime()->format('Y-m-d'):null);
        $email_activation = $doc["email_activation"];

        $active = ($doc["active"] ? 1 : 0);
        $ekfno = $doc["ekfno"];

        $durum = ( $active ? ( $email_activation ? "active" : "pending") : "passive");
        $seviyeler = [];
        if ($doc["sinavlar"] instanceof ArrayObject) {
            $doc["sinavlar"]->uasort(function ($a,$b){
                if ($a["tarih"] < $b["tarih"]) {
                    return 1;
                } else {
                    return -1;
                }
            });
            if ($doc["sinavlar"]->count()>0) {
                foreach($doc["sinavlar"] as $sinav) {
                    array_push($seviyeler,[
                        "uye_id" => null,
                        "tarih"=> ($sinav["tarih"] ? $sinav["tarih"]->toDateTime()->format('Y-m-d'):null),
                        "aciklama" => $sinav["aciklama"],
                        "seviye" => strtoupper($sinav["seviye"])
                    ]);
                }
            } else {
                array_push($seviyeler,[
                    "uye_id" => null,
                    "tarih"=> date("Y-m-d"),
                    "aciklama" => "Aktarim",
                    "seviye" => "7 KYU"
                ]);
            }
        }
        $seviye = $seviyeler[0]["seviye"];
        $dosya_id = 0;
        $err = "";
        mysqli_begin_transaction($mysql);
        if (trim($doc["img"])) {
            $foto = null;
            $foto_type = "";
            $id = new \MongoDB\BSON\ObjectId(trim($doc["img"]));
            $result = $bucket->findOne(["_id" => $id]);
            if ( !is_null($result) ) {
                $stream = fopen('php://temp', 'w+b');
                $bucket->downloadToStream($id, $stream);
                $foto = base64_encode(stream_get_contents($stream, -1, 0));
                $foto_type = $result->metadata->file_type;
                $stmtdosya = mysqli_prepare($mysql,"INSERT INTO dosya (icerik, file_type) VALUES (?,?)");
                mysqli_stmt_bind_param($stmtdosya,"ss",$foto,$foto_type);
                if ( mysqli_stmt_execute($stmtdosya) ) {
                    $dosya_id = mysqli_insert_id($mysql);
                } else {
                    $err = "dosya: ".mysqli_stmt_error($stmtdosya);
                }
                mysqli_stmt_close($stmtdosya);
                fclose($stream);
            } else {
                $err = "Uye resmi bulunamadi";
            }
        } else {
            $err = "Uye resmi kaydedilmemis";
        }
        $data = [
            "eski_id"=>$doc["_id"]->__toString(),
            "durum"=>$durum,
            "ad"=>$ad,
            "tahakkuk_id"=>$tahakkuk_id,
            "email" => $email,
            "cinsiyet" => $cinsiyet,
            "dogum_tarih" => $dogum_tarih,
            "seviye" => $seviye,
            "dosya_id" => $dosya_id,
            "seviyeler" => $seviyeler
        ];
        if (!$err) {
            if ($cinsiyet && $email && $dogum_tarih && $dosya_id) {
                //echo "$durum $ad $tahakkuk_id $email $cinsiyet $dogum_tarih $seviye".PHP_EOL;
                $stmt = mysqli_prepare($mysql,"INSERT INTO uye (durum, ad, tahakkuk_id, email, cinsiyet, dogum_tarih, seviye, dosya_id, ekfno, parola) VALUES (?,?,?,?,?,?,?,?,?,parola_uret(6))");
                mysqli_stmt_bind_param($stmt,"ssissssis",$durum,$ad,$tahakkuk_id,$email,$cinsiyet,$dogum_tarih,$seviye,$dosya_id,$ekfno);
                if (mysqli_stmt_execute($stmt)) {
                    $uye_id = mysqli_insert_id($mysql);            
                    $stmtdosya = mysqli_prepare($mysql,"UPDATE dosya SET tablo = 'UYE', tablo_id=? WHERE dosya_id = ?");
                    mysqli_stmt_bind_param($stmtdosya,"ii",$uye_id,$dosya_id);
                    if (mysqli_stmt_execute($stmtdosya) ) {

                        if (count($seviyeler)>0) {
                            $inssql = "INSERT INTO uye_seviye (tarih, aciklama, uye_id, seviye) VALUES ";
                            for ($i=0; $i<count($seviyeler); $i++) {
                                if ($i>0) {
                                    $inssql.=",";
                                }
                                $inssql.="(".getSqlVals([$seviyeler[$i]["tarih"],$seviyeler[$i]["aciklama"],$uye_id,$seviyeler[$i]["seviye"]]).")";
                            }
                            if (!mysqli_query($mysql,$inssql)) {
                                $err = "uye_seviye-ins: ".mysqli_error($mysql) . " / ".$inssql;
                            }
                        }

                        if (!$err && $doc["keikolar"] instanceof ArrayObject && $doc["keikolar"]->count() > 0 ) { //keikolar
                            $inssql = "INSERT INTO uye_yoklama (uye_id, yoklama_id, tarih) VALUES ";
                            for($i = 0; $i< $doc["keikolar"]->count(); $i++) {
                                $mt = $doc["keikolar"][$i];
                                $yt = $mt->toDateTime()->format("Y-m-d");
                                if ($i>0) {
                                    $inssql.=",";
                                }
                                $inssql.="(".getSqlVals([$uye_id, 1, $yt]).")";
                            }
                            if (mysqli_query($mysql,$inssql)) {
                                if ($doc["aidateksigi"] instanceof ArrayObject && $doc["aidateksigi"]->count()>0) { // aidat eksikleri
                                    $inssql = "INSERT INTO uye_tahakkuk (uye_id, tahakkuk_id, borc, tahakkuk_tarih, yil, ay,yoklama_id) VALUES ";
                                    for($i = 0; $i< $doc["aidateksigi"]->count(); $i++) {
                                        $tt = $doc["aidateksigi"][$i]."-01";
                                        $yilayarr = explode("-",$doc["aidateksigi"][$i]);
                                        $yil = intval($yilayarr[0]);
                                        $ay = intval($yilayarr[1]);
                                        $borc = ($tahakkuk_id == 1 ? 250 : 200);
                                        if ($i>0) {
                                            $inssql.=",";
                                        }
                                        $inssql.="(".getSqlVals([$uye_id, $tahakkuk_id, $borc,$tt,$yil, $ay,1]).")";
                                    }
                                    if (!mysqli_query($mysql,$inssql)) {
                                        $err = "uye_tahakkuk-ins: ".mysqli_error($mysql) . " / ".$inssql;
                                    }
                                }
                            } else {
                                $err = "uye_yoklama-ins: ".mysqli_error($mysql);
                            }
                        }                        
                        if ( !$err && $doc["gelirgider"] instanceof ArrayObject && $doc["gelirgider"]->count() > 0 ) { //Muhasebe gelirgider
                            $inssql = "INSERT INTO muhasebe (uye_id, tarih, tutar, kasa, aciklama, tanim, tahsilatci) VALUES ";
                            for ($i=0; $i< $doc["gelirgider"]->count(); $i++ ) {
                                $tar = $doc["gelirgider"][$i]["tarih"]->toDateTime()->format("Y-m-d");
                                $tutar = $doc["gelirgider"][$i]["tutar"];
                                $kasa = $doc["gelirgider"][$i]["kasa"];
                                $aciklama =str_replace(["\n","'"]," ",$doc["gelirgider"][$i]["aciklama"]);
                                $tanim = $doc["gelirgider"][$i]["tanim"];
                                $tahsilatci = $doc["gelirgider"][$i]["user_text"];
                                if ($i>0) {
                                    $inssql.=",";
                                }
                                
                                $inssql.="(".getSqlVals([$uye_id, $tar, $tutar,$kasa,$aciklama, $tanim, $tahsilatci]).")";
                            }

                            if (!mysqli_query($mysql,$inssql)) {
                                $err = "muhasabe-ins: ".mysqli_error($mysql) . " / ".$inssql;
                            }
                        }
                    } else {
                        $err = "dosya-update: ".mysqli_stmt_error($stmtdosya);
                    }
                    mysqli_stmt_close($stmtdosya);
                } else {
                    $err = "uye: ".mysqli_stmt_error($stmt);
                }
                mysqli_stmt_close($stmt);
            } else {
                $err = "veri eksikligi > ($cinsiyet | $email | $dogum_tarih | $dosya_id)";
            }
        }
        

        if (!$err) {

            mysqli_commit($mysql);
        } else {
            echo "$ad($active) => $err".PHP_EOL;
            array_push($hatali,[
                "error"=>$err,
                "data" => $data
            ]);
            mysqli_rollback($mysql);
        }
        
        $it->next();
    }
    mysqli_close($mysql);
    //var_dump($hatali);
}

try {
    $dotenv = Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env");
    $dotenv->load();
} catch (\Exception $ex) {
    die("Config File can't read");
}

uye_ve_baglantililar($_ENV["MYSQL_CONNECTION_STRING"],$_ENV["MONGO_CONNECTION_STRING"]);
