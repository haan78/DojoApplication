import {wrap} from 'svelte-spa-router/wrap';
import Login from "./pages/Login.svelte";
import NewMember from "./pages/NewMember.svelte";
import PasswordReset from "./pages/PasswordReset.svelte";
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
    "/password-reset":PasswordReset,
    "/password-change":wrap({asyncComponent: () =>{
        if (checkAuth()) {
            return import("./pages/PasswordChange.svelte");
        } else {
            return import("./pages/NotAuth.svelte");
        }
        
    }}),
    "*":NotFound
}