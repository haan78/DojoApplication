<div class="header">
    <a href="?m=new">Yeni Kayıt</a>
    <a href="?m=forgot">Şifremi Bilmiyorum</a>
</div>
<div class="body">
    <div class="item">
        <label style="width: 100%">
            <span>E-Posta</span>
            <input name="username" type="text" placeholder="E-Posta" autocomplete="off" />
        </label>
    </div>
    <div class="item">
        <label style="width: 100%">
            <span>Parola</span>
            <input name="password" type="password" placeholder="Parola" autocomplete="off" />
        </label>
    </div>

    <div class="item">
        <label style="cursor: pointer;"><input type="checkbox" onchange="" />Beni Hatırla</label>
    </div>
    <div class="item">
        <div class="h-captcha" data-sitekey="a896eecd-92bd-4f8a-b523-e5453c631235" data-size="compact"></div>
    </div>

    <div class="item">
        <button type="button" class="button" onclick="loginformsubmit()">Giriş</button>
    </div>
</div>
<script>
    loadlogin();
</script>