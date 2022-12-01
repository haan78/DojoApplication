import { get,writable } from 'svelte/store';

export interface UserData {
    ad:string;
    email:string;
    durum:string;
    token:string;
    uye_id:number;
}

export function getUserData() : UserData {
    return <UserData>get(store_user);
}


export const store_user = writable(<UserData>{
    ad:"",
    email:"",
    durum:"",
    token:"",
    uye_id:0
});