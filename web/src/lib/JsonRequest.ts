
import { getCookie, setCookie } from 'typescript-cookie';
type Header = Record<string,string>;


export interface RequestJWT {
    payload:Record<string,string|number>,
    secret:string,
    time:number
}

export class JsonRequest {
    public static encoding = 'UTF-8';    
    public static authCookieName = "authorization";
    private _auth:string;

    constructor(authorization:string = "") {
        if (authorization) {
            this._auth = authorization;
        } else {
            this._auth = (JsonRequest.authCookieName ? (getCookie( JsonRequest.authCookieName ) ?? "") : "");            
        }
    }

    public static bearer(token: string):JsonRequest {        
        return new JsonRequest(`Bearer ${token}`);
    }

    public static basic(user:string,password:string):JsonRequest {                
        return new JsonRequest("Basic "+Buffer.from(user+":"+password, "binary").toString("base64"));
    }

    public json(url: string, data: unknown = null): Promise<unknown> {

        const headers:Header = {
            "Content-Type":`application/json; charset=${JsonRequest.encoding}`
        }

        if (this._auth) {
            headers["authorization"] = this._auth;
        }

        return new Promise((resolve, reject) => {
            fetch(url, {
                method: (data === null ? 'GET' : 'POST'),
                cache: 'no-cache',
                headers: headers,
                body: (data === null ? null : JSON.stringify(data))
            }).then(response =>{
                let ah = response.headers.get(JsonRequest.authCookieName) ?? "";
                if (ah) {
                    setCookie(JsonRequest.authCookieName,ah);
                }
                response.json().then(json=>{
                    resolve(json);
                }).catch(error=>{
                    reject(error);
                });
            }).catch(error => {
                reject(error);
            });
        });
    }
}