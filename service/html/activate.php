<?php
require_once "page.php";
require_once "./customized/db.php";
$code = $_GET["code"] ?? "";
if ( !$code ) {
    die("Invalid code");
}
$err = "";
setSessionAttempt();
initSecret();
try {
    uye_eposta_onay($code);
} catch(Exception $ex) {
    $err = $ex->getMessage();
}

page(function () {
    global $err;
?>
    <div class="body">
        <div class="form">
            <div class="item">
                <?php if (!$err) : ?>
                    <h1 style="color:darkgreen">E-Postanız Doğrulanmıştır</h1>
                    <p>Artık bu şifreyle <a href="/">dojo.ankarakendo.com</a> adresine giriş yapabilirsiniz.</p>
                <?php else : ?>
                    <h1 style="color:brown"><?php echo strip_tags($err); ?></h1>
                    <p>Birşeyler yanlış gitti. Bu sayfaya yanlış bir anahtarla gelmiş olabilirsiniz veya aktifleştirme işlemini yapmakta geç kalınmış olabilir. Sorunun cözümü için lütfen dojo sistem yöneticisiyle görüşün.</p>
                <?php endif; ?>
            </div>

            <div class="link">
                <a href="/">
                    Üye Girişi ve Şifre Alma<br/>
                </a>
            </div>
            <div class="link">
                <a href="mailto:<?php echo $GLOBALS["INFO_EMAIL"]; ?>"><?php echo $GLOBALS["INFO_EMAIL"]; ?></a>
            </div>

        </div>
    </div>
<?php
});
