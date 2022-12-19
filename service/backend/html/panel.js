function raise(err, level) {
    var div = document.createElement("div");
    div.className = "AlertError";
    div.innerHTML = (typeof err === "string" ? err : err.toString() ) + "/ "+level;    
    document.body.append(div);
    setTimeout(() => {
        div.remove();
    }, 4000);
}
function isEmail(email) {
    return /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(email.trim().toLocaleLowerCase());
}
function callback(data) {
    if (typeof MobileApp !== "undefined") {
        MobileApp.postMessage(JSON.stringify(data));
    } else if (window.parent) {
        window.parent.postMessage(data,"*");
    }
}

function resetformsubmit(btn) {
    if ( btn.getAttribute("data-loading") ) {
        return;
    }
    var code = document.querySelector("input[name=code]").value.trim();
    var pass = document.querySelector("input[name=new]").value.trim();
    var _repeat = document.querySelector("input[name=repeat]").value.trim();
    var captcha = document.querySelector("[name=h-captcha-response]").value.trim();

    if (pass.length < 6) {
        raise("Parola en az 6 karakter olmalı", 1);
        return;
    }

    if (pass != _repeat ) {
        raise("Parola terarıyla uyuşmuyor", 1);
        return;
    }

    if (!captcha) {
        raise("Captcha doğrulaması gerekli", 1);
        return;
    }

    btn.setAttribute("data-loading","loading");
    btn.querySelector("img").style.display = "inline-block";

    fetch("service.php/reset",{method: "POST",
    cache: 'no-cache',
    body: JSON.stringify({
        "captcha": captcha,
        "password":pass,
        "code":code
    })}).then(raw=>{
        btn.setAttribute("data-loading","");
        btn.querySelector("img").style.display = "none";
        raw.json().then(response => {
            if (response.success) {
                window.location.href = "/?m=login";
            } else {                
                raise(response.data.message, 4);
            }
        }).catch(err => {
            raise(err, 3);
        });
    }).catch(err=>{
        btn.setAttribute("data-loading","");
        raise(err, 2);
    });
}

function emailformsubmit(btn) {
    if ( btn.getAttribute("data-loading") ) {
        return;
    }
    var email = document.querySelector("input[name=email]").value.trim();
    var captcha = document.querySelector("[name=h-captcha-response]").value.trim();
    if (!isEmail(email)) {        
        raise("E-Posta formatı doğru değil", 1);
        return;
    }

    if (!captcha) {
        raise("Captcha doğrulaması gerekli", 1);
        return;
    }

    btn.setAttribute("data-loading","loading");
    btn.querySelector("img").style.display = "inline-block";

    fetch("service.php/email",{method: "POST",
    cache: 'no-cache',
    body: JSON.stringify({
        "captcha": captcha,
        "email":email
    })}).then(raw=>{
        btn.setAttribute("data-loading","");
        btn.querySelector("img").style.display = "none";
        raw.json().then(response => {
            if (response.success) {
                window.location.href = "/?m=reset"
            } else {                
                raise(response.data.message, 4);
            }
        }).catch(err => {
            raise(err, 3);
        });
    }).catch(err=>{
        btn.setAttribute("data-loading","");
        raise(err, 2);
    });
}

function loginformsubmit(btn) {
    if ( btn.getAttribute("data-loading") ) {
        return;
    }
    var user = document.querySelector("input[name=username]").value.trim();
    var pass = document.querySelector("input[name=password]").value.trim();
    var captcha = document.querySelector("[name=h-captcha-response]").value.trim();
    var type = document.querySelector("input[name=type]").value.trim();

    if (!isEmail(user)) {
        console.log(user);
        raise("E-Posta formatı doğru değil", 1);
        return;
    }

    if (pass.length < 6) {
        raise("Parola en az 6 karakter olmalı", 1);
        return;
    }

    if (!captcha) {
        raise("Captcha doğrulaması gerekli", 1);
        return;
    }

    btn.setAttribute("data-loading","loading");
    btn.querySelector("img").style.display = "inline-block";
    fetch("service.php/token", {
        method: "POST",
        cache: 'no-cache',
        body: JSON.stringify({
            "type":type,
            "captcha": captcha
        }),
        headers: {
            "Content-Type": "application/json; charset=utf-8",
            "authorization": "Basic " + btoa(user + ":" + pass)
        }
    }).then(raw => {
        btn.setAttribute("data-loading","");
        btn.querySelector("img").style.display = "none";
        //console.log(raw.body);
        raw.json().then(response => {
            if (response.success) {
                response.data.password = pass;
                callback(response.data);
            } else {                
                raise(response.data.message, 4);
            }
        }).catch(err => {
            raise(err, 3);
        });
    }).catch(err => {
        btn.setAttribute("data-loading","");
        raise(err, 2);
    });
}
