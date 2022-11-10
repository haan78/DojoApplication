<script>
// @ts-nocheck

    import { onMount,createEventDispatcher } from "svelte";
    let lookup = [];
    export let lookupList;
    export let selectedList;
    export let count;
    export let size;

    const evtChange = createEventDispatcher();
    
    $: {
        lookup = lookup.map((elm) => {
            if (!elm.selected && selectedList.length >= count) {
                elm.disabled = true;
            } else {
                elm.disabled = false;
            }
            return elm;
        });
    }

    function cellclick(index) {
        lookup[index].selected = !lookup[index].selected;
        selectedList = lookup.reduce((pv, cv) => {
            if (cv.selected) {
                pv.push(cv.value);
            }
            return pv;
        }, []);
        evtChange("change",{ count:lookup.length,list:selectedList });
    }

    onMount(() => {
        lookup = lookupList.map((raw) => {
            let elm = {
                selected: false,
                disabled: false,
                value: raw,
            };
            if (Array.isArray(selectedList)) {
                const fe = selectedList.find((sv) => {
                    return raw == sv;
                });

                elm["selected"] = typeof fe !== "undefined";
                elm["disabled"] =
                    !elm["selected"] &&
                    lookupList.length >= (count || lookupList.length + 1);
            }
            return elm;
        });
        evtChange("change",{ count:lookup.length,list:selectedList });
    });
</script>

<main class="list-select" style="--size:{size ? size*1.2: 'max-content'}em">
    <ul>
        {#each lookup as item, index}
            <li class={item.disabled? "disabled" : ""}>
                <label
                    ><input
                        type="checkbox"
                        bind:checked={item.selected}
                        on:click={() => {
                            cellclick(index);
                        }}
                        disabled={item.disabled}
                    />{item.value}</label
                >
            </li>
        {/each}
    </ul>    
</main>
<style>
    .list-select {
        --size:
    }
    .list-select>ul {
        list-style-type: none;
        max-height: var(--size);
        overflow-y: auto;
        width: 100%;
        margin: 0; /* To remove default bottom margin */ 
        padding: 0;        
        background-color: white;
    }

    .list-select>ul>li {
        color: black;
    }
    .list-select>ul>li.disabled {
        color: var(--disabled-cl);
    }

    .list-select>ul>li>label {
        cursor: pointer;
    }
</style>
