<main>
    <AppBar title="Ankara Kendo" on:exit={exit}>
        <span slot="exit"></span>
    </AppBar>
    <div class="container">
        {#if (module != "Error" && module != "Loading")}
        <div class="settings">            
            <a class:active={module=="Member"}  href={'javascript:;'} on:click={()=>{ module="Member"; }}><UserIcon size="1x" /> Üye Bilgisi</a>
            <a class:active={module=="Dues"}  href={'javascript:;'} on:click={()=>{ module="Dues"; }}><CreditCardIcon size="1x" /> Aidatlar</a>
            <a class:active={module=="Scores"} href={'javascript:;'} on:click={()=>{ module="Scores"; }}><CreditCardIcon size="1x" /> Çalışmalar</a>
            <a class:active={module=="PasswordChange"} href={'javascript:;'} on:click={()=>{ module="PasswordChange"; }}><KeyIcon size="1x" /> Parola Değiştir</a>
        </div>
        {/if}
    <div>
        {#if module=="PasswordChange"}
        <PasswordChange />
        {:else if module == "Dues"}
        <Dues/>
        {:else if module == "Scores"}
        <Scores/>
        {:else if module == "Loading"}
        <img src="loading.svg" alt="" />
        {:else if module == "Error"}
        <h2>Sistemede bir hata oluştur</h2>
        <p style="color: brown;">{detail}</p>
        {:else}
    <div class="info">
        <div class="left">
            <img class="foto" src="/img.php/member" alt="" />
            <p>Üyelik bilgilerinizle ilgili bir sorun olduğunu düşüyor veya resminizi değiştirmek istiyorsanız. Lütfen çalışmadaki yetkili <i>Senpai</i> ile temasa geçin</p>
        </div>
        <div class="labels">
            <span><b>Üye</b>{info.ad}</span>            
            <span><b>Üyelik Tipi / Durumu</b> {info.tahakkuk} / {durum}</span>
            <hr/>            
            <span><b>Seviye</b>{level.seviye}</span>
            <span><b>Seviye Tar.</b>{ trDate(level.tarih)}</span>            
            <hr/>        
            <span><b>Son Çal.</b>{attendances[0] ? ( trDate(attendances[0].tarih) ) + " / " + attendances[0].tanim : "" }</span>
            <span><b>Son 3 Ay Çal.</b>{info.son3Ay}</span>
            <hr/>
            {#if borcbilgiparse(info.borcbilgi,1) != -1}            
            <a href={'javascript:;'} on:click={()=>{module="Dues"}} style="color: red;">
            <span><b>Ödenmemiş aidta Sayısı </b>{borcbilgiparse(info.borcbilgi,1)}</span><br/>
            <span><b>Toplma Aidat Borcu </b>{borcbilgiparse(info.borcbilgi,2)} TL</span>
            </a>
            {:else}
            <span style="color:green; font-weight: bold;">Ödenmemiş Aidat Borsunuz Bulunmamaktadır</span>
            {/if}
            <hr/>
            <span><a href="kyu_sinavi_icerigi.html" target="_blank">Kyu Sınavı Yönetmeliği</a></span>
        </div>
    </div>
        {/if}
    </div>
</div>
</main>

<script lang="ts">
    // @ts-strict
    import { KeyIcon, UserIcon, CreditCardIcon } from 'svelte-feather-icons';
    import { push } from "svelte-spa-router";
    import PasswordChange from './PasswordChange.svelte';
    import Dues from './Dues.svelte';
    import Scores from './Scores.svelte';   
    import { onMount } from "svelte";
    import {JRequest } from "../lib/JRequest";
    import type { JRequestError } from "../lib/JRequest";
    import { type Due, type MemberInfo, type Level, type UyeYoklama, type Uyebilgi, trDate } from "../Types";
    import AppBar from "./comp/AppBar.svelte";
    import { getUserData } from '../store';

    let durum:string;
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
        file_type:"",
        borcbilgi:""
    };
    let levels:Array<Level> = [];
    let attendances:Array<UyeYoklama> = [];
    let level:Level = {
        aciklama:"",
        seviye:"",
        tarih:"",
        uye_seviye_id:0
    }


    let module:string = "";
    let detail:string = "";

    function borcbilgiparse(borcbilgi:string,part:number):number {
        if (borcbilgi) {
            const arr = borcbilgi.split(" ");
            if (arr[part-1]) {
                return parseFloat(arr[part-1]) || -1;            
            } else {
                return -1;
            }
        } else {
            return -1;
        }
        
    }

    function exit() {
        JRequest<void>("/service.php/member/logout").then(()=>{
            push("/");
        });
    }

    onMount(()=>{
        durum = getUserData().durum;
        module = "Loading";
        JRequest<Uyebilgi>("/service.php/member/bilgi").then(response=>{
            levels = response[1];
            if (levels[0]) {
                level = levels[0];
            };
            attendances = response[2];
            duelist = [] //response[2];
            info = response[0][0];
            module = "Member";
        }).catch((err:JRequestError)=>{            
            if (err.status == 401) {
                push("/");
            } else {
                detail = err.message;
                module = "Error";
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
        flex-direction: column;
    }

    .info > .left {
        display: flex;
        flex-direction: row;        
        flex-wrap: nowrap;
    }

    .info > .left > img {
        width: auto;
        height: auto;
        max-width: 10em;
        flex: 1 1 0;
    }

    .info > .left > p {
        width: 60%;
        padding-left: 1em;
        flex-basis: 1;
    }

    .labels {
        padding-top: .5em;
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

    .labels > span > b {
        padding-right: .5em;
    }
</style>