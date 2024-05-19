export default {
  mounted() {

    this.el.addEventListener("jeopardy:buzz", e => {
      this.pushEventTo("#awaiting-buzz", "buzz", {timestamp: Date.now()});
    })
  }
};
