<script lang="ts">
    import Router from 'svelte-spa-router';
    import pages from "./pages";

</script>
<main class="dojo" >
    <Router routes={pages} />
</main>
<style>
    @import "./assets/app.css";
    @import "./pages/comp/theme.css";
    @import "./pages/comp/Button.css";
</style>