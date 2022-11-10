import "./Alert.css";
// @ts-ignore
export default (container) => {
    return {
        container: container,
        __alert: null,
        __stettings: {
            time: 3000,
            pos: "top-center",
            id: "__alert_div"
        },
        // @ts-ignore
        __delete(frame, closefnc) {
            if (frame && frame.parentElement) {
                // @ts-ignore
                this.__alert.removeChild(frame);
                // @ts-ignore
                if (this.__alert.childNodes == 0) {
                    // @ts-ignore
                    var pe = this.__alert.parentElement;
                    pe.removeChild(this.__alert);
                }
                closefnc();
            }
        },
        // @ts-ignore
        __create(type, message, closefnc) {
            this.__alert = this.container.querySelector("#" + this.__stettings.id);
            if (!this.__alert) {
                // @ts-ignore
                this.__alert = document.createElement("div");
                // @ts-ignore
                this.__alert.id = this.__stettings.id;
                // @ts-ignore
                this.__alert.classList.add("alert", this.__stettings.pos);
                this.container.appendChild(this.__alert);
            }
            var frame = document.createElement("div");
            frame.classList.add("frame", type);
            frame.innerHTML = message;
            frame.addEventListener("click", () => {
                this.__delete(frame, closefnc);
            });
            // @ts-ignore
            this.__alert.appendChild(frame);
            if (this.__stettings.time > 0) {
                setTimeout(() => {
                    this.__delete(frame, closefnc);
                }, this.__stettings.time);
            }

        },
        // @ts-ignore
        time(milliseconds) {
            this.__stettings.time = !isNaN(parseInt(milliseconds)) ? parseInt(milliseconds) : 3000;
            return this;
        },
        // @ts-ignore
        pos(position) {
            // @ts-ignore
            this.__stettings.pos = ["top-center", "top-left", "top-right", "bottom-center", "bottom-left", "bottom-right", "center"].includes(position) ? position : "top-center";
            return this;
        },
        // @ts-ignore
        good(message) {
            let self = this;
            // @ts-ignore
            return new Promise(function (resolve, reject) {
                self.__create("good", message, () => {
                    resolve(true);
                });
            });
        },
        // @ts-ignore
        bad(message) {
            let self = this;
            // @ts-ignore
            return new Promise(function (resolve, reject) {
                self.__create("bad", message, () => {
                    resolve(true);
                });
            });
        },
        // @ts-ignore
        ugly(message) {
            let self = this;
            // @ts-ignore
            return new Promise(function (resolve, reject) {
                self.__create("ugly", message, () => {
                    resolve(true);
                });
            });
        }
    }
}