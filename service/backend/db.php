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
    $err = "";
    $resultarr = [];
    $mysqli = mysqlilink();
    $result_tahakkuk = mysqli_query($mysqli,"SELECT tahakkuk_id,tanim,tutar FROM tahakkuk");
    if($result_tahakkuk) {
        $arr = [];
        while( $row = mysqli_fetch_assoc($result_tahakkuk) ) {
            array_push($arr,$row);
        }
        $resultarr["tahakkuklar"] = $arr;
    } else {
        $err = mysqli_error($mysqli);
    }
    if ($err) {
        throw new Exception($err);
    } else {
        return $resultarr;
    }
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

function uye_yoklama(int $yoklama_id, int $uye_id, string $tarih) {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    return $p->procedure("uye_yoklama")->in($yoklama_id)->in($uye_id)->in($tarih)->call()->result("queries");
}