<script lang="ts">
    let showdd: boolean = false;
    let btnc: boolean = false;
    let element: HTMLElement;
    let pos = {
        left: "auto",        
        top: "auto"
    };
    export function toggle(event: MouseEvent) {
        btnc = true;
        showdd = !showdd;
        if (showdd) {
            setTimeout(() => {
                const width = element.offsetWidth;
                const height = element.offsetHeight;                
                if (window.innerWidth  - 12 < event.pageX + width) {
                    pos.left = (window.innerWidth  - width - 12) + "px";

                } else {
                    pos.left = event.pageX + "px";
                }

                if (window.innerHeight - 10 < event.pageY + height) {
                    pos.top = (event.pageY - height - 12) + "px";                    
                } else {
                    pos.top = event.pageY + "px";                    
                }
            }, 5);
        }
    }

    function closebtn() {
        if (!btnc) showdd = false;
        btnc = false;
    }
</script>

<div
    class="popup"
    bind:this={element}
    style:display={showdd ? "block" : "none"}
    style:top={pos.top}
    style:left={pos.left}
>
    <slot />
</div>

<svelte:body on:click={closebtn} />

<style>
    .popup {
        display: inline-block;
        position: fixed;
        right: auto;        
        bottom: auto;
        z-index: 999;
    }
</style>
