<main>
    <iframe class="frame" src={serviceroot} title="Giriş"/>
</main>
<script lang="ts">
    import { onMount } from 'svelte';
    import { store_title,store_user } from '../store';
    import type {UserData} from '../store';
    import { push } from 'svelte-spa-router';
    import { setCookie } from 'typescript-cookie';


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
    .frame {
        border: none;
        width: 100%;
        height: 400px;
        max-width: 500px;
    }
</style>