<?php

require_once "./lib/MySqlTool/MySqlToolCall.php";

function mysqlilink(): mysqli {
    $arr = explode('|', $_ENV["MYSQL_CONNECTION_STRING"]);
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

function create_identity(string $username,&$ad,&$code) : void {    
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $outs = $p->procedure("uye_kimlik_olustur")->out("code")->out("ad")->in($username)->call()->result("outs");
    $ad = $outs["ad"];
    $code = $outs["code"];
}

function reset_password(string $code, string $password) : void {
    $p = new \MySqlTool\MySqlToolCall(mysqlilink());
    $p->procedure("uye_kimlik_degistir")->in($code)->in($password)->call();
}

function validate(string $username, string $password) {
    $uye_id = $ad = $durum = $dosya_id = $err = "";
    $sql = "SELECT ad,durum,uye_id,dosya_id FROM uye
                WHERE durum IN ('active','admin','super-admin')
                    email = ? AND parola = IF(LENGTH(parola)<=6,?, UPPER(SHA1(TRIM(?))) )";
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
            $sql = "UPDATE uye SET parola = UPPER(SHA1(?)) WHERE parola =  IF(LENGTH(parola)<=6,?, UPPER(SHA1(?)) ) AND uye_id = ?";
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
