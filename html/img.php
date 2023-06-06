<?php
require_once "./settings.php";
require_once "./customized/db.php";
require_once "vendor/autoload.php";
require_once "./lib/Minmi.php";
require_once "./customized/routerAdmin.php";

use \Minmi\Router;
use \Minmi\Response;

initSecret();

class ImageResult  {
    public string $type;
    public $data;
    public $quality = null;

    function __construct(string $type, $data, $quality = null) {
        $this->type = $type;
        $this->data = $data;
        $this->quality = $quality;
    }
}

class ImageRouter extends Router {

    function imgText(string $message): void {
        $img = imagecreatefromjpeg("./assets/kendoka.jpg");
        $color = imagecolorallocate($img, 255, 155, 155);
        imagestring($img,5, 10, 10, $message,$color);
        header('Content-type: image/jpeg');
        imagejpeg($img);
        imagedestroy($img);
    }


    protected function output(Response $response) : void {

        foreach($response->headers as $h) {
            header($h,true);
        }

        if (!$response->error) {

            if ($response->result instanceof ImageResult) {
                if ($response->result->type == "image/png") {
                    header('Content-type: image/jpeg');
                    imagejpeg($response->result);
                    imagedestroy($response->result->data);
                } elseif ($response->result->type == "image/jpeg") {
                    header('Content-type: image/png');
                    imagepng($response->result->data);
                    imagedestroy($response->result->data);
                } else {
                    $this->imgText("Unknown ".$response->result->type);
                }
            } else {
                $this->imgText("No ImageResult");
            }
        } else {
            $this->imgText($response->error->getMessage());
        }
    }
}

$router = new ImageRouter("",function($req){
    authAdmin($req);
});

$router->add("/uye/#uye_id",function($req) {
    $uye_id = $req->params()["uye_id"] ?? 0;
    $new_width = 165;
    $new_height = 222;
    if ($uye_id > 0) {
        $imgdata = uyeImage($uye_id);

        list($w, $h) = getimagesizefromstring($imgdata->icerik);
        $im = @imagecreatefromstring($imgdata->icerik);
        //var_dump([$h,$w]);
        if ($im) {
            if ( isset($_GET["orginal"]) ) {
                return new ImageResult("image/jpeg", $im,-1);    
            } else {
                $dst = imagecreatetruecolor($new_width, $new_height);    
                imagecopyresized($dst, $im, 0, 0, 0, 0, $new_width, $new_height, $w, $h);
                return new ImageResult("image/jpeg", $dst,-1);
            }
            
        } else {        
            throw new \Exception("img error");
        }
    } else {
        throw new \Exception("No ID");
    }
});

$router->execute();
