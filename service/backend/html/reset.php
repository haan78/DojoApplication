<div class="body">
    <div class="form">
        <input type="hidden" value="<?php echo isset($_GET["code"]) ? trim($_GET["code"]) : ""; ?>" name="code" />
    <div class="item">
            <label style="width: 100%">
                <span>Yeni Parola</span>
                <input name="new" type="password" placeholder="Parola" autocomplete="off" />
            </label>
        </div>
        <div class="item">
            <label style="width: 100%">
                <span>Tekrar Parola</span>
                <input name="repeat" type="password" placeholder="Parola" autocomplete="off" />
            </label>
        </div>

        <div class="item">
            <div class="h-captcha" data-sitekey="<?php echo $HCAPTCHA_SITEKEY; ?>"></div>
        </div>

        <div class="item">
            <?php button("resetformsubmit","Değiştir"); ?>
        </div>
    </div>
</div>