<script lang="ts">
    import Popup from "./Popup.svelte";

    import { SettingsIcon,LogOutIcon } from "svelte-feather-icons";
    import { createEventDispatcher } from "svelte";
    let popup: Popup;
    export let foregroundColor:string = "gold";
    export let backgroundColor:string = "black";
    export let logo:string = "./logo.png"
    export let title:string = "";
    const eventDispatcher = createEventDispatcher();

    function onExit() {
        eventDispatcher("exit",null);
    }

</script>

<div class="header" style="--foreground-color:{foregroundColor}; --background-color:{backgroundColor};" >
    <div class="left">
        <img src={logo} alt="LOGO" style="vertical-align: middle" />
        <span
            style="margin-left: .5em; font-weight: bolder; font-size: x-large; "
            >{title}</span
        >
    </div>
    <div class="right">
        {#if $$slots.settings}
            <a
                href={"javascript:;"}
                on:click={(event) => {
                    if (popup.toggle) popup.toggle(event);
                }}><SettingsIcon size="1.5x" /></a
            >
            <Popup bind:this={popup}>
                <slot name="settings" />
            </Popup>
        {/if}
        {#if $$slots.exit}
            <a href={"javascript:;"} on:click={onExit} ><LogOutIcon size="1.5x" /><slot name="exit" /></a>
        {/if}
    </div>
</div>

<style>
    .header {
        background-color: var(--background-color);
        color: var(--foreground-color);
        display: flex;
        padding: 0.5em;
        justify-content: space-between;
        align-items: center;
    }

    .header > .left {
        height: 3em;
        display: flex;
        justify-content: left;
        align-items: center;
        padding: .3em;
    }

    .right > a {
        color: var(--foreground-color);
        padding: .5em;
    }
</style>
