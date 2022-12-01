// @ts-strict
export interface Due {
    uye_tahakkuk_id:string,
    ay:number,
    yil:number,
    tahakkuk_tarih:string,
    tanim:string,
    odeme_tutar:number | null,
    borc:number,
    odeme_tarih:string | null,
    muhasebe_id:string |null,
    yoklama:string,
    yoklama_id:string,
    keikolar:string
}

export const Aylar = ["Ocak","Şubat","Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];

export interface MemberInfo {
    ad:string;
    cinsiyet:string;
    dogum_tarih:string;
    dosya_id:number,
    ekfno:string,
    email:string,
    img64:string,
    son3Ay:number,
    tahakkuk:string,
    tahakkuk_id:number
}

export interface Level {
    uye_seviye_id:number,
    aciklama:string,
    tarih:string,
    seviye:string
}

export interface UyeYoklama {
    tarih:string,
    yoklama_id:number,
    tanim:string
}

export type Uyebilgi = [
    Array<MemberInfo>,
    Array<Level>,
    Array<Due>,
    Array<UyeYoklama>
]