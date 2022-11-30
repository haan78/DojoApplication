<main class="main">
    <div class="header">
        {#if module!="Member"}
        <a href={'javascript:;'} on:click={()=>{ module="Member"; }}>Üye</a>
        {/if}
        {#if module != "PasswordChange" }
        <a href={'javascript:;'} on:click={()=>{ module="PasswordChange"; }}>Parola</a>
        {/if}
        {#if module != "Dues"}
        <a href={'javascript:;'} on:click={()=>{ module="Dues"; }}>Aidatlar</a>
        {/if}
        <a href={'#'} on:click={()=>{ push("/"); }}>Çıkış</a>        
    </div>
    <div class="body" >
        {#if module=="PasswordChange"}
        <PasswordChange />
        {:else if module == "Dues"}
        <Dues dues={duelist}/>
        {:else}
        <Member />
        {/if}
    </div>
</main>

<script lang="ts">
    import { push } from "svelte-spa-router";
    import PasswordChange from './PasswordChange.svelte';
    import Member from './Member.svelte';    
    import Dues from './Dues.svelte';    
    import { onMount } from "svelte";
    import {JRequest } from "../lib/JRequest";
    import type { JRequestError } from "../lib/JRequest";
    import type { Due } from "../Types";

    let duelist:Array<Due> = [];

    let module:string = "";
    onMount(()=>{
        module = "Member";
        JRequest("/member/bilgi").then(response=>{
            duelist = response[2];
        }).catch((err:JRequestError)=>{
            if (err.status == 401) {
                push("/");
            }
        });
    });

</script>

<style>
    .main > .header {
        text-align: right;
        font-size: small;
    }
    .main > .header > a {
        margin-right: 1em;
    }
</style>