<?php

require_once "./lib/MySqlTool/MySqlToolCall.php";

function mysqlilink(): mysqli {
    $arr = explode('|', $_ENV["MYSQL_CONNECTION_STRING"]);
    $c = @mysqli_connect(
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
        throw new Exception("DB Error  / ".mysqli_connect_error());
    }
}

function resultToArray(mysqli_result $result): array {
    $arr = [];
    while($row=mysqli_fetch_assoc($result)) {
        array_push($arr,$row);
    }
    return $arr;
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
    $uye_id = $ad = $durum = $dosya_id = $err = "";
    $list = "'active','admin','super-admin'";
    if ($type == "admin") {
        $list = "'admin','super-admin'";
    }
    //throw new Exception($list." - ".$type);
    $sql = "SELECT ad,durum,uye_id,dosya_id FROM uye
                WHERE durum IN ($list) AND
                    email = ? AND parola = IF(LENGTH(parola)<=6,?, MD5(?) )";
    $mysqli = mysqlilink();
    $stmt = mysqli_prepare($mysqli, $sql);
    if ($stmt) {
        if (mysqli_stmt_bind_param($stmt, "sss", $username, $password, $password)) {
            if (mysqli_stmt_execute($stmt)) {
                mysqli_stmt_bind_result($stmt, $ad, $durum, $uye_id,$dosya_id);
                mysqli_stmt_fetch($stmt);
            } else {
                $err = mysqli_stmt_error($stmt);
            }
        } else {
            $err = "Bind param / " . mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        $err = "STMT / " . mysqli_error($mysqli);
    }
    mysqli_close($mysqli);
    if (!$err) {
        if ($uye_id) {
            return [
                "uye_id" => intval($uye_id),
                "dosya_id" => intval($dosya_id),
                "ad" => $ad,
                "durum" => $durum,
                "email" => $username
            ];
        } else {
            return null;
        }
    } else {
        throw new Exception($err);
    }
}

function uye(int $uye_id) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    return $p->procedure("uye_bilgi")->in($uye_id)->call()->result("queries");
}

function uye_listele(string $durumlar) : array {
    $err = "";
    $list = [];
    
    $sql = "SELECT u.uye_id,u.ad,u.dosya_id,(SELECT seviye FROM uye_seviye WHERE uye_id = u.uye_id ORDER BY tarih DESC LIMIT 1) as seviye
    ,SUM(IF(ut.uye_tahakkuk_id is NULL,0,1)) as odenmemis_aidat_syisi,
    SUM( COALESCE(ut.borc,0) ) as odenmemis_aidat_borcu,
    (SELECT uy.tarih FROM uye_yoklama uy WHERE uy.uye_id = u.uye_id ORDER BY uy.tarih DESC LIMIT 1 ) AS son_keiko,
    (SELECT count(*) FROM  uye_yoklama uy WHERE uy.uye_id  = u.uye_id AND uy.tarih >= DATE_ADD(CURRENT_DATE,INTERVAL -3 MONTH)) as son3Ay,
    d.icerik as image , d.file_type as image_type
    FROM uye u
    LEFT JOIN uye_tahakkuk ut ON ut.uye_id = u.uye_id and ut.muhasebe_id  is null
    LEFT JOIN dosya d ON d.dosya_id  = u.dosya_id
    WHERE FIND_IN_SET(u.durum,?)
    GROUP BY u.uye_id,u.ad,u.cinsiyet,u.dosya_id,u.durum,u.ekfno,u.email,seviye";
    
    $mysqli = mysqlilink();
    $stmt = mysqli_prepare($mysqli, $sql);
    if ($stmt) {
        //var_dump([$durumlar,$tahakkuk_id]);
        if (mysqli_stmt_bind_param($stmt, "s", $durumlar)) {
            if (mysqli_stmt_execute($stmt)) {
                mysqli_stmt_bind_result($stmt, $uye_id,$ad,$dosya_id,$seviye,$odenmemis_aidat_syisi,$odenmemis_aidat_borcu,$son_keiko,$son3Ay,$image,$image_type);
                while (mysqli_stmt_fetch($stmt)) {
                    array_push($list,(object)[
                        "uye_id"=> $uye_id,
                        "ad" => $ad,                    
                        "dosya_id" => $dosya_id,                
                        "seviye" => $seviye,
                        "odenmemis_aidat_syisi" => $odenmemis_aidat_syisi,
                        "odenmemis_aidat_borcu" => $odenmemis_aidat_borcu,
                        "son_keiko" => $son_keiko,
                        "son3Ay" => intval($son3Ay),
                        "image" => $image,
                        "image_type" => $image_type
                    ]);
                }
            } else {
                $err = mysqli_stmt_error($stmt);
            }
            //var_dump($list);
        } else {
            $err = mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        $err = mysqli_error($mysqli);
    }    
    mysqli_close($mysqli);
    if ($err) {
        throw new Exception($err);
    }
    return $list;
}

function sabitler() {
    $mysqli = mysqlilink();
    mysqli_multi_query($mysqli,
        "SELECT tahakkuk_id,tanim,tutar FROM tahakkuk;
        SELECT yoklama_id,tanim FROM yoklama;
        SELECT muhasebe_tanim_id,tanim,tur FROM muhasebe_tanim
        ",
        

    );

    $result_tahakkuklar = mysqli_store_result($mysqli);
    mysqli_next_result($mysqli);
    $result_yoklamalar = mysqli_store_result($mysqli);
    mysqli_next_result($mysqli);
    $result_muhasebe_tanim = mysqli_store_result($mysqli);

    $data = [
        "tahakkuklar"=>resultToArray($result_tahakkuklar),
        "yoklamalar" =>resultToArray($result_yoklamalar),
        "muhasebe_tanimlar" => resultToArray($result_muhasebe_tanim)
    ];
    mysqli_free_result($result_tahakkuklar);
    mysqli_free_result($result_yoklamalar);
    mysqli_close($mysqli);
    

    return $data;
}

function download(int $dosya_id) {
    $err = $icerik = $file_type = "";
    $sql = "SELECT icerik,file_type FROM dosya WHERE dosya_id = ?";
    $mysqli = mysqlilink();
    $stmt = mysqli_prepare($mysqli, $sql);
    if ($stmt) {
        if (mysqli_stmt_bind_param($stmt, "i", $dosya_id)) {
            if (mysqli_stmt_execute($stmt)) {
                mysqli_stmt_bind_result($stmt, $icerik, $file_type);
                mysqli_stmt_fetch($stmt);
            } else {
                $err = mysqli_stmt_error($stmt);
            }
        } else {
            $err = mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);
    if (!$err) {
        if ($icerik && $file_type) {
            //icerik zaten base64
            //return "data:$file_type;base64," . $icerik;
            return [
                "type" => $file_type,
                "content" => $icerik
            ];
        } else {
            return "";
        }
    } else {
        throw new Exception($err);
    }
}

function upload($icerik, $file_type): int {
    $err = "";
    $dosya_id = 0;
    $sql = "INSERT INTO dosya (icerik, file_type) VALUES (?,?)";
    $mysqli = mysqlilink();
    $stmt = mysqli_prepare($mysqli, $sql);
    if ($stmt) {
        if (mysqli_stmt_bind_param($stmt, "ss", $icerik, $file_type)) {
            if (mysqli_stmt_execute($stmt)) {
                $dosya_id = mysqli_stmt_insert_id($stmt);
            } else {
                $err = mysqli_stmt_error($stmt);
            }
        } else {
            $err = mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);
    if (!$err) {
        return $dosya_id;
    } else {
        throw new Exception($err);
    }
}

function password(int $uye_id, string $old, string $new, &$err): bool {
    $err = "";
    $pn = trim($new);
    $po = trim($old);
    if (strlen($pn) >= 6) {
        if ($pn != $po) {
            $mysqli = mysqlilink();
            $sql = "UPDATE uye SET parola = MD5(?) WHERE parola =  IF(LENGTH(parola)<=6,?, MD5(?) ) AND uye_id = ?";
            $stmt = mysqli_prepare($mysqli, $sql);
            if ($stmt) {
                if (mysqli_stmt_bind_param($stmt, "sssi", $pn, $po, $po, $uye_id)) {
                    if (mysqli_stmt_execute($stmt)) {
                        if (!mysqli_stmt_affected_rows($stmt)) {
                            $err = "Old password doesn't match with given";
                        }
                    } else {
                        $err = mysqli_stmt_error($stmt);
                    }
                } else {
                    $err = mysqli_stmt_error($stmt);
                }
                mysqli_stmt_close($stmt);
            } else {
                $err = mysqli_error($mysqli);
            }
            mysqli_close($mysqli);
        } else {
            $err = "New password can't be same with old one";
        }
    } else {
        $err = "Password must be at least 6 characters";
    }
    return (!$err ? true : false);
}

function seviye_ekle($uye_id,string $seviye, string $tarih, string $aciklama,&$err) : bool {
    $err = "";
    $mysqli = mysqlilink();
    $sql = "INSERT INTO uye_seviye ( uye_id,tarih,aciklama, seviye ) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE tarih = VALUES(tarih), aciklama = VALUES(aciklama)";
    $stmt = mysqli_prepare($mysqli, $sql);
    if ($stmt) {
        if (mysqli_stmt_bind_param($stmt, "isss", $uye_id,$tarih,$aciklama,$seviye)) {
            if (!mysqli_stmt_execute($stmt)) {
                $err = mysqli_stmt_error($stmt);    
            }
        } else {
            $err = mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);
    return !$err;
}

function seviye_sil($uye_id,string $seviye,&$err) : bool {
    $err = "";
    $mysqli = mysqlilink();
    $sql = "DELETE FROM uye_seviye WHERE uye_id = ? AND seviye = ?";    
    $stmt = mysqli_prepare($mysqli, $sql);
    if ($stmt) {
        if (mysqli_stmt_bind_param($stmt, "is", $uye_id,$seviye)) {
            if (!mysqli_stmt_execute($stmt)) {
                $err = mysqli_stmt_error($stmt);    
            }
        } else {
            $err = mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);
    return !$err;
}

function uye_eke($uye_id,$ad,$tahakkuk_id,$email,$cinsiyet,$dogum,$ekfno,$durum,$dosya,$file_type) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $outs = $p->procedure("uye_ekle")->out("uye_id",$uye_id)->out("parola")->in($tahakkuk_id)
    ->in($ad)->in($email)->in($dosya)->in($file_type)->in($cinsiyet)->in($dogum)->in($ekfno)->in($durum)->call()->result("outs");
    return $outs["uye_id"];
}

function uye_eposta_onkayit(int $uye_id,string &$ad,string &$email,string &$code,string &$err):bool {
    $err = "";
    $mysqli = mysqlilink();
    $sql = "SELECT ad,email FROM uye WHERE uye_id = $uye_id";
    $result = mysqli_query($mysqli,$sql);
    if ($result) {
        $row = mysqli_fetch_assoc($result);
        if ($row) {
            $code = uniqid(date('ymdHis'));
            $email = $row["email"];
            $ad = $row["ad"];
            $sql = "INSERT INTO uye_kimlik_degisim (uye_id,anahtar,email) VALUES ($uye_id,'$code','$email') ON DUPLICATE KEY UPDATE anahtar = VALUES(anahtar), email = values(email)";
            if ( !mysqli_query($mysqli,$sql) ) {
                echo $sql.PHP_EOL;
                $err = mysqli_error($mysqli);
                
            }
        } else {
            $err = mysqli_error($mysqli);
        }
    } else {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);
    return empty($err);
}

function uye_eposta_onay(string $code,&$err) : bool {
    $err = "";
    $mysqli = mysqlilink();
    $sql = "SELECT uye_id FROM uye_kimlik_degisim WHERE anahtar = ? AND TIME_TO_SEC(TIMEDIFF(NOW(), COALESCE(olusma,degisme))) <= 86400";
    $stmt = mysqli_prepare($mysqli, $sql);
    if ($stmt) {
        if (mysqli_stmt_bind_param($stmt, "s", $code)) {
            if (mysqli_stmt_execute($stmt)) {
                mysqli_stmt_bind_result($stmt,$uye_id);
                if (mysqli_stmt_fetch($stmt)) {
                    $mysqli2 = mysqlilink();
                    $sqlupdate = "UPDATE uye SET durum = 'active' WHERE durum = 'registered' AND uye_id = $uye_id";
                    if ( !mysqli_query($mysqli2,$sqlupdate) ) {
                        $err = mysqli_error($mysqli);
                    }
                    mysqli_close($mysqli2);
                } else {
                    $err = "Kayit bulunamadi";
                }
            } else {
                $err = mysqli_stmt_error($stmt);    
            }
        } else {
            $err = mysqli_stmt_error($stmt);
        }    
        mysqli_stmt_close($stmt);
    } else {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);
    return empty($err);
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
    $mysqli = mysqlilink();
    $result = mysqli_query($mysqli,$sql);
    $arr = [];
    if ( $result ) {
        $arr = resultToArray($result);
        mysqli_free_result($result);
        mysqli_close($mysqli);
    } else {
        $err = mysqli_error($mysqli);
        mysqli_close($mysqli);
        throw new Exception($err);
    }
    
    return $arr;
}

function yoklamaliste(int $yoklama_id, string $tarih) {
    $sql = "SELECT u.uye_id,u.ad,d.icerik,d.file_type,IF(uy.yoklama_id IS NOT NULL,1,0) as katilim FROM uye u 
    LEFT JOIN dosya d ON u.dosya_id = d.dosya_id
    LEFT JOIN uye_yoklama uy ON uy.uye_id = u.uye_id and uy.yoklama_id = ? AND uy.tarih = ? 
    WHERE (u.durum NOT IN ('passive','registered') OR uy.yoklama_id IS NOT NULL) ORDER BY u.ad ASC";
    $err = "";
    $mysqli = mysqlilink();
    $stmt = mysqli_prepare($mysqli, $sql);
    $list = [];
    if ($stmt) {
        //echo "$yoklama_id,$tarih";
        if (mysqli_stmt_bind_param($stmt, "is", $yoklama_id,$tarih)) {
            if (mysqli_stmt_execute($stmt)) {
                mysqli_stmt_bind_result($stmt,$uye_id,$ad,$icerik,$file_type,$katilim);
                while ( mysqli_stmt_fetch($stmt) ) {
                    array_push($list,[
                        "uye_id" => $uye_id,
                        "ad" => $ad,
                        "image" => $icerik,
                        "file_type" => $file_type,
                        "katilim" => $katilim
                    ]);
                }
            } else {
                $err = mysqli_stmt_error($stmt);    
            }
        } else {
            $err = mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        $err = mysqli_error($mysqli);
    }    
    mysqli_close($mysqli);
    if (!empty($err)) {
        throw new Exception($err);
    }
    return $list;
}

function uyetahakkuklist(int $uye_id) {
    $sql = "SELECT ut.uye_tahakkuk_id,ut.yil, ut.ay, ut.tahakkuk_tarih,ut.borc, t.tanim, ut.tahakkuk_id,
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
	    WHERE ut.`uye_id` = $uye_id ORDER BY tahakkuk_tarih DESC";
    $err = "";
    $mysqli = mysqlilink();
    $result = mysqli_query($mysqli,$sql);
    if ($result) {
        $arr = resultToArray($result);
        mysqli_free_result($result);
        mysqli_close($mysqli);
        return $arr;
    } else {
        $err = mysqli_error($mysqli);
        mysqli_close($mysqli);
        throw new Exception($err);
    }
}

function uyedigerodemelist(int $uye_id) {
    $sql = "SELECT m.muhasebe_id, m.tarih, m.kasa, mt.tanim, m.muhasebe_tanim_id, m.aciklama, m.tutar 
            FROM muhasebe m LEFT JOIN uye_tahakkuk ut ON ut.muhasebe_id = m.muhasebe_id
            INNER JOIN muhasebe_tanim mt ON mt.muhasebe_tanim_id = m.muhasebe_tanim_id AND mt.tur = 'GELIR' and mt.muhasebe_tanim_id <> 9
            WHERE m.uye_id = $uye_id AND ut.uye_tahakkuk_id  IS NULL ORDER BY m.tarih DESC";
    $err = "";
    $mysqli = mysqlilink();
    $result = mysqli_query($mysqli,$sql);
    if ($result) {
        $arr = resultToArray($result);
        mysqli_free_result($result);
        mysqli_close($mysqli);
        return $arr;
    } else {
        $err = mysqli_error($mysqli);
        mysqli_close($mysqli);
        throw new Exception($err);
    }
}

function uyeharcamalist(int $uye_id) {
    $sql = "SELECT m.muhasebe_id, m.tarih, m.kasa, mt.tanim, m.muhasebe_tanim_id, m.aciklama, m.tutar 
            FROM muhasebe m LEFT JOIN uye_tahakkuk ut ON ut.muhasebe_id = m.muhasebe_id
            INNER JOIN muhasebe_tanim mt ON mt.muhasebe_tanim_id = m.muhasebe_tanim_id AND mt.tur = 'GIDER'
            WHERE m.uye_id = $uye_id AND ut.uye_tahakkuk_id  IS NULL ORDER BY m.tarih DESC";
    $err = "";
    $mysqli = mysqlilink();
    $result = mysqli_query($mysqli,$sql);
    if ($result) {
        $arr = resultToArray($result);
        mysqli_free_result($result);
        mysqli_close($mysqli);
        return $arr;
    } else {
        $err = mysqli_error($mysqli);
        mysqli_close($mysqli);
        throw new Exception($err);
    }
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
    $sql = "DELETE FROM uye_tahakkuk WHERE uye_tahakkuk_id = $uye_tahakkuk_id AND muhasebe_id IS NULL";
    $err = "";
    $mysqli = mysqlilink();
    if ( !mysqli_query($mysqli,$sql) ) {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);

    if (!empty($err)) {
        throw new Exception($err);
    }
}

function muhasebe_duzelt(int $muhasebe_id, int $uye_id, string $tarih, float $tutar, string $kasa, int $muhasebe_tanim_id,string $aciklama, string $tahsilatci) {
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
        ->in($tahsilatci)
        ->call()
        ->result("outs");
    return intval($outs["muhasebe_id"]);
}

function muhasebe_sil(int $muhasebe_id) {
    $sql = "DELETE FROM muhasebe WHERE muhasebe_id = $muhasebe_id AND muhasebe_tanim_id <> 9";

    $err = "";
    $mysqli = mysqlilink();
    if ( !mysqli_query($mysqli,$sql) ) {
        $err = mysqli_error($mysqli);
    }
    mysqli_close($mysqli);

    if (!empty($err)) {
        throw new Exception($err);
    }
}