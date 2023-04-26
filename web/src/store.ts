import { get,writable } from 'svelte/store';

export interface UserData {
    ad:string;
    email:string;
    durum:string;
}

export function getUserData() : UserData {
    return <UserData>get(store_user);
}

function getUserDataFromLocal() : UserData {
    const json = localStorage.getItem("UserData");
    if (json) {
        return <UserData>JSON.parse(json);
    } else {
        return <UserData>{
            ad:"",
            email:"",
            durum:""            
        };
    }
}
export const store_user = writable(getUserDataFromLocal());
export const store_status = writable(false);
export function isLoggedIn():boolean {
    console.log(store_status);
    return <boolean>get(store_status);
}


store_user.subscribe(value=>{
    localStorage.setItem("UserData",JSON.stringify(value));
});