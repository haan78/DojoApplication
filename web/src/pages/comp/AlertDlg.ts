'strict'
export const ssr = false;
import "./AlertDlg.css";
abstract class Alert {
    private container: HTMLElement;
    private divid: string;

    constructor(container: HTMLElement) {
        this.container = container;
        this.divid = "__alert_div_id_" + (Math.random() * 1000).toFixed(0).padStart(4, "0");
    }

    public getContainer(): HTMLElement {
        return this.container;
    }

    protected getFrame(): HTMLDivElement {
        const lname = this.constructor.name.toLowerCase();
        let div: HTMLDivElement | null = this.container.querySelector("#" + this.divid);
        if (div == null) {
            div = document.createElement("div");
            div.id = this.divid;
            div.classList.add("alert-background");
            div.classList.add(lname);
            this.container.append(div);
        }

        let frame = document.createElement("div");
        frame.classList.add("alert-frame");
        frame.classList.add(lname);
        div.appendChild(frame);
        return frame;
    }

    protected pop(frame: HTMLDivElement) {
        if (frame.parentElement) {
            const parent = frame.parentElement;
            parent.removeChild(frame);
            if (parent.childNodes.length == 0 && parent.parentElement) {
                const grandparent = parent.parentElement;
                grandparent.removeChild(parent);
            }
        }
    }

}

export let AlertDefaults = {
    zIndex: 999,
    timeout:3000,
    btnYes: "Yes",
    btnNo: "No",
    iconLoading: `<svg style="width:50px; height:50px;" version="1.1" id="L9" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
        viewBox="0 0 100 100" enable-background="new 0 0 0 0" xml:space="preserve">
          <path fill="black" d="M73,50c0-12.7-10.3-23-23-23S27,37.3,27,50 M30.9,50c0-10.5,8.5-19.1,19.1-19.1S69.1,39.5,69.1,50">
            <animateTransform 
               attributeName="transform" 
               attributeType="XML" 
               type="rotate"
               dur="1s" 
               from="0 50 50"
               to="360 50 50" 
               repeatCount="indefinite" />
        </path>
      </svg>`
};

export type PopupProperties = {
    message:HTMLElement|string;
    type?:'good' | 'bad' | 'ugly' | 'default',
    position?: 'tm' | 'tl' | 'tr' | 'bm' | 'bl' | 'br' | 'c',
    timeout?:number
};

export class Popup extends Alert {

    public async push(properties:PopupProperties):Promise<'ok'|'timeout'> {
        const frame = this.getFrame();
        const div = (<HTMLDivElement>frame.parentElement);
        const msgdiv = document.createElement("div");
        const to = typeof properties.timeout == "undefined" ? AlertDefaults.timeout : properties.timeout;
        msgdiv.append(properties.message);
        msgdiv.classList.add("message");
        frame.classList.add("popup");
        frame.classList.add(properties.type || "default");
        frame.appendChild(msgdiv);

        div.style.position = "fixed";
        div.style.display = "flex";
        div.style.background = "none";
        div.style.zIndex = AlertDefaults.zIndex.toString();
        div.style.margin = "0";
        div.style.top = "0";
        div.style.left = "0";
        div.style.flexDirection = "column";
        div.style.width = "max-content";
        div.style.height = "max-content";
        if (properties.position == "bm") {
            div.style.bottom = "0%";
            div.style.top = "auto";
            div.style.left = "50%";
            div.style.transform = "translateX(-50%)";
        } else if (properties.position == "bl") {
            div.style.bottom = "0%";
            div.style.left = "0%";
        } else if (properties.position == "br") {
            div.style.bottom = "0%";
            div.style.right = "0%";
            div.style.left = "auto";
            div.style.paddingRight = "1rem";
        } else if (properties.position == "tm") {
            div.style.top = "1%";
            div.style.left = "50%";
            div.style.transform = "translateX(-50%)";
        } else if (properties.position == "tl") {
            div.style.top = "0%";
            div.style.left = "0%";
        } else if (properties.position == "tr") {
            div.style.top = "0%";
            div.style.right = "0%";
            div.style.left = "auto";
            div.style.paddingRight = "1rem";
        } else {
            div.style.top = "40%";
            div.style.left = "50%";
            div.style.transform = "translate(-50%, 50%)";
        }


        return new Promise<'ok'|'timeout'>((resolve,reject)=>{
            frame.addEventListener("click", (evt: MouseEvent) => {
                this.pop(frame);
                resolve('ok');
            });
            
            if ( to > 0) {
                setTimeout(() => {
                    this.pop(frame);
                    resolve('timeout');
                }, to);
            }
        });
    }

}

export type ConfirmProperties = {
    message: string | HTMLElement,
    title?: string,
    top?: number,
    left?: number,
    width?: number,
    height?: number,
    yes?: HTMLElement | string,
    no?: HTMLElement | string
};

export class Confirm extends Alert {

    public async push(properties: ConfirmProperties):Promise<'yes' | 'no'> {
        const frame = this.getFrame();
        const div = (<HTMLDivElement>frame.parentElement);
        frame.classList.add("confirm");
        if (properties.title) {
            const titlediv = document.createElement("div");
            titlediv.innerHTML = properties.title;
            titlediv.classList.add("title");
            frame.appendChild(titlediv);
        }

        const msgdiv = document.createElement("div");
        msgdiv.append(properties.message);
        msgdiv.classList.add("message");
        frame.appendChild(msgdiv);

        const btndiv = document.createElement("div");
        btndiv.classList.add("buttons");
        const btnyes = document.createElement("a");
        btnyes.classList.add("btn");
        btnyes.classList.add("yes");
        btnyes.append( properties.yes || AlertDefaults.btnYes);
        const btnno = document.createElement("a");
        btnno.append( properties.no || AlertDefaults.btnNo);
        btnno.classList.add("btn");
        btnno.classList.add("no");

        btndiv.appendChild(btnyes);
        btndiv.appendChild(btnno);
        frame.appendChild(btndiv);

        div.style.display = "block";
        div.style.position = "fixed";
        div.style.zIndex = AlertDefaults.zIndex.toString();
        div.style.margin = "0";
        div.style.top = "0";
        div.style.left = "0";
        div.style.padding = "0";
        div.style.width = "100vw"; //this.getContainer().clientWidth ? this.getContainer().clientWidth + "px" :
        div.style.height = "100vh"; //this.getContainer().clientHeight ? this.getContainer().clientHeight + "px" :

        frame.style.position = "relative";
        frame.style.left = (properties.left || 50) + "%";
        frame.style.top = (properties.top || 30) + "%";
        frame.style.width = "max-content";
        frame.style.height = "max-content";
        frame.style.transform = "translate(-50%,0%)";
        frame.style.display = "flex";

        return new Promise<'yes' | 'no'>((resolve,reject)=>{
            btnno.addEventListener("click", (evt: MouseEvent) => {
                this.pop(frame);
                resolve("no");
            });
            btnyes.addEventListener("click", (evt: MouseEvent) => {
                this.pop(frame);
                resolve("yes");
            });
        });
    }
}

export type LoadingProperties = {
    icon?:string;
};

export class Loading extends Alert {
    private _active:boolean = false;
    private frame: HTMLDivElement | null = null;
    public on(properties:LoadingProperties = {}): void {
        this._active = true;
        this.frame = this.getFrame();
        this.frame.classList.add("loading");
        this.frame.innerHTML = (properties.icon || AlertDefaults.iconLoading);
        const div = <HTMLDivElement>this.frame.parentElement;
        div.style.display = "block";
        div.style.position = "absolute";
        //div.style.background = "none";
        div.style.zIndex = AlertDefaults.zIndex.toString();
        div.style.margin = "0";
        div.style.top = "0";
        div.style.left = "0";
        div.style.padding = "0";
        div.style.width = this.getContainer().clientWidth + "px";
        div.style.height = this.getContainer().clientHeight + "px";
        this.frame.style.position = "relative";
        this.frame.style.left = "50%";
        this.frame.style.top = "50%";
        this.frame.style.width = "max-content"; // (position.width || 30) + "%";
        this.frame.style.height = "max-content"; //(position.height || 30) + "%";
        this.frame.style.transform = "translate(-50%,-50%)";
    }

    public get active():boolean {
        return this._active;
    }

    public off(): void {
        this._active = false;
        if (this.frame !== null) {
            this.pop(this.frame);
        }
    }
}