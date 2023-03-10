<div class="body">
    <div class="form">
        <div class="item">
            <?php if (!$GLOBALS["err"]) : ?>
                <h1 style="color:darkgreen">E-Postanız Doğrulanmıştır</h1>
            <?php else : ?>
                <h1 style="color:brown"><?php echo strip_tags($GLOBALS["err"]); ?></h1>
            <?php endif; ?>
        </div>

        <div class="link">
            <a href="?m=login">Üye Girişi</a>
        </div>

    </div>
</div>