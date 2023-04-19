<?php
require_once "page.php";

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
                <a href="?m=email">Şifremi Unuttum</a>
            </div>

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
            if (!isEmail(user)) {
                console.log(user);
                raise("E-Posta formatı doğru değil", 1);
                return;
            }

            if (pass.length < 6) {
                raise("Parola en az 6 karakter olmalı", 1);
                return;
            }
            btn.showLoading();

            fetch("service.php/token", {
                method: "POST",
                cache: 'no-cache',
                body: JSON.stringify({
                    "type": type
                }),
                headers: {
                    "Content-Type": "application/json; charset=utf-8",
                    "authorization": "Basic " + btoa(user + ":" + pass)
                }
            }).then(raw => {
                btn.hideLoading();
                raw.json().then(response => {
                    if (response.success) {
                        response.data.password = pass;
                        callback(response.data);
                    } else {
                        raise(response.data.message, 4);
                    }
                }).catch(err => {
                    raise(err, 3);
                });
            }).catch(err => {
                btn.hideLoading();
                raise(err, 2);
            });
            
            
        }
    </script>
<?php
});
