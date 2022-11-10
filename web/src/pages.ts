import {wrap} from 'svelte-spa-router/wrap';
import Login from "./pages/Login.svelte";
import NewMember from "./pages/NewMember.svelte";
import NotFound from "./pages/NotFound.svelte";
import { getCookie } from 'typescript-cookie';

function checkAuth():boolean {
    if (getCookie("authorization")) {
        return true;
    } else {
        return false;
    }
}

export default {
    "/":Login,
    "/new":NewMember,
    "/password":wrap({asyncComponent: () =>{
        if (checkAuth()) {
            return import("./pages/PasswordReset.svelte");
        } else {
            return import("./pages/NotAuth.svelte");
        }
        
    }}),
    "*":NotFound
}