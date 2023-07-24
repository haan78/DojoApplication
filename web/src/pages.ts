import NotFound from "./pages/NotFound.svelte";
import Welcome from "./pages/Welcome.svelte";
import Login from "./pages/Login.svelte";


export default {
    "/":Login,
    "/welcome":Welcome,
    "*":NotFound
}