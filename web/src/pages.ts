import {wrap} from 'svelte-spa-router/wrap';
import NotFound from "./pages/NotFound.svelte";

function checkAuth():boolean {
    if (sessionStorage.getItem("bearer-auth")) {
        return true;
    } else {
        console.log(["Autfalse",sessionStorage.getItem("bearer-auth")]);
        return false;
    }
}

export default {
    "/":wrap({asyncComponent: () =>{
        sessionStorage.removeItem("bearer-auth");
        return import("./pages/Login.svelte");        
    }}),
    "/welcome":wrap({asyncComponent: () =>{
        if (checkAuth()) {
            return import("./pages/Welcome.svelte");
        } else {
            return import("./pages/Login.svelte");
        }        
    }}),
    "*":NotFound
}