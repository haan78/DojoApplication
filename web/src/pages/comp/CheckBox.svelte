<script lang="ts">
  import { createEventDispatcher } from "svelte";
  export let disabled = false;
  export let position = "right";
  export let checked: boolean;
  export let name: string | undefined;
  export let value = "";

  const evtChange = createEventDispatcher();

  function onchange() {
    evtChange("change", checked);
  }
</script>

<label
  class={"CheckBox " +
    (disabled ? "dis" : "enb") +
    (position == "left" ? " left" : "")}
>
  <input
    {name}
    value={value}
    type="checkbox"
    {disabled}
    bind:checked={checked}
    on:change={onchange}
  />
  <span><slot /></span>
</label>

<style>
  .CheckBox {
    display: flex;
    flex-direction: row;
    align-items: flex-end;
    width: fit-content;
    line-height: 1.5em;
    cursor: pointer;
  }

  .CheckBox.left {
    flex-direction: row-reverse;
  }

  .CheckBox > *,
  .CheckBox > *:before,
  .CheckBox > *:after {
    box-sizing: border-box;
  }

  .CheckBox > span {
    font-weight: bold;
    margin-left: var(--di-in-default);
    margin-right: var(--di-in-default);
  }

  .CheckBox.dis {
    cursor: not-allowed;
  }

  .CheckBox.dis > input[type=checkbox] {
    cursor: not-allowed;
    color: var(--cl-tx-disabled);
    cursor: not-allowed;
    box-shadow: inset 1em 1em var(--cl-tx-disabled);
  }

  .CheckBox.dis > span {
    color: var(--cl-tx-disabled);
  }

  .CheckBox.dis > input[type=checkbox] {
    color: var(--cl-tx-disabled);
  }

  :is(.CheckBox.enb > input[type=checkbox]):hover {
    outline: var(--di-br-default) var(--cl-br-hover) solid;
  }

  .CheckBox > input[type=checkbox] {
    /* Add if not using autoprefixer */
    cursor: pointer;
    -webkit-appearance: none;
    /* Remove most all native input styles */
    appearance: none;
    /* For iOS < 15 */
    background-color: var(--form-background);
    /* Not removed via appearance */
    margin: 0;

    font: inherit;
    color: var(--cl-br-default);
    width: 1.15em;
    height: 1.15em;
    border: calc(var(--di-br-default) / 2) var(--cl-br-default) solid;
    border-radius: 0.15em;
    transform: translateY(-0.075em);

    display: grid;
    place-content: center;
  }

  .CheckBox > input[type=checkbox]::before {
    content: "";
    width: 0.65em;
    height: 0.65em;
    clip-path: polygon(14% 44%, 0 65%, 50% 100%, 100% 16%, 80% 0%, 43% 62%);
    transform: scale(0);
    transform-origin: bottom left;
    transition: 120ms transform ease-in-out;
    box-shadow: inset 1em 1em var(--cl-tx-good);
    /* Windows High Contrast Mode */
    background-color: CanvasText;
  }

  .CheckBox > input[type=checkbox]:checked::before {
    transform: scale(1);
  }

  .CheckBox > input[type=checkbox]:focus {
    /*outline: max(2px, 0.15em) solid var(--cl-br-active);*/
    outline-offset: max(2px, 0.15em);
  }
</style>
