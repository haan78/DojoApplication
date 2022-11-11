function loadlogin() {
    document.querySelector(".login input[name=username]").value = localStorage.getItem("ankarakendo-login-user") ?? "";
    document.querySelector(".login input[name=password]").value = localStorage.getItem("ankarakendo-login-pass") ?? "";
}


function raise(err, level) {
    document.querySelector(".footer").innerHTML = err.toString();
    setTimeout(()=>{
        document.querySelector(".footer").innerHTML="";
    },4000);
}

function callback(data) {
    console.log(data)
}

function loginformsubmit() {
    var user = document.querySelector(".login input[name=username]").value;
    var pass = document.querySelector(".login input[name=password]").value;
    var captcha = document.querySelector(".login [name=h-captcha-response]").value;

    if (user && pass && captcha) {
        fetch("service.php/token", {
            method: "POST",
            cache: 'no-cache',
            body: JSON.stringify({
                "captcha": captcha
            }),
            headers: {
                "Content-Type": "application/json; charset=utf-8",
                "authorization": "Basic " + btoa(user + ":" + pass)
            }
        }).then(raw => {
            console.log(raw.text());
            raw.json().then(response => {
                if (response.success) {
                    localStorage.setItem("ankarakendo-login-user", user);
                    localStorage.setItem("ankarakendo-login-pass", pass);
                    callback(response.data);
                } else {
                    console.log("iceri");
                    raise(response.data, 4);
                }
            }).catch(err => {
                raise(err, 3)
            })
        }).catch(err => {
            raise(err, 2);
        });
    } else {
        raise("user, pass or captcha ", 1);
    }
}