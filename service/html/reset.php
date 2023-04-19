<?php
require_once "page.php";
page(function(){
    ?>
    <div class="body">
    <div class="form">
        <input type="hidden" value="<?php echo $_GET["code"] ?? ""; ?>" name="code" />
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
            <button class="entry" onclick="resetformsubmit(this)">Değiştir</button>
        </div>
    </div>
</div><script>
    function resetformsubmit(btn) {
    var code = document.querySelector("input[name=code]").value.trim();
    var pass = document.querySelector("input[name=new]").value.trim();
    var _repeat = document.querySelector("input[name=repeat]").value.trim();

    if (pass.length < 6) {
        raise("Parola en az 6 karakter olmalı", 1);
        return;
    }

    if (pass != _repeat ) {
        raise("Parola terarıyla uyuşmuyor", 1);
        return;
    }

    btn.send({url:"service.php/reset",data:{
        "password":pass,
        "code":code
    }}).then(data=>{
        window.location.href = "/member";
    }).catch(err=>{
        raise(err);
    });
}
</script>
    <?php
});