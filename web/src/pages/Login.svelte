<main>
    <div class="center">
        <iframe class="frame" src={serviceroot} title="Giriş"/>
    </div>
    
</main>
<script lang="ts">
    import { onMount } from 'svelte';
    import { store_title,store_user } from '../store';
    import type {UserData} from '../store';
    import { push } from 'svelte-spa-router';


    const serviceroot = import.meta.env.VITE_SERVICE_ROOT;
    
    store_title.set("Login");

    function loginSucced(data:UserData) {
        const token = data.token;        
        sessionStorage.setItem("bearer-auth",`Bearer ${token}`);
        data.token = "";
        store_user.set(data);
        push("/welcome");
    }

    window.addEventListener("message",e=>{
        loginSucced(e.data);        
    })

    onMount(()=>{
    });

</script>
<style>
     .center {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
        width: 100%;
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
</style>