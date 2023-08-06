<main bind:this={container}>
    {#if loading}
    <span>Loading...</span>
    {:else}
    <table id="tbl1">
        <thead>
            <tr>
                <th class="aka" colspan="2" >Aka</th>                
                <th class="sonuc">Sonuç</th>                
                <th class="shiro" colspan="2" >Shiro</th>                
            </tr>
        </thead>
        <tbody>
            {#each scores as score}
            <tr>
                <td class="aka">{score.aka}</td>
                <td class="aka">
                    <span>{printIppons(score.aka_ippon)}</span>
                    <br/><span>{printHansoku(score.aka_hansoku)}</span></td>
                <td class="sonuc">
                    <span>{@html printSonuc(score.sonuc,new Date(score.tarih))}</span>
                </td>
                <td class="shiro"><span>{printIppons(score.shiro_ippon)}</span><br/><span>{printHansoku(score.shiro_hansoku)}</span></td>
                <td class="shiro">{score.shiro}</td>
            </tr>
            {/each}
        </tbody>
    </table>
    {/if}
</main>
<script lang="ts">
    import { onMount } from 'svelte';
    import { type Score } from '../Types';
    import { JRequest, JRequestError } from '../lib/JRequest';
    import { Popup } from "./comp/AlertDlg";
    let loading:boolean = false;
    let container: HTMLElement;
    let popup : Popup;
    let scores:Array<Score> = [];
    const ipponSymbols = [" M ", " K ", " D ", " T ", " H ", " Ht "];

    function printIppons(ippons:string|null) {
        if (ippons) {
            let str = "";
            for (let i = 0; i < ippons.length; i++) {
                const v = parseInt(ippons[i]);
                if ( typeof v == "number") {
                    str += ipponSymbols[v];
                }            
            }
            return str.trim();
        } else {
            return "";
        }
        
    }
    function printHansoku(num:number) {
        let str = "";
        for (var i = 0; i < num; i++) {
            str += " ▲ ";
        }
        return str.trim();
    }
    function printSonuc(sonuc:string, tarih:Date) {
        let str = "";
        if (sonuc == "G") {
            str = "<b style='color:green'>Galibiyet</b>"
        } else if (sonuc == "M") {
            str = "<b style='color:red'>Mağlubiyet</b>";
        } else {
            str = "<b style='color:black'>Beraberlik</b>";
        }
        str += "<br/>";
        str += tarih.toLocaleDateString('TR-tr');
        return str;

    }

    onMount(()=>{    
        popup = new Popup(container);
        loading = true;
        JRequest<Array<Score>>("/service.php/member/scores").then( response=>{
            loading = false;
            scores = response;
        }).catch((err:JRequestError)=>{
            loading = false;
            popup.push({message:err.message, type:"bad"});
        });
    });
</script>
<style>
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

    #tbl1 > thead > tr > th.aka {
        text-align: left;
    }

    #tbl1 > thead > tr > th.shiro {
        text-align: right;
    }

    #tbl1 > thead > tr > th.sonuc {
        text-align: center;
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

    #tbl1 > tbody > tr > td.aka {
        text-align: left;
        background-color: red;
    }

    #tbl1 > tbody > tr > td.shiro {
        text-align: right;
        background-color: white;
    }

    #tbl1 > tbody > tr > td.sonuc {
        text-align: center;
        background-color: gainsboro;
    }

    #tbl1 > tbody > tr:nth-child(even) {
        background-color: rgb(221, 223, 224);
    }

    #tbl1 td, #tbl1 th {
        padding: 1em;
    }
</style>