<script lang="ts">
    import Popup from "./Popup.svelte";
    export let settings: boolean = false;
    import { SettingsIcon } from "svelte-feather-icons";
    let popup: Popup;
    export let foregroundColor:string = "gold";
    export let backgroundColor:string = "black";
    export let logo:string = "/logo.png"
    export let title:string = "";
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
        {#if settings}
            <a
                href={"javascript:;"}
                on:click={(event) => {
                    popup.toggle(event);
                }}><SettingsIcon size="1.5x" /></a
            >
            <Popup bind:this={popup}>
                <slot name="settings" />
            </Popup>
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
    }

    .right > a {
        color: var(--foreground-color);
    }
</style>
