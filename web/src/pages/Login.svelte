<main>
    <AppBar title="Ankara Kendo" />
    <div class="center">
        <iframe class="frame" src={serviceroot} title="Giriş"/>
    </div>
    
</main>
<script lang="ts">
    import { onMount } from 'svelte';
    import { store_title,store_user } from '../store';
    import type {UserData} from '../store';
    import { push } from 'svelte-spa-router';
    import AppBar from './comp/AppBar.svelte';


    const serviceroot = import.meta.env.VITE_SERVICE_HOST+import.meta.env.VITE_AUTH_PAGE;
    console.log(serviceroot);
    store_title.set("Login");

    function loginSucced(data:UserData) {
        if (data.token) {           
            sessionStorage.setItem("authorization",`Bearer ${data.token}`);            
            store_user.set(data);
            push("/welcome");
        } else {
            console.log("olmadi");
        }
        
    }

    window.addEventListener("message",e=>{
        loginSucced(e.data);        
    })

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
</style>