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
                <span>Parola333</span>
                <input name="password" type="password" placeholder="Parola" autocomplete="off" />
            </label>
        </div>

        <div class="separate">
            <div class="item">
                <label style="cursor: pointer;"><input type="checkbox" onchange="" />Beni Hatırla</label>
            </div>
            <a href="javascript:;" onclick="removelogincookie()">Beni Unut</a>
        </div>

        <div class="item">
            <div class="h-captcha" data-sitekey="<?php echo $HCAPTCHA_SITEKEY; ?>"></div>
        </div>

        <div class="item">
            <?php button("loginformsubmit", "Giriş"); ?>
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
        document.querySelector(".separate").style.display = "none";
        /*if ( type == "admin" ) {
            document.querySelector(".separate").style.display = "none";
        } else {
            document.querySelector(".separate").style.display = "block";
        }*/
    }
    loadlogin();
</script>