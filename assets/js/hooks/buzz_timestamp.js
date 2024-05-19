export default {
  mounted() {
    window.addEventListener("jeopardy:buzz", (event) => {
      this.pushEventTo("#awaiting-buzz", "buzz", {
        timestamp: Date.now()
      });
    });
  }
};
