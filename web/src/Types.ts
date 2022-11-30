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