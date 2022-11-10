<script lang="ts">

    import { createEventDispatcher } from "svelte";

    let opclass = "";
    export let value:string;
    export let name:string;
    export let list:Array<string> = [];
    export let minLength=3;
    export let maxListCount=10;

    const onevt = createEventDispatcher();

    $: options = list.filter(option=>{                    
            return value.length >= minLength && option.trim().toLocaleLowerCase().startsWith(value.trim().toLocaleLowerCase());
        }).sort().slice(0,maxListCount);

    function focus() {
        opclass="show";
    }

    function blur() {
        setTimeout(()=>{
            opclass="";
        },550);
        
    }

    function clickinput() {
        opclass = "show";
    }

    function changeinput(evt:Event) {
        onevt("change",evt);
    }

    function optionlink(op:string) {
        value = op;
    }

    function keyup(evt:Event) {
        //console.log(evt);
        opclass = "show";
    }

</script>
<div class="Auto">
    <input type="text" {name} on:focus={focus} on:blur={blur} on:click={clickinput} on:change={changeinput} on:keyup={keyup} bind:value={value} />
    <div class={"list "+( options.length > 0 ? opclass : "")}>
        {#each options as op }
        <a class="option" href={"javascript:;"} on:click={()=>optionlink(op)}>{op}</a>
        {/each}
    </div>
</div>
<style>
    .Auto {
        position: relative;
        display: inline-block;
        width: max-content;
    }

    .Auto > input[type=text] {
        box-sizing: border-box;
    }

    .Auto > .list {
        position: fixed;
        z-index: 999;
        display: none;
        background-color: var(--cl-bg-default);
        width: inherit;
        filter: drop-shadow(.5em .5em var(--br-rd-default) var(--cl-bg-shadow));
        border: var(--br-default);
        border-radius: .3em;
        padding: .3em;
    }

    .Auto > .list > .option {
        border-bottom: var(--br-default);
        cursor: pointer;
        display: block;
        color: var(--cl-tx-info);
        margin-bottom: var(--di-in-default);
    }

    .Auto > .list.show {
        display: block !important;
    }

</style>