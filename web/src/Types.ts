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
export function trDate(isodate:string|null ) : string {
    if (isodate) {
        if (/^[1-9][0-9]{3}-[0-1][0-9]-[0-9]{2}$/.test(isodate)) {
            return (new Date(<string>isodate)).toLocaleDateString();
        }
    }
    return "";
}

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
    tahakkuk_id:number,
    file_type:string,
    borcbilgi:string
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
    Array<UyeYoklama>
]