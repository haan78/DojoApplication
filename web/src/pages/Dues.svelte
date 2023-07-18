<main bind:this={container}>
    {#if loading}
    <span>Loading...</span>
    {:else}
    <table id="tbl1">
        <thead>
            <tr>
                <th></th>
                <th>Ay/Yıl</th>                
                <th>Çalışma</th>
                <th>Tutar</th>            
            </tr>
        </thead>
        <tbody>
            {#each dues as due}
            <tr style:color={due.muhasebe_id ? "darkgreen" : "brown"} on:click={()=>{bilgi(due)}} >
                <td>
                    {#if due.muhasebe_id}<CheckCircleIcon size="1.5x" />{:else}<AlertCircleIcon size="1.5x" />{/if}
                </td>
                <td>{aytr(due.ay)}/{due.yil}</td>
                <td>{due.yoklama}</td>
                <td>{#if due.muhasebe_id}
                    <span style="color: darkgreen">Ödendi</span>
                    {:else}
                    <span style="color: brown; font-weight: bold;">{due.borc}</span>
                    {/if}
                </td>                
            </tr>
            {/each}
        </tbody>
    </table>
    {/if}
    
    <Dialog bind:visible={showdlg}>
        <fieldset class="dlg">
            <legend>{dlgtitle}</legend>
            <ul>
                {#each tarihler as tarih }
                <li>{tarih.toLocaleDateString()}</li>
                {/each}                
            </ul>
        </fieldset>
    </Dialog>
    
</main>
<script lang="ts">
    import { onMount } from 'svelte';
    import { AlertCircleIcon, CheckCircleIcon } from 'svelte-feather-icons';
    import { Aylar, type Due } from "../Types";
    import Dialog from "./comp/Dialog.svelte";    
    import {JRequest } from "../lib/JRequest";
    import type { JRequestError } from "../lib/JRequest";
    import { Popup } from "./comp/AlertDlg";
    let dues:Array<Due> = [];
    let showdlg:boolean = false;
    let tarihler:Array<Date> = [];
    let dlgtitle:string;
    let popup : Popup;
    let container: HTMLElement;
    let loading:boolean = false;
    function aytr(num:number) {
        return Aylar[num-1];
    }

    function bilgi(due:Due) {
        tarihler = [];
        dlgtitle = `Ay içinde katıdığınız keikolar ${due.yoklama} ${due.yil} / ${Aylar[due.ay-1]}`;
        due.keikolar.split(",").forEach((value,ind)=>{
            const d = new Date(value);
            tarihler.push(d);
        });
        showdlg = true;

    }

    onMount(()=>{
        popup = new Popup(container);
        loading = true;
        JRequest<Array<Due>>("/service.php/member/tahakkuk/list").then( response=>{
            loading = false;
            dues = response;
        }).catch((err:JRequestError)=>{
            loading = false;
            popup.push({message:err.message, type:"bad"});
        });
    });
</script>
<style>
    .dlg {
        width: 13em;
        margin: 1em;
    }
    .dlg > ul > li {
        margin-bottom: .5em;
    }

    #tbl1 {
        width: 100%;
        border-collapse: collapse;
    }

    #tbl1 > thead {
        display: block;
        padding-right: 1rem;
    }

    #tbl1 > thead > tr > th {
        text-align: left;
        border-bottom: solid 1px black;
    }

    #tbl1 > thead > tr, #tbl1 > tbody > tr {
        display: table;
        width: 100%;
        table-layout: fixed;/* even columns width , fix width of table too*/
    }

    #tbl1 > tbody {
        max-height: 80vh;
        overflow-y: scroll;
        overflow-x: hidden;
        display: block;
        width: 100%;
    }

    #tbl1 > tbody > tr {
        cursor: pointer;
        padding-top: .7em;
    }

    #tbl1 > tbody > tr > td {
        padding-top: .7em;
        border-bottom: solid 1px black;
    }

    #tbl1 > tbody > tr:nth-child(even) {
        background-color: rgb(221, 223, 224);
    }
</style>