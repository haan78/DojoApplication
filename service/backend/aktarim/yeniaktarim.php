<?php
if (PHP_SAPI != 'cli') {
  die("Works only CLI mode");
}
define("CONNS", "mongodb://root:dQu98KNmtF9@localhost");

define("QUERY", array (
  0 => 
  array (
    '$addFields' => 
    array (
      'keikoaylar' => 
      array (
        '$setUnion' => 
        array (
          '$map' => 
          array (
            'input' => '$keikolar',
            'as' => 'ktar',
            'in' => 
            array (
              '$dateToString' => 
              array (
                'format' => '%Y-%m',
                'date' => '$$ktar',
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  1 => 
  array (
    '$lookup' => 
    array (
      'from' => 'gelirgider',
      'localField' => '_id',
      'foreignField' => 'uye_id',
      'as' => 'aidatlar',
      'pipeline' => 
      array (
        0 => 
        array (
          '$match' => 
          array (
            '$and' => 
            array (
              0 => 
              array (
                '$expr' => 
                array (
                  '$eq' => 
                  array (
                    0 => '$tur',
                    1 => 'GELIR',
                  ),
                ),
              ),
              1 => 
              array (
                '$expr' => 
                array (
                  '$gt' => 
                  array (
                    0 => '$ay',
                    1 => 0,
                  ),
                ),
              ),
              2 => 
              array (
                '$expr' => 
                array (
                  '$regexMatch' => 
                  array (
                    'input' => '$tanim',
                    'regex' => 'aidat',
                    'options' => 'i',
                  ),
                ),
              ),
            ),
          ),
        ),
        1 => 
        array (
          '$project' => 
          array (
            '_id' => 0,
            'tarih' => 1,
            'yil' => 1,
            'ay' => 1,
            'tanim' => 1,
            'yilay' => 
            array (
              '$dateToString' => 
              array (
                'format' => '%Y-%m',
                'date' => 
                array (
                  '$dateFromParts' => 
                  array (
                    'year' => '$yil',
                    'month' => '$ay',
                    'day' => 1,
                  ),
                ),
              ),
            ),
            'tutar' => 1,
            'aciklama' => 1,
            'kasa' => 1,
            'user_text' => 1,
            'tamogrenci' => 
            array (
              '$cond' => 
              array (
                'if' => 
                array (
                  '$regexMatch' => 
                  array (
                    'input' => '$tanim',
                    'regex' => 'tam',
                    'options' => 'i',
                  ),
                ),
                'then' => 'TAM',
                'else' => 'OGRENCI',
              ),
            ),
          ),
        ),
        2 => 
        array (
          '$group' => 
          array (
            '_id' => '$yilay',
            'toplam' => 
            array (
              '$sum' => '$tutar',
            ),
            'tamogrenci' => 
            array (
              '$min' => '$tamogrenci',
            ),
            'yil' => 
            array (
              '$min' => '$yil',
            ),
            'ay' => 
            array (
              '$min' => '$ay',
            ),
            'tarih' => 
            array (
              '$max' => '$tarih',
            ),
            'kasa' => 
            array (
              '$last' => '$kasa',
            ),
            'aciklama' => 
            array (
              '$last' => '$aciklama',
            ),
            'user_text' => 
            array (
              '$last' => '$user_text',
            ),
            'tanim' => 
            array (
              '$last' => '$tanim',
            ),
          ),
        ),
      ),
    ),
  ),
  2 => 
  array (
    '$addFields' => 
    array (
      'aidataylar' => '$aidatlar._id',
    ),
  ),
  3 => 
  array (
    '$addFields' => 
    array (
      'aidateksigi' => 
      array (
        '$setDifference' => 
        array (
          0 => '$keikoaylar',
          1 => '$aidataylar',
        ),
      ),
    ),
  ),
  4 => 
  array (
    '$lookup' => 
    array (
      'from' => 'gelirgider',
      'localField' => '_id',
      'foreignField' => 'uye_id',
      'as' => 'diger',
      'pipeline' => 
      array (
        0 => 
        array (
          '$match' => 
          array (
            '$expr' => 
            array (
              '$not' => 
              array (
                '$regexMatch' => 
                array (
                  'input' => '$tanim',
                  'regex' => 'aidat',
                  'options' => 'i',
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  5 => 
  array (
    '$addFields' => 
    array (
      'dosya_id' => 
      array (
        '$toObjectId' => '$img',
      ),
    ),
  ),
  6 => 
  array (
    '$lookup' => 
    array (
      'from' => 'dosya.files',
      'localField' => 'dosya_id',
      'foreignField' => '_id',
      'as' => 'foto',
      'pipeline' => 
      array (
        0 => 
        array (
          '$lookup' => 
          array (
            'from' => 'dosya.chunks',
            'localField' => '_id',
            'foreignField' => 'files_id',
            'as' => 'data',
          ),
        ),
        1 => 
        array (
          '$project' => 
          array (
            '_id' => 0,
            'type' => '$metadata.file_type',
            'data' => 
            array (
              '$first' => '$data.data',
            ),
          ),
        ),
      ),
    ),
  ),
  7 => 
  array (
    '$addFields' => 
    array (
      'foto' => 
      array (
        '$first' => '$foto',
      ),
    ),
  ),
  8 => 
  array (
    '$match' => 
    array (
      'foto' => 
      array (
        '$exists' => true,
      ),
      'email_activation' => true,
      'cinsiyet' => 
      array (
        '$ne' => NULL,
      ),
    ),
  ),
  9 => 
  array (
    '$project' => 
    array (
      '_id' => 0,
      'ad' => 1,
      'ogrenci' => 1,
      'active' => 1,
      'cinsiyet' => 1,
      'dogum' => 1,
      'email' => 1,
      'ekfno' => 1,
      'keikolar' => 1,
      'sinavlar' => 1,
      'aidatlar' => 1,
      'aidateksigi' => 1,
      'diger' => 1,
      'foto' => 1,
    ),
  ),
));

require_once __DIR__ . "/vendor/autoload.php";

function muhtanim($tanim) {
  if (!is_null($tanim)) {
    return trim(str_replace([
      'AIDAT TAM',
      'AIDAT OGRENCI',
      'SINAV TAM',
      'SINAV OGRENCI',
      'Salona Kirası',
      'Diğer Harcamalar',
      'Diğer Masraflar',
      'Ögrenci Aidat',
      'Organizasyon Harcamaları'
    ], [
      'Tam Aidat',
      'Ögrenci Aidat',
      'Tam Sınav',
      'Öğrenci Sınav',
      'Salon Kirası',
      'Diğer',
      'Diğer',
      'Öğrenci Aidat',
      'Etkinlik Masrafı'
    ], $tanim));
  } else {
    return null;
  }
}

function val($v): string {
  if (is_null($v) || (is_string($v) && empty(trim($v)))) {
    return "NULL";
  } elseif (is_string($v)) {
    return "'$v'";
  } else {
    return "" . $v;
  }
}

function insert(string $table, array $matrix): string {


  $fields = "";
  $values = "";
  for ($i = 0; $i < count($matrix); $i++) {
    if ($i > 0) {
      $values .= ", ";
    }
    $values .= PHP_EOL . "(";
    $first = true;

    foreach ($matrix[$i] as $filed => $value) {
      if ($i == 0) {
        if (!$first) {
          $fields .= ",";
        }
        $fields .= $filed;
      }
      if (!$first) {
        $values .= ", ";
      }
      $values .= val($value);
      $first = false;
    }
    $values .= ")";
  }
  if ($fields && $values) {
    return "INSERT INTO $table ($fields) VALUES $values;" . PHP_EOL;
  } else {
    return "";
  }
}

function randomPassword(int $default = 6 ):string {
  $alphabet = "abcdefghijklmnopqrstuwxyz.!@#?*,-_%$~:0123456789";
  $pass = array(); //remember to declare $pass as an array
  $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
  for ($i = 0; $i < $default; $i++) {
      $n = rand(0, $alphaLength);
      $pass[] = $alphabet[$n];
  }
  return implode($pass); //turn the array into a string
}

if (!isset($argv[1])) {
  echo "No Connection String";
  exit(1);
}

$emaillist = [];
$conn = new \MongoDB\Client(trim($argv[1]));
$cursor = $conn->selectDatabase("dojo")->selectCollection("uye")->aggregate(QUERY);
$uyeit = new \IteratorIterator($cursor);
$uyeit->rewind();
$id = 1;
$muhasebe_id = 1;
echo "SET NAMES utf8mb3 COLLATE utf8_turkish_ci;".PHP_EOL;
echo "USE dojo;".PHP_EOL;

echo "TRUNCATE TABLE uye;".PHP_EOL;
echo "TRUNCATE TABLE uye_seviye;".PHP_EOL;
echo "TRUNCATE TABLE uye_yoklama;".PHP_EOL;
echo "TRUNCATE TABLE muhasebe;".PHP_EOL;
echo "TRUNCATE TABLE uye_tahakkuk;".PHP_EOL;
echo "TRUNCATE TABLE dosya;".PHP_EOL;

while ($doc = $uyeit->current()) {
  $uye = [
    "uye_id" => $id,
    "dosya_id" => $id,
    "ad" => $doc["ad"],
    "tahakkuk_id" => ($doc["ogrenci"] ? 2 : 1),
    "email" => $doc["email"],
    "cinsiyet" => $doc["cinsiyet"],
    "dogum_tarih" => ($doc["dogum"] ? $doc["dogum"]->toDateTime()->format('Y-m-d') : null),
    "durum" => ($doc["active"] ? "active" : "passive"),
    "ekfno" => $doc["ekfno"]
  ];
  $type = $doc["foto"]["type"];
  $foto = base64_encode($doc["foto"]["data"]);
  $seviye = null;

  if (!in_array($uye["email"], $emaillist)) {
    $seviyeler = [];
    if ($doc["sinavlar"]->count() > 0) {
      $doc["sinavlar"]->uasort(function ($a, $b) {
        if ($a["tarih"] < $b["tarih"]) {
          return 1;
        } else {
          return -1;
        }
      });
      foreach ($doc["sinavlar"] as $sinav) {
        array_push($seviyeler, [
          "uye_id" => $id,
          "tarih" => ($sinav["tarih"] ? $sinav["tarih"]->toDateTime()->format('Y-m-d') : null),
          "aciklama" => $sinav["aciklama"],
          "seviye" => strtoupper($sinav["seviye"])
        ]);
      }
    } else {
      array_push($seviyeler, [
        "uye_id" => $id,
        "tarih" => date("Y-m-d"),
        "aciklama" => "Aktarim",
        "seviye" => "7 KYU"
      ]);
    }

    $uye["seviye"] = $seviyeler[0]["seviye"];
    $uye["parola"] = randomPassword();

    $yoklamalar = [];
    foreach ($doc["keikolar"] as $keiko) {
      array_push($yoklamalar, [
        "uye_id" => $id,
        "yoklama_id" => 1,

        "tarih" => $keiko->toDateTime()->format('Y-m-d')
      ]);
    }

    $muhasebe = [];
    $aidatlar = [];
    foreach ($doc["aidatlar"] as $aidat) {

      array_push($aidatlar, [
        "uye_id" => $id,
        "tahakkuk_id" => ($aidat["tamogrenci"] == "TAM" ? 1 : 2),
        "borc" => floatval($aidat["toplam"]),
        "yil" => intval($aidat["yil"]),
        "ay" => intval($aidat["ay"]),
        "tahakkuk_tarih" => $aidat["yil"]."-".str_pad($aidat["ay"],2,"0",STR_PAD_LEFT)."-01",
        "muhasebe_id" => $muhasebe_id,
        "yoklama_id" => 1
      ]);

      array_push($muhasebe, [
        "muhasebe_id" => $muhasebe_id,
        "uye_id" => $id,
        "tarih" => $aidat["tarih"]->toDateTime()->format('Y-m-d'),
        "tutar" => floatval($aidat["toplam"]),
        "aciklama" => str_replace(["\n", "'"], " ", $aidat["aciklama"]),
        "tanim" => muhtanim($aidat["tanim"]),
        "kasa" => $aidat["kasa"],
        "tahsilatci" => $aidat["user_text"],
        "ay" => intval($aidat["ay"]),
        "yil" => intval($aidat["yil"])
      ]);
      $muhasebe_id++;
    }

    foreach ($doc["diger"] as $diger) {
      array_push($muhasebe, [
        "muhasebe_id" => $muhasebe_id,
        "uye_id" => $id,
        "tarih" => $diger["tarih"]->toDateTime()->format('Y-m-d'),
        "tutar" => floatval($diger["tutar"]),
        "aciklama" => str_replace(["\n", "'"], " ", $diger["aciklama"]),
        "tanim" => muhtanim($diger["tanim"]),
        "kasa" => $diger["kasa"],
        "tahsilatci" => $diger["user_text"],
        "ay" => null,
        "yil" => null
      ]);
      $muhasebe_id++;
    }

    foreach ($doc["aidateksigi"] as $eksik) {
      $arr = explode("-", $eksik);
      $ay = intval($arr[1]);
      $yil = intval($arr[0]);
      array_push($aidatlar, [
        "uye_id" => $id,
        "tahakkuk_id" => $uye["tahakkuk_id"],
        "borc" => ($uye["tahakkuk_id"] == 1 ? 250 : 200),
        "yil" => $yil,
        "ay" => $ay,
        "tahakkuk_tarih" => $eksik . "-01",
        "muhasebe_id" => null,
        "yoklama_id" => 1
      ]);
    }

    echo PHP_EOL . "/*" . $uye["ad"] . "--------------*/" . PHP_EOL;
    echo insert("uye",[$uye]);
    echo insert("uye_seviye",$seviyeler);
    echo insert("uye_yoklama",$yoklamalar);
    echo insert("muhasebe",$muhasebe);
    echo insert("uye_tahakkuk", $aidatlar);
    echo insert("dosya",[["tablo"=>"UYE","tablo_id"=>$id,"file_type"=>$type,"icerik"=>$foto ]]);

    array_push($emaillist, $uye["email"]);
    $id++;
  } else {
  }
  $uyeit->next();
}
