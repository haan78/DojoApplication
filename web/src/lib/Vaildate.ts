export default {
    tckn(tckn:string):boolean {
        return /^[0-9]{11}$/.test(tckn);
    },
    email(email:string):boolean {
        return /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(email.trim().toLocaleLowerCase());
    },
    gsm(num:string):string {
        var f = num.trim().replace(/\s|\-/gi,"");
        if (f.startsWith("0")) {
            f = f.substring(1);
        }
        if ( /^5[0-9]{9}$/.test(f) ) {            
            return "0"+f.substring(0, 3)+" "+f.substring(3, 6)+" "+f.substring(6, 8)+" "+f.substring(8, 10);
        } else {            
            return "";
        }
    }
}