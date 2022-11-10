<script lang="ts">
    export let method = "POST";
    export let action = "";
    export let enctype = "multipart/form-data";
    export let form:HTMLFormElement | null = null;

    type ValidateFnc = () => Promise<Boolean>;
    export let validate: ValidateFnc | null = null;

    export function submit() {
        if (form) {
            form.submit();
        }        
    }

    async function submitcontrol(evt: Event) {        
        if ( validate && !await validate() ) {
            evt.preventDefault();
            return false;
        }
        return true;
    }
</script>

<form method={method} action={action} enctype={enctype} on:submit={submitcontrol} bind:this={form} ><slot></slot></form>
