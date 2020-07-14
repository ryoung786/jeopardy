"use strict";

export default {
  mounted() {
    const early_buzz_el = document.querySelector(".game.early_buzz_penalty");
    if (early_buzz_el) {
      early_buzz_el.classList.remove("active");
      window.clearTimeout(window.early_buzz_penalty_timeout);
    }
  },
};
