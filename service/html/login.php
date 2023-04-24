<?php
require_once "page.php";
setSessionAttempt();
page(function () {
?>
    <div class="body">
        <div class="form">
            <input type="hidden" name="type" value="" />
            <div class="item">
                <label style="width: 100%">
                    <span>E-Posta</span>
                    <input name="username" type="text" placeholder="Sisteme kayıtlı eposta adresiniz" autocomplete="off" />
                </label>
            </div>
            <div class="item">
                <label style="width: 100%">
                    <span>Parola</span>
                    <input name="password" type="password" placeholder="Parola" autocomplete="off" />
                </label>
            </div>

            <div class="item">
                <button class="entry" onclick="login(this)">Giriş</button>
            </div>
            <div class="link">
                <a href="email.php">Şifremi Bilmiyorum</a>
            </div>
            <div class="link">
                <a href="mailto:<?php echo INFO_EMAIL; ?>"><?php echo INFO_EMAIL; ?></a>
            </div>
            <input type="text" name="type12" value="" placeholder="Boş bırak" style="display: none;" />
        </div>
    </div>
    <script>
        function setLoginData(user, pass, type) {
            document.querySelector("input[name=username]").value = user || "";
            document.querySelector("input[name=password]").value = pass || "";
            document.querySelector("input[name=type]").value = type || "";
        }

        function login(btn) {
            var user = document.querySelector("input[name=username]").value.trim();
            var pass = document.querySelector("input[name=password]").value.trim();
            var type = document.querySelector("input[name=type]").value.trim();
            var type12 = document.querySelector("input[name=type12]").value.trim();
            if (type12 || !type) {                
                return;
            }
            if (!isEmail(user)) {
                console.log(user);
                raise("E-Posta formatı doğru değil", 1);
            } else if (pass.length < 6 || pass.length > 20) {
                raise("Parola en az 6 en fazla 20 karakter olmalı", 1);
            } else {
                btn.send({
                    url: "service.php/open/token",
                    user: user,
                    password: pass,
                    data: {
                        type: type
                    }
                }).then(data => {
                    data.password = pass;
                    callback(data);
                }).catch(err => {
                    raise(err.toString());
                });
            }
        }
    </script>
<?php
});
