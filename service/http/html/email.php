<div class="body">
    <div class="form">
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
            <button type="button" class="button" onclick="emailformsubmit(this)">
            <img src="../assets/loading.gif" style="width: 1.2em;height: 1.2em; vertical-align: middle; display: none;" />
            Doğrulama E-Postası Gönder</button>
        </div>
    </div>
</div>