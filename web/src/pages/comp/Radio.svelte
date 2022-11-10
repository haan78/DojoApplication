<script lang="ts">
    import { createEventDispatcher } from "svelte";
    export let disabled = false;
    export let position = "right";
    export let group:any;
    export let name: string | undefined;
    export let value = "";

  
    const evtChange = createEventDispatcher();
  
    function onchange() {
      evtChange("change", {value});
    }
  </script>
  
  <label
    class={"Radio " +
      (disabled ? "dis" : "enb") +
      (position == "left" ? " left" : "")}
  >
    <input
      {name}
      value={value}
      type="radio"
      {disabled}
      bind:group={group}
      on:change={onchange}
    />
    <span><slot /></span>
  </label>
  <style>
    .Radio {
      display: flex;
      flex-direction: row;
      align-items: flex-end;
      width: fit-content;
      line-height: 1.5em;
      cursor: pointer;
    }
  
    .Radio.left {
      flex-direction: row-reverse;
    }
  
    .Radio > *,
    .Radio > *:before,
    .Radio > *:after {
      box-sizing: border-box;
    }
  
    .Radio > span {
      font-weight: bold;
      margin-left: var(--di-in-default);
      margin-right: var(--di-in-default);
    }
  
    .Radio.dis {
      cursor: not-allowed;
    }
  
    .Radio.dis > input[type=radio] {
      cursor: not-allowed;
      color: var(--cl-tx-disabled);
      cursor: not-allowed;
      box-shadow: inset 1em 1em var(--cl-tx-disabled);
    }
  
    .Radio.dis > span {
      color: var(--cl-tx-disabled);
    }
  
    .Radio.dis > input[type=radio] {
      color: var(--cl-tx-disabled);
    }
  
    :is(.Radio.enb > input[type=radio]):hover {
      outline: var(--di-br-default) var(--cl-br-hover) solid;
    }
  
    .Radio > input[type=radio] {
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
      border-radius: 0.60em;
      transform: translateY(-0.075em);
  
      display: grid;
      place-content: center;
    }
  
    .Radio > input[type=radio]::before {
      content: "";
      width: 0.6em;
      height: 0.6em;
      /*clip-path: polygon(14% 44%, 0 65%, 50% 100%, 100% 16%, 80% 0%, 43% 62%);*/
      clip-path:circle(50% at 50% 50%);
      transform: scale(0);
      transform-origin: center center;
      transition: 120ms transform ease-in-out;
      box-shadow: inset 1em 1em var(--cl-tx-good);
      /* Windows High Contrast Mode */
      background-color: CanvasText;
    }
  
    .Radio > input[type=radio]:checked::before {
      transform: scale(1);
    }
  
    .Radio > input[type=radio]:focus {
      /*outline: max(2px, 0.15em) solid var(--cl-br-active);*/
      outline-offset: max(2px, 0.15em);
    }
  </style>
  