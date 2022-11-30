<div class="body">
    <div class="form">
        <div class="text">
            Sistemde kayıtlı olan e-postanızı bilmiyorsanız veya değiştirmek istiyorsanız. Lütfen dojo yöneticinizle görüşünüz.
        </div>
        <hr/>
        <div class="item">
            <label style="width: 100%">
                <span>E-Posta</span>
                <input name="email" type="text" placeholder="Sisteme kayıtlı eposta adresiniz" autocomplete="off" />
            </label>
        </div>

        <div class="item">
            <div class="h-captcha" data-sitekey="<?php echo $HCAPTCHA_SITEKEY; ?>"></div>
        </div>

        <div class="item">
            <?php button("emailformsubmit","Doğrulama E-Postası Gönder") ?>
        </div>
        <div class="link">
        <a href="?m=login">Login</a>
        </div>
    </div>
</div>