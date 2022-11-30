<main>
    <h2>Aidatlar</h2>
    <div class="list">
        <div class="header" >
            <div style="width: 1.2em">#</div>
            <div style="width: 3em">Yıl</div>
            <div style="width: 4em">Ay</div>
            <div style="width: 4em">Çal.</div>
            <div style="width: 5em">Tutar</div>
            <div style="width: 5em">Bilgi</div>
        </div>
        <div class="body">
            {#each dues as due,ind}
            <div class={ `row ${due.muhasebe_id ? "" : "alert"}` }>
                <div style="width: 1.2em">
                    {#if due.muhasebe_id}<CheckCircleIcon size="1x" />{:else}<AlertCircleIcon size="1x" />{/if}
                </div>
                <div style="width: 3em">{due.yil}</div>
                <div style="width: 4em">{aytr(due.ay)}</div>
                <div style="width: 4em">{due.yoklama}</div>
                <div style="width: 5em;">
                    {#if due.muhasebe_id}
                    <span style="color: darkgreen">Ödendi</span>
                    {:else}
                    <span style="color: brown">{due.borc}</span>
                    {/if}
                </div>
                <div style="width: 5em">
                    <a href={"javascript:;"} on:click={()=>{bilgi(due)}}><HelpCircleIcon size="2x" /></a>
                </div>
            </div>
            {/each}
        </div>
    </div>
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
    import { AlertCircleIcon, CheckCircleIcon,HelpCircleIcon } from 'svelte-feather-icons';
    import { Aylar, type Due } from "../Types";
    import Dialog from "./comp/Dialog.svelte";
    export let dues:Array<Due> = [];
    let showdlg:boolean = false;
    let tarihler:Array<Date> = [];
    let dlgtitle:string;
    function aytr(num:number) {
        return Aylar[num-1];
    }

    function bilgi(due:Due) {
        tarihler = [];
        dlgtitle = `${due.yoklama} ${due.yil} / ${Aylar[due.ay-1]}`;
        due.keikolar.split(",").forEach((value,ind)=>{
            const d = new Date(value);
            tarihler.push(d);
        });
        showdlg = true;

    }

    onMount(()=>{

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
    .list {
        display: flex;
        width: 100%;
        height: 100%;
        flex-direction: column;
        align-content: flex-start;        
        justify-content: start;
    }

    .list > .header {
        display: flex;

        flex-direction: row;
        align-content: flex-start;        
        justify-content: start;
        flex-wrap: nowrap;
    }
    .list > .header > div {        
        border-bottom: solid 2px black;
        padding-left: .5em;
        padding-bottom: .5em;
        display: flex;
        justify-content: start;
        align-content: center;
        font-weight: bolder;

    }
    .list > .body {
        display: flex;
        width: 100%;
        flex-direction: column;
        align-content: flex-start;        
        justify-content: start;
        overflow-y:scroll; 
        max-height: 30em; 
    }

    .list > .body > .row {
        display: flex;

        flex-direction: row;
        align-content: flex-start;        
        justify-content: start;
        flex-wrap: nowrap;
        background-color: white;
    }
    .list > .body > .row:nth-child(even) > div {
        background-color: rgb(221, 223, 224);
    }
    
    .list > .body > .row > div:first-child {
        color: darkgreen;
    }
    .list > .body > .row > div {
        padding-top: .7em;
        padding-bottom: .7em;
        border-bottom: solid 1px black;
        padding-left: .5em;
        display: flex;
        align-content: center;        
        justify-content: start;
        flex-wrap: wrap;
    }
    .list > .body > .row.alert {
        font-weight: bold;
    }
    .list > .body > .row.alert > div:first-child{
        color: brown;
    }
</style>