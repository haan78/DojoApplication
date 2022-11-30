<div class="body">
    <div class="form">
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
            <?php button("loginformsubmit","Giriş"); ?>
        </div>
        <div class="link">
        <a href="?m=email">Şifremi Unuttum</a>
        </div>
        
    </div>
</div>
<script>
    loadlogin();
</script>