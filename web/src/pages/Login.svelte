<main>
    <AppBar title="Ankara Kendo" />
    <div class="center">
        <iframe class="frame" src="/login.php" title="Giriş" bind:this={frame} on:load={fLoad}/>        
    </div>
    <div class="remember">
        <label>Beni Hatirla<input type="checkbox" bind:checked={remember} /></label>
        <a href={"javascript:;"} on:click={removeUser}>Beni Unut</a>
    </div>
    
    
</main>
<script lang="ts">
    import { onMount } from 'svelte';
    import { store_user,store_status,isLoggedIn } from '../store';
    import type {UserData} from '../store';
    import { push } from 'svelte-spa-router';
    import AppBar from './comp/AppBar.svelte';
    import Cookie from '../lib/Cookie';

    let ankarakendo_login_user:string = "";
    let ankarakendo_login_pass:string = "";
    let frame:any;
    let remember:boolean = false;


    function loginSucced(data:UserData) {
        if (remember) {
            Cookie.set("ankarakendo-login-user", ankarakendo_login_user, 2);
            Cookie.set("ankarakendo-login-pass", ankarakendo_login_pass, 2);
        }

        store_user.set(data);
        store_status.update(v=>true);
        console.log([isLoggedIn(),"login"]);
        push("/welcome");
    }

    window.addEventListener("message",e=>{
        loginSucced(e.data);
    })

    function fLoad() {        
        ankarakendo_login_user = Cookie.get("ankarakendo-login-user") || "";
        ankarakendo_login_pass = Cookie.get("ankarakendo-login-pass") || "";
        if (frame.contentWindow  && typeof frame.contentWindow.setLoginData == "function") {
            frame.contentWindow.setLoginData(ankarakendo_login_user,ankarakendo_login_pass,"web");
        }
    }

    function removeUser() {
        Cookie.set("ankarakendo-login-user", "", -1);
        Cookie.set("ankarakendo-login-pass", "", -1);
        window.location.reload();
    }

    onMount(()=>{
        sessionStorage.removeItem("authorization");        
    });

</script>
<style>
     .center {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
        width: 100%;
        margin-top: 3em;
     }

     .center > .frame {
        border: none;
        width: 100%;
        height: 360px;
        max-width: 330px;
        border: solid 1px black;
        border-radius: 1em;        
        overflow: hidden;
    }
    .remember {
        padding: 1em;
        display: flex;
        justify-content: space-around;
    }
</style>