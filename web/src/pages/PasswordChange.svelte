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
    
</main>
<script lang="ts">
    import { onMount } from "svelte";
    import { JRequest } from "../lib/JRequest";
    import validate from "../lib/Vaildate";
    import Alert from "./comp/Alert.js";
    let oldpass:string = "";
    let newpass:string = "";
    let repatpass:string = "";
    let newemail:string = "";
    let passform:any;
    let emailform:any;
    let altpass:any;
    let altemail:any;
    let disemail:boolean = false;
    let dispass:boolean = false;
    onMount(()=>{
        altpass = Alert(passform);
        altemail = Alert(emailform);
    });

    function validatepass() {
        if (oldpass.trim().length < 1) {
            if (altpass.bad) altpass.bad("Eski parolayı girmeniz gerekiyor.");
        } else if (newpass.trim().length < 6) {
            if (altpass.bad) altpass.bad("Yeni parola en az 6 karakterden oluşmalı");
        } else if (repatpass != newpass) {
            if (altpass.bad) altpass.bad("Parolanın tekrarı hatalı");
        } else {
            dispass = true;
        }
    }

    function validateemail() {
        if (!validate.email(newemail)) {
            if (altemail.bad) altemail.bad("Lütfen geçerli bir eposta adresi girin");
        } else {
            disemail = true;
            JRequest()
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