const serviceurl = import.meta.env.VITE_SERVICE_HOST+import.meta.env.VITE_SERVICE_SCRIPT;
type RequestHeader = Record<string,string>;

export class JRequestError extends Error {
    private _code:number;
    private _status:number;
    private _type:string;
    constructor(message:string, type:string, code:number = 0, status:number = 0) {
        super(message);
        this._code = code;
        this._status = status;
        this._type = type;
    }

    get code() {
        return this._code;
    }

    get status() {
        return this._status;
    }

    get type() {
        return this._type;
    }
}

export type JRequestReject = (error:JRequestError)=>void;

export function JRequest<T>(uri:string,data:unknown = null) : Promise<T> {
    const url = `${serviceurl}${uri}`;
    let headers:RequestHeader = {
        "Content-Type":`application/json; charset=UTF-8`,
        "authorization": sessionStorage.getItem("authorization") || ""
    };
    return new Promise<T>((resolve, reject:JRequestReject) => {        
        fetch(url, {
            method: (data === null ? 'GET' : 'POST'),
            cache: 'no-cache',
            headers: headers,
            body: (data === null ? null : JSON.stringify(data))
        }).then(response =>{
            let ah = response.headers.get("authorization") ?? "";
            if (ah) {
                console.log(["AH",ah]);
                sessionStorage.setItem("authorization",ah);
            }
            response.json().then(json=>{
                if (json.success) {
                    resolve(<T>json.data);    
                } else {
                    let err = new JRequestError(json.data.message,"Response",json.data.code,response.status);
                    reject(err);
                }                
            }).catch(error=>{
                let err = new JRequestError(error.message,"Json",0,response.status);
                reject(err);
            });
        }).catch(error => {
            let err = new JRequestError(error.message,"Network",0);            
            reject(err);
        });
    });
}
