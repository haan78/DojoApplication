import {wrap} from 'svelte-spa-router/wrap';

// @ts-ignore
import NotFound from "./pages/NotFound.svelte";
// @ts-ignore
import Welcome from "./pages/Welcome.svelte";
// @ts-ignore
import Login from "./pages/Login.svelte";


export default {
    "/":wrap({asyncComponent: () =>{        
        return Login;        
    }}),
    "/welcome":wrap({asyncComponent: () =>{  
        return Welcome;
    }}),
    "*":NotFound
}