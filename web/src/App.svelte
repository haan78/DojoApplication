<script lang="ts">
    import Router from 'svelte-spa-router';
    import pages from "./pages";
    import { store_title } from './store';
    let title:string = "";
    store_title.subscribe(value=>{
        title = value;
    });

</script>
<main class="dojo" >
    <Router routes={pages} />
</main>
<style>
    @import "./assets/app.css";
    @import "./pages/comp/theme.css";
    @import "./pages/comp/Button.css";
</style>