<?php
if (PHP_SAPI != 'cli') {
  die("Works only CLI mode");
}

define("QUERY", [
  0 => [
    '$addFields' => [
      'keikoaylar' => [
        '$setUnion' => [
          '$map' => [
            'input' => '$keikolar',
            'as' => 'ktar',
            'in' => [
              '$dateToString' => [
                'format' => '%Y-%m',
                'date' => '$$ktar',
              ],
            ],
          ],
        ],
      ],
    ],
  ],
  1 => [
    '$lookup' => [
      'from' => 'gelirgider',
      'localField' => '_id',
      'foreignField' => 'uye_id',
      'as' => 'aidatlar',
      'pipeline' => [
        0 => [
          '$match' => [
            '$and' => [
              0 => [
                '$expr' => [
                  '$eq' => [
                    0 => '$tur',
                    1 => 'GELIR',
                  ],
                ],
              ],
              1 => [
                '$expr' => [
                  '$gt' => [
                    0 => '$ay',
                    1 => 0,
                  ],
                ],
              ],
              2 => [
                '$expr' => [
                  '$regexMatch' => [
                    'input' => '$tanim',
                    'regex' => 'aidat',
                    'options' => 'i',
                  ],
                ],
              ],
            ],
          ],
        ],
        1 => [
          '$project' => [
            '_id' => 0,
            'tarih' => 1,
            'yil' => 1,
            'ay' => 1,
            'tanim' => 1,
            'yilay' => [
              '$dateToString' => [
                'format' => '%Y-%m',
                'date' => [
                  '$dateFromParts' => [
                    'year' => '$yil',
                    'month' => '$ay',
                    'day' => 1,
                  ],
                ],
              ],
            ],
            'tutar' => 1,
            'aciklama' => 1,
            'kasa' => 1,
            'user_text' => 1,
            'tamogrenci' => [
              '$cond' => [
                'if' => [
                  '$regexMatch' => [
                    'input' => '$tanim',
                    'regex' => 'tam',
                    'options' => 'i',
                  ],
                ],
                'then' => 'TAM',
                'else' => 'OGRENCI',
              ],
            ],
          ],
        ],
        2 => [
          '$group' => [
            '_id' => '$yilay',
            'toplam' => [
              '$sum' => '$tutar',
            ],
            'tamogrenci' => [
              '$min' => '$tamogrenci',
            ],
            'yil' => [
              '$min' => '$yil',
            ],
            'ay' => [
              '$min' => '$ay',
            ],
            'tarih' => [
              '$max' => '$tarih',
            ],
            'kasa' => [
              '$last' => '$kasa',
            ],
            'aciklama' => [
              '$last' => '$aciklama',
            ],
            'user_text' => [
              '$last' => '$user_text',
            ],
            'tanim' => [
              '$last' => '$tanim',
            ],
          ],
        ],
      ],
    ],
  ],
  2 => [
    '$addFields' => [
      'aidataylar' => '$aidatlar._id',
    ],
  ],
  3 => [
    '$addFields' => [
      'aidateksigi' => [
        '$setDifference' => [
          0 => '$keikoaylar',
          1 => '$aidataylar',
        ],
      ],
    ],
  ],
  4 => [
    '$lookup' => [
      'from' => 'gelirgider',
      'localField' => '_id',
      'foreignField' => 'uye_id',
      'as' => 'diger',
      'pipeline' => [
        0 => [
          '$match' => [
            '$expr' => [
              '$not' => [
                '$regexMatch' => [
                  'input' => '$tanim',
                  'regex' => 'aidat',
                  'options' => 'i',
                ],
              ],
            ],
          ],
        ],
      ],
    ],
  ],
  5 => [
    '$addFields' => [
      'dosya_id' => [
        '$toObjectId' => '$img',
      ],
    ],
  ],
  6 => [
    '$match' => [
      'email_activation' => true,
      'cinsiyet' => [
        '$ne' => NULL,
      ],
    ],
  ],
  7 => [
    '$project' => [
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
      'img' => 1,
    ],
  ],
]);

require_once __DIR__ . "/vendor/autoload.php";

function muhtanim($tanim,$tutar) {
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
      'Tam Aidat',
      'Organizasyon Harcamaları',
      'Diğer',
      'DİĞER',
      'Salon Kirası',
      'Bağış',
      'Satış',
      'Öğrenci Aidat',
      'Tam Sınav',
      'Öğrenci Sınav'
    ], [
      9,
      9,
      10,
      10,
      1,
      $tutar >= 0 ? 15 : 8,
      $tutar >= 0 ? 15 : 8,
      9,
      9,
      2,
      $tutar >= 0 ? 15 : 8,
      $tutar >= 0 ? 15 : 8,
      1,
      14,
      13,
      9,
      10,
      10
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

function passCreate(int $len = 8): string {
  $KEYS = '1234567890ABCFGTXRYUPLabcdefghtlomnvcxz_';
  $s = "";
  for ($i = 0; $i < $len; $i++) {
      $s.= $KEYS[random_int(0,strlen($KEYS)-1)];
  }
  return $s;
}

if (!isset($argv[1])) {
  echo "No Connection String";
  exit(1);
}

$dbpass = passCreate(22);

echo "/* DB SQL */\n".str_replace('{{dbpassword}}','\''.$dbpass.'\'',file_get_contents('01-db.sql'))."\n\n";
echo "/* TABLES SQL */\n".file_get_contents('02-tables.sql')."\n\n";
echo "####/* PROCEDURES SQL */\n".file_get_contents('03-procedures.sql')."\n\n";

$emaillist = [];
$conn = new \MongoDB\Client(trim($argv[1]));
$cursor = $conn->selectDatabase("dojo")->selectCollection("uye")->aggregate(QUERY);
$uyeit = new \IteratorIterator($cursor);
$uyeit->rewind();
$id = 1;
$muhasebe_id = 1;

echo "/* DATA SQL */\n";
/*echo "TRUNCATE TABLE uye;".PHP_EOL;
echo "TRUNCATE TABLE uye_seviye;".PHP_EOL;
echo "TRUNCATE TABLE uye_yoklama;".PHP_EOL;
echo "TRUNCATE TABLE muhasebe;".PHP_EOL;
echo "TRUNCATE TABLE uye_tahakkuk;".PHP_EOL;
echo "TRUNCATE TABLE dosya;".PHP_EOL;*/

$bucket = $conn->selectDatabase("dojo")->selectGridFSBucket([
  "bucketName" => "dosya"
]);

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
  $img = $doc["img"];
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

    //$uye["seviye"] = $seviyeler[0]["seviye"];
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
        "muhasebe_tanim_id" => muhtanim($aidat["tanim"],floatval($aidat["toplam"])),
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
        "muhasebe_tanim_id" => muhtanim($diger["tanim"],floatval($diger["tutar"])),
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
        "borc" => ($uye["tahakkuk_id"] == 1 ? 350 : 300),
        "yil" => $yil,
        "ay" => $ay,
        "tahakkuk_tarih" => $eksik . "-01",
        "muhasebe_id" => null,
        "yoklama_id" => 1
      ]);
    }

    $f_id = new \MongoDB\BSON\ObjectId($img);
    $f_result = $bucket->findOne(["_id" => $f_id]);
    $f_data = null;
    if ( !is_null($f_result) ) {
      $destination = fopen('php://temp', 'w+b');
      $bucket->downloadToStream($f_id, $destination);
      $f_data = stream_get_contents($destination, -1, 0);
    }

    echo PHP_EOL . "/*" . $uye["ad"] . "--------------*/" . PHP_EOL;
    echo insert("uye",[$uye]);
    echo insert("uye_seviye",$seviyeler);
    echo insert("uye_yoklama",$yoklamalar);
    echo insert("muhasebe",$muhasebe);
    echo insert("uye_tahakkuk", $aidatlar);
    if (!is_null($f_data)) {
      echo "\nINSERT INTO dosya (dosya_id, file_type, icerik) VALUES ( $id, '".$f_result->metadata->file_type."', FROM_BASE64('".base64_encode($f_data)."') );";
    }    

    array_push($emaillist, $uye["email"]);
    $id++;
  } else {
  }
  $uyeit->next();
}
