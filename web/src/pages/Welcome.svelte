<main>
    <AppBar title="Ankara Kendo" on:exit={()=>{ push("/") }}>
        <span slot="exit"></span>
    </AppBar>
    <div class="container">
        <div class="settings">            
            <a class:active={module=="Member"}  href={'javascript:;'} on:click={()=>{ module="Member"; }}><UserIcon size="1x" /> Üye Bilgisi</a>
            <a class:active={module=="Dues"}  href={'javascript:;'} on:click={()=>{ module="Dues"; }}><CreditCardIcon size="1x" /> Aidatlar</a>
            <a class:active={module=="PasswordChange"} href={'javascript:;'} on:click={()=>{ module="PasswordChange"; }}><KeyIcon size="1x" /> Parola Değiştir</a>
        </div>
    <div>
        {#if module=="PasswordChange"}
        <PasswordChange />
        {:else if module == "Dues"}
        <Dues dues={duelist}/>
        {:else if module == "Loading"}
        <img src="loading.svg" alt="" />
        {:else}
    <div class="info">
        <div class="left">
            <img class="foto" src={ `data:image/png;base64, ${info.img64}` } alt="" />
        </div>
        <div class="labels">
            <span><b>Ad</b>{info.ad}</span>
            <span><b>Cinsiyet</b>{info.cinsiyet}</span>
            <span><b>Doğum Tar.</b>{ (new Date(info.dogum_tarih)).toLocaleDateString()}</span>
            <span><b>Üyelik Tipi</b> {info.tahakkuk}</span>
            <hr/>            
            <span><b>Seviye</b>{level.seviye}</span>
            <span><b>Seviye Tar.</b>{ level.tarih ? (new Date(level.tarih)).toLocaleDateString() : "" }</span>            
                      
        </div>
        <div class="labels">
            <span><b>Son Çal.</b>{attendances[0] ? ((new Date(attendances[0].tarih)).toLocaleDateString()) + " / " + attendances[0].tanim : "" }</span>
            <span><b>Son 3 Ay Çal.</b>{info.son3Ay}</span>  
            <hr/>
            {#if duesum_count > 0}
                <span class="bad"><b>Ödenmemiş Aidat</b>{duesum_count}</span>
                <span class="bad"><b>Ödenmemiş Borç</b>{duesum_total}</span>
                <a href={'javascript:;'} on:click={() => module = "Dues"}>Aidatlar</a>  
            {:else}
                <span class="good"><b>Aidat Borcunuz Blunmamaktadır</b></span>
            {/if}
            
        </div>
    </div>
        {/if}
    </div>
</div>
</main>

<script lang="ts">
    // @ts-strict
    import { KeyIcon, UserIcon, CreditCardIcon, LogOutIcon } from 'svelte-feather-icons';
    import { push } from "svelte-spa-router";
    import PasswordChange from './PasswordChange.svelte';
    import Dues from './Dues.svelte';    
    import { onMount } from "svelte";
    import {JRequest } from "../lib/JRequest";
    import type { JRequestError } from "../lib/JRequest";
    import type { Due, MemberInfo, Level, UyeYoklama, Uyebilgi } from "../Types";
    import AppBar from "./comp/AppBar.svelte";

    let duelist:Array<Due> = [];
    let info:MemberInfo = {
        ad:"",
        dogum_tarih:"",
        cinsiyet:"",
        dosya_id:0,
        ekfno:"",
        email:"",
        img64:"",
        son3Ay:0,
        tahakkuk:"",
        tahakkuk_id:0,
    };
    let levels:Array<Level> = [];
    let attendances:Array<UyeYoklama> = [];
    let level:Level = {
        aciklama:"",
        seviye:"",
        tarih:"",
        uye_seviye_id:0
    }

    let duesum_total:number = 0;
    let duesum_count:number = 0;
    


    let module:string = "";
    onMount(()=>{
        module = "Loading";
        JRequest<Uyebilgi>("/member/bilgi").then(response=>{
            levels = response[1];
            if (levels[0]) {
                level = levels[0];
            };
            attendances = response[3];
            duelist = response[2];
            info = response[0][0];
            duesum_count = 0;
            duesum_total = 0;
            duelist.forEach(due=>{
                if (!due.muhasebe_id) {
                    duesum_count += 1;                                        
                    duesum_total += parseFloat(""+due.borc);
                }
            });
            module = "Member";
        }).catch((err:JRequestError)=>{
            if (err.status == 401) {
                push("/");
            }
        });
    });

</script>

<style>
    .container {
        padding-left: 1em;
        padding-right: 1em;
        padding-top: 1em;
        padding-bottom: 0em;
    }

    .settings {
        list-style-type: none;
        padding: 1em;
        background-color: white;       
        border-radius: .7em;
        border: solid 1px black;
        font-size: small;
        margin-bottom: 1em;
    }
    .settings > a {
        color: darkblue;
        text-decoration: none;
        cursor: pointer;
        white-space: nowrap;
        margin-right: 1em;
    }
    .settings > a.active {
        font-weight: bolder;
    }

    .info {
        display: flex;
        flex-wrap: wrap;
        min-width: 330px;
    }

    .info > .left {
        max-width: 40%;
    }

    .info > .left > img {
        width: 100%;
        height: auto;
    }

    .labels {
        display: flex;
        flex-direction: column;
        align-content: flex-start;
        justify-content: flex-start;
        padding-left: .5em;
    }

    .labels > hr {
        width: 100%;
    }

    .labels > span {
        margin-bottom: .5em;
    }

    .labels > span.bad {
        color: red;
    }

    .labels > span.good {
        color: darkgreen;
    }

    .labels > span > b {
        padding-right: .5em;
    }
</style>