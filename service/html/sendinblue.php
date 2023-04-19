<?php


function sendinblue(string $email, int $id, object $params = null) {
    $curl = curl_init();

    curl_setopt_array($curl, array(
        CURLOPT_URL => "https://api.sendinblue.com/v3/smtp/email",
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_ENCODING => "",
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_TIMEOUT => 0,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
        CURLOPT_CUSTOMREQUEST => "POST",
        CURLOPT_POSTFIELDS => "{ \"templateId\": $id, \"to\": [ { \"email\": \"$email\" } ], \"params\": " . json_encode($params) . "}",
        CURLOPT_HTTPHEADER => array(
            "api-key: " . $_ENV["SENDINBLUE_APIKEY"],
            "Content-Type: application/json"
        )
    ));

    $response = curl_exec($curl);
    $error = null;
    if ($response === FALSE) {
        $error = curl_error($curl);
    } else {
        $obj = json_decode($response, true);
        if (isset($obj["code"])) {
            $error = $obj["code"] . " / " . $obj["message"];
        } elseif (is_null($obj)) {
            $error = "E-Mail gonderimi basarisiz daha sonra tekrar deneyin($response)";
        }
    }
    curl_close($curl);

    if (!is_null($error)) {
        throw new \Exception($error);
    }
}
