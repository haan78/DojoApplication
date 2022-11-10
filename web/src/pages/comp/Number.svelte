<script>
    import { createEventDispatcher,onMount } from 'svelte';
    export let min = 0;
    export let max = 999;
    export let value = min;
    export let width = '5em';
    export let step = 1;

    let dispatch = createEventDispatcher();

    onMount(()=>{
        if (typeof min !== "number") {
            min = 0;
        }
        if (typeof max !== "number") {
            max = 999;
        }
        if ( !width ) {
            width = "5em";
        }
        if (typeof step !== "number") {
            step = 1;
        }
    });

    function changeevt() {
        var oldval = value;
        if (value<min) {
            value = min;
        } else if (value > max) {
            value = max;            
        }
        dispatch("change",{ new:value,old:oldval });        
    }

</script>
<input type="number" bind:value={value} max={max} min={min} on:change={changeevt} class="NumberInput" style="width: {width};" />
<style>
    .NumberInput {
        font-weight: inherit;
    }
</style>

