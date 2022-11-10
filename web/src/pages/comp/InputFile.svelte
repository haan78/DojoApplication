<input type="file" {accept} {name} on:change={onchange} bind:this={input} style="display: none;" />
<script lang="ts">
    import { createEventDispatcher } from "svelte";
    let input:HTMLInputElement;
    export let accept = "image/*";
    export let name = "";    
    export let src:string = "";
    export let size:number = 0;
    export let type:string = "";

    export function open():void {
        input.click();
    }

    export async function download(url:string) {
        return new Promise<Blob>((resolve,reject)=>{
            fetch(url).then(response=>{
                response.blob().then(bdata=>resolve(bdata)).catch(err=>reject(err));
            }).catch(err=>reject(err));
        });
    }

    const onevt = createEventDispatcher();

    function clear():void {
        src = "";
        type = "";
        size = 0;
        onevt("change",{ src:src,size:size,type:type });
    }

    function onchange(evt:Event) {
        if ((<HTMLInputElement>evt.target).files) {
            const fl: FileList = <FileList>(<HTMLInputElement>evt.target).files;
            if (fl.length) {
                const reader = new FileReader();
                reader.addEventListener("load", () => {                                    
                    src = <string>reader.result;
                    size = fl[0].size;
                    type = fl[0].type;
                    onevt("change",{ src:src,size:size,type:type });
                });
                reader.addEventListener("error",error=>{
                    clear();
                    onevt("error",error);
                });   
                reader.readAsDataURL(fl[0]);             
            }
        } else {
            clear();
        }
    }


</script>