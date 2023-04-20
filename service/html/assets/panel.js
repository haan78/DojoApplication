function raise(err, level,seconds) {
    var div = document.createElement("div");
    div.className = "AlertError";
    div.innerHTML = (typeof err === "string" ? err : err.toString() );    
    document.body.append(div);
    return new Promise((resolve,reject)=>{
        setTimeout(() => {
            div.remove();
            resolve();
        }, seconds || 4000);
    });
}

function success(message,seconds) {
    var div = document.createElement("div");
    div.className = "AlertSuccess";
    div.innerHTML = message;    
    document.body.append(div);
    return new Promise((resolve,reject)=>{
        setTimeout(() => {
            div.remove();
            resolve();
        }, seconds || 4000);
    });
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

function entryButton() {
    document.querySelectorAll("button.entry").forEach(elm=>{
        var title = elm.innerHTML;
        console.log(title);
        elm.innerHTML = `<img src="assets/loading.svg"/>
        <span>${title}</span>`;
        elm.showLoading=function() {
            this.disabled = true;
            this.querySelector("img").style.display="inline-block";
        };
        elm.hideLoading=function() {
            this.disabled = false;
            this.querySelector("img").style.display="none";
        };
        elm.isLoading=function() {
            return this.querySelector("img").style.display=="inline-block";
        }

        elm.send=function(obj) {
            var url = obj.url || "";
            var data = obj.data || null
            var method = data ? "POST" : "GET";
            var auth = obj.user && obj.password ? "Basic " + btoa(obj.user + ":" + obj.password) : "";
            var settings = {
                cache: 'no-cache',
                method:method,
                headers:{
                    "Content-Type": "application/json; charset=utf-8"
                }
            };
            if (auth) {
                settings.headers["authorization"] = auth;
            }
            if (data) {
                settings.body = JSON.stringify(data);
            }
            
            return new Promise((resolve,reject)=>{
                elm.showLoading();
                fetch(url,settings).then((raw)=>{
                    elm.hideLoading();
                    raw.json().then((response=>{
                        if (response.success) {
                            resolve(response.data);
                        } else {
                            var errmsg = response.data.message ?? "Error";
                            reject(new Error(errmsg));
                        }
                    })).catch(err=>{
                        reject(err);
                    });
                }).catch(err=>{
                    elm.hideLoading();
                    reject(err);
                })
            });
        }
    });
}

window.addEventListener("load", () => {
    entryButton();
});