<?php
require_once "./settings.php";
require_once "vendor/autoload.php";
require_once "./lib/Minmi.php";
require_once "./customized/db.php";
require_once "./customized/sendinblue.php";
require_once "./customized/routerAdmin.php";
require_once "./customized/routerMember.php";
require_once "./customized/routerOpen.php";

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

initSecret();

$router = new DefaultJsonRouter("", function (Request $req) {
    $urlpattern = $req->getUriPattern();
    if (strpos($urlpattern,"/open") === 0) {
        authOpen($req);
    } elseif (strpos($urlpattern,"/member") === 0) {
        authMember($req);
    } elseif (strpos($urlpattern,"/admin") === 0) {
        authAdmin($req);
    } else {
        throw new MinmiExeption("Unknown request type", 401);
    }    
});

routerOpen($router);
routerAdmin($router);
routerMember($router);

$router->execute();
