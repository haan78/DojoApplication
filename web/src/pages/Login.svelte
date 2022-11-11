<main class="login">
    <label>
        <span>E-Posta</span><br/>
        <input type="text" bind:value={formdata.username} placeholder="E-Posta" />
    </label>

    <label>
        <span>Poarola</span><br/>
        <input type="password" bind:value={formdata.password} placeholder="Parola" />
    </label>    
    
    <div style="text-align: center;">
        <button class="btn prm" style="width: 100%" ><LogInIcon size="1x"/>Giriş</button>
    </div>
    <div class="bottomline">
        <button type="button" class="btn" on:click={()=>{push("/new")}}><HelpCircleIcon size="1x" />Şifremi Bilmiyorum</button>
        <button type="button" class="btn" on:click={()=>{push("/password-reset")}}><UserPlusIcon size="1x"/>Yeni Kayıt</button>
    </div>
    
</main>
<script lang="ts">
    import { store_title } from '../store';
    import { LogInIcon,HelpCircleIcon,UserPlusIcon } from 'svelte-feather-icons';
    import { push } from 'svelte-spa-router';
    store_title.set("Login");
    let formdata = {
        username:"",
        password:""
    };
</script>
<style>
    .login label {        
        display: block;
        padding-bottom: 1.5em;
    }
    .login .bottomline {
        padding-top: 2.5em;
        display: flex;
        justify-content: space-between;
    }
</style>