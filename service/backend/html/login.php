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
    }
</script>