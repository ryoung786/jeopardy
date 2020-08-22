"use strict";

export default {
  mounted() {
    this.handleEvent("draft_saved", (args) => {
      let el = document.querySelector(
        `.${args.round} .saved[data-category='${args.category_id}']`
      );
      el.classList.remove("active");
      void el.offsetWidth;
      el.classList.add("active");

      el.addEventListener("animationend", function (e) {
        if (e.animationName == "fadeout") {
          el.classList.remove("active");
        }
      });
    });
  },
};
