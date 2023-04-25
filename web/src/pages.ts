import {wrap} from 'svelte-spa-router/wrap';
import NotFound from "./pages/NotFound.svelte";

export default {
    "/":wrap({asyncComponent: () =>{        
        return import("./pages/Login.svelte");        
    }}),
    "/welcome":wrap({asyncComponent: () =>{
        return import("./pages/Welcome.svelte");
        /*if (sessionStorage.getItem("authorization")) {
            return import("./pages/Welcome.svelte");
        } else {
            return import("./pages/Login.svelte");
        }*/        
    }}),
    "*":NotFound
}