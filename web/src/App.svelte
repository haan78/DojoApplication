<script lang="ts">
    import Router from 'svelte-spa-router';
    import pages from "./pages";
</script>
<main class="dojo" >
    <div class="header">
        <img src="/logo.png" alt="LOGO" style="vertical-align: middle" />
        <span style="margin-left: .5em; font-weight: bolder; font-size: x-large; ">Ankara Kendo</span>
    </div>
    <div class="body">
        <Router routes={pages} />
    </div>    
</main>
<style>
    @import "./assets/app.css";
</style>