<div class="body">
    <?php if (!$err) :?>
        <h1 style="color:darkgreen">E-Postanız Doğrulanmıştır</h1>        
    <?php else : ?>
        <h1 style="color:brown"><?php $err; ?></h1>
    <?php endif; ?>
    <hr/>
    <a href="?m=login" >Üye Girişi</a>
</div>
