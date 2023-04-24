<?php
require_once "page.php";
setSessionAttempt();
page(function () {
?>
    <div class="body">
        <div class="form">
            <div class="text">
                Sistemde kayıtlı olan e-postanızı bilmiyorsanız veya değiştirmek istiyorsanız. Lütfen dojo yöneticinizle görüşünüz.
            </div>
            <hr />
            <div class="item">
                <label style="width: 100%">
                    <span>E-Posta</span>
                    <input name="email" type="text" placeholder="Sisteme kayıtlı eposta adresiniz" autocomplete="off" />
                </label>
            </div>

            <div class="item">
                <button class="entry" onclick="emailformsubmit(this)">Doğrulama E-Postası Gönder</button>
            </div>
            <div class="link">
                <a href="login.php">Login</a>
            </div>
            <div class="link">
                <a href="mailto:<?php echo INFO_EMAIL; ?>"><?php echo INFO_EMAIL; ?></a>
            </div>
        </div>
    </div>
    <script>
        function setLoginData(email) {
            document.querySelector("input[name=email]").value = email || "";
        }

        function emailformsubmit(btn) {
            var email = document.querySelector("input[name=email]").value.trim();
            if (!isEmail(email)) {
                raise("E-Posta formatı doğru değil", 1);
            } else {
                btn.send({
                    url: "service.php/open/email",
                    data: {
                        "email": email
                    }
                }).then(data => {
                    success("Aktivasyon e-postası eposta adresinize gönderildi").then(() => {
                        window.location.href = "login.php"
                    });
                }).catch(err => {
                    raise(err.toString())
                });
            }
        }
    </script>
<?php
});
