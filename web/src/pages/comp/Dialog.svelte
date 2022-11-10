<script>
// @ts-nocheck

    import { createEventDispatcher,onMount } from 'svelte';
    
    const dispatch = createEventDispatcher();

    export let visible = false;
    
    function show() {
        dispatch('show',null);
    }

    function close(handler) {
        visible = false;
        dispatch('close',{ by:handler});
    }

    onMount(()=>{
        show();
    });
</script>
<main>
    {#if (visible)}
    <div id="background"  on:click={()=>close('bg')}></div>
    <div id="modal">
        <span on:click={()=>close('x')}>&#x2715</span>
        <slot></slot>
    </div>
    {/if}
</main>
<style>
    #background {
        position: fixed;
        z-index: 998;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
    }

    #modal {
        position: fixed;
        z-index: 999;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: #fff;
        filter: drop-shadow(0 0 20px #333);
        padding: 1em;
    }

    #modal > span {
        position: absolute;
        top: 0px;
        right:0px;
        cursor: pointer;
        font-weight: bolder;
        color: darkred;
        margin-right: 4px;
    }
</style>