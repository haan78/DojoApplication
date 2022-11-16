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
    <div class="header">
        <img src="/logo.png" alt="LOGO" style="vertical-align: middle" />
        <span style="margin-left: .5em; font-weight: bolder; font-size: x-large; ">Ankara Kendo</span>
    </div>
    <div class="body">
        <div class="content">
            <Router routes={pages} />
        </div>        
    </div>    
</main>
<style>
    @import "./assets/app.css";
    @import "./pages/comp/theme.css";
    @import "./pages/comp/Button.css";
</style>