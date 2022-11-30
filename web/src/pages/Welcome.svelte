<main>
    <AppBar title="Ankara Kendo" settings={true}>
        <ul class="settings" slot="settings" >
            <li><a href={'javascript:;'} on:click={()=>{ module="PasswordChange"; }}><KeyIcon size="1x" /> Parola Değiştir</a></li>
            <li><a href={'javascript:;'} on:click={()=>{ module="Member"; }}><UserIcon size="1x" /> Üye Bilgisi</a></li>
            <li><a href={'javascript:;'} on:click={()=>{ module="Dues"; }}><CreditCardIcon size="1x" /> Aidatlar</a></li>
            <li><a href={'javascript:;'} on:click={()=>{ push("/"); }}><LogOutIcon size="1x" /> Çıkış</a></li>
        </ul>
    </AppBar>

    <div style="padding: 2em;">
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
    import { KeyIcon, UserIcon, CreditCardIcon, LogOutIcon } from 'svelte-feather-icons';
    import { push } from "svelte-spa-router";
    import PasswordChange from './PasswordChange.svelte';
    import Member from './Member.svelte';    
    import Dues from './Dues.svelte';    
    import { onMount } from "svelte";
    import {JRequest } from "../lib/JRequest";
    import type { JRequestError } from "../lib/JRequest";
    import type { Due } from "../Types";
    import AppBar from "./comp/AppBar.svelte";

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

    .settings {
        list-style-type: none;
        padding: 1em;
        background-color: white;
        filter: drop-shadow(.5em .5em 1em black);
        border-radius: .7em;
    }
    .settings > li {
        white-space: nowrap;
        padding-bottom: .5em;
    }
    .settings > li > a {
        color: darkblue;
        text-decoration: none;
        cursor: pointer;
    }
</style>