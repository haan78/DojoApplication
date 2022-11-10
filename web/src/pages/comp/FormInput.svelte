<script lang="ts">
    import { onMount } from "svelte";
    let _message = "";

    export function message(message: string = "", time: number = 0) {
        if (message) {
            _message = message;
            if (time) {
                setTimeout(() => {
                    _message = "";
                }, time);
            }
        } else {
            _message = "";
        }
    }
    export let title = "";
    export let position = "top";

    onMount(() => {
        _message = "";
    });
</script>

<label class="FormInput" data-pos={position} title={title ?? ""}>
    <span class="lbl">
        <slot name="label" />
    </span>
    <span class="inp">
        <div class="inpline">            
            <div class="input"><slot name="input" /></div>
            {#if $$slots.icon  }
            <div class="icon"><slot name="icon"/></div>
            {/if}
            
        </div>        
        <div class="subline">
            {#if !_message}
                <i class="info"><slot name="info" /></i>
            {:else}
                <i class="alert">{_message}</i>
            {/if}
        </div>
    </span>
</label>

<style>
    .FormInput {
        margin-bottom: 1em;
        display: flex;
        flex-wrap: nowrap;
        flex-direction: column;
        vertical-align: middle;
        align-items: flex-start;
        padding: var(--di-in-default);
    }

    .FormInput[data-pos=left] {
        flex-direction: row;
    }

    .FormInput[data-pos=left] > span.lbl {
        margin-right: var(--di-in-default);
    }

    .FormInput[data-pos=top] > span.lbl {
        margin-bottom: cal(var(--di-in-default)/2);
    }

    .FormInput > span.lbl {
        font-weight: bold;
    }

    .FormInput > span.inp {
        width: 100%;
    }

    .FormInput > span.inp > .subline {
        font-size: smaller;
    }

    .FormInput > span.inp > .subline > .info {
        color: var(--cl-tx-info);
    }

    .FormInput > span.inp > .subline > .alert {
        color: var(--cl-tx-bad);
        font-weight: bold;
    }
    .FormInput > span.inp > .inpline {
        display: flex;
        width: 100%;
        flex-direction: row;
    }
    .FormInput > span.inp > .inpline > div {
        position: relative;
    }
    .FormInput > span.inp > .inpline > div.icon {
        flex: 0;
        display: flex;
        align-items: center;
        padding-left: .2em;
        color: var(--cl-tx-info);
        font-size: large;
    }
    .FormInput > span.inp > .inpline > div.input {
        flex: 1;
        width: 100%;
    }
</style>
