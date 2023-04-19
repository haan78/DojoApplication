<main>
    
    <div class="form" bind:this={passform}>
        <h3>Parola Değiştir</h3>
        <label>
            <span>Eski Parola</span>
            <input type="password" bind:value={oldpass} />
        </label>
        <label>
            <span>Yeni Parola</span>
            <input type="password" bind:value={newpass} />
        </label>
        <label>
            <span>Tekrar Yeni Parola</span>
            <input type="password" bind:value={repatpass} />
        </label>
        <button disabled={dispass} class="btn" on:click={validatepass}>Parola Değiştir</button>

    </div>

    <div class="form" bind:this={emailform}>
        <h3>E-Posta Değiştir</h3>
        <label>
            <span>Yeni Eposta</span>
            <input type="text" bind:value={newemail} />
        </label>
        <button disabled={disemail} class="btn" on:click={validateemail}>E-Posta Değiştir</button>
    </div>
    <Dialog bind:visible={dlgemailshow}>
        <p style="font-size: large">
            Belirtiğiniz yeni adrese adresine bir doğrulama e-postası gönderildi. E-Posta doğrulamasını onayladıktan sonra. değişiklik gerçekleşecektir.            
            <a href={"javascript:;"} on:click={()=>{ dlgemailshow = false; }}>Kapat</a>
        </p>
    </Dialog>
</main>
<script lang="ts">
    import { onMount } from "svelte";
    import { JRequest } from "../lib/JRequest";
    import validate from "../lib/Vaildate";
    import { Popup } from "./comp/AlertDlg";
    import Dialog from "./comp/Dialog.svelte";
    let oldpass:string = "";
    let newpass:string = "";
    let repatpass:string = "";
    let newemail:string = "";
    let passform:HTMLDivElement;
    let emailform:HTMLDivElement;
    let disemail:boolean = false;
    let dispass:boolean = false;
    let dlgemailshow:boolean = false;
    let popup1: Popup;
    let popup2: Popup;
    onMount(()=>{
        popup1 = new Popup(passform);
        popup2 = new Popup(emailform);
    });

    function validatepass() {
        if (oldpass.trim().length < 1) {
            popup1.push( { message:"Eski parolayı girmeniz gerekiyor.", type: "bad" } );
        } else if (newpass.trim().length < 6) {
            popup1.push({message:"Yeni parola en az 6 karakterden oluşmalı", type:"bad"});
        } else if (repatpass != newpass) {
            popup1.push({message:"Parolanın tekrarı hatalı", type:"bad"});
        } else {
            dispass = true;
            JRequest<void>("/service.php/member/password",{"oldpass":oldpass, "newpass":newpass}).then(()=>{                
                popup1.push({message:"Prolanız başarıyla değiştirildi", type:"good"});                
                dispass = false;
                oldpass = "";
                newpass = "";
                repatpass = "";
            }).catch(err=>{
                popup1.push({message:err.message, type:"bad"});                
                dispass = false;
            });
        }
    }

    function validateemail() {
        if (!validate.email(newemail)) {
            popup2.push({message:"Lütfen geçerli bir eposta adresi girin", type:"bad"});            
        } else {
            disemail = true;
            JRequest<void>("/service.php/member/email",{"email":newemail}).then(()=>{                
                dlgemailshow = true;
                dispass = false;
                newemail = "";
            }).catch(err=>{
                popup2.push({message:err.message, type:"bad"});                 
                dispass = false;
            });
        }
    }
</script>
<style>

    .form {
        display: flex;
        flex-direction: column;
        align-content: flex-start;
        justify-content: flex-start;
    }
    .form > * {
        margin-bottom: 1em;
    }
</style>