<main>
    <h1>New Memeber</h1>
    <button type="button" on:click={login}>Login</button>
</main>
<script lang="ts">
    import {push, pop, replace} from 'svelte-spa-router';
    function login() {
        push("/");
    }
</script>

