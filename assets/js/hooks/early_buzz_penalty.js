"use strict";

/**
If they buzz in too early,
 1. make the full screen lock overlay "active"
 2  set a timeout for 1 second to deactivate it

We also need to clear the timeout if they keep buzzing early.
We also need to remove our event listener to avoid multiple ones firing.
*/

const listener = (event) => {
  const early_buzz_el = document.querySelector(".game.early_buzz_penalty");
  const buzzer_el =
    document.querySelector(".game.buzz") ||
    document.querySelector(".buzzer_is_locked");

  if (
    !early_buzz_el ||
    (buzzer_el && !early_buzz_el.classList.contains("active"))
  ) {
    return;
  }

  window.clearTimeout(window.early_buzz_penalty_timeout);
  const penalty_in_ms = parseInt(early_buzz_el.dataset.penaltyInMs);

  early_buzz_el.classList.add("active");
  window.early_buzz_penalty_timeout = window.setTimeout(function () {
    early_buzz_el.classList.remove("active");
  }, penalty_in_ms);
};

export default {
  mounted() {
    window.addEventListener("click", listener);
  },

  destroyed() {
    window.removeEventListener("click", listener);
    window.clearTimeout(window.early_buzz_penalty_timeout);
  },
};
