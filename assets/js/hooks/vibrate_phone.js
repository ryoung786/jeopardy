export default {
  mounted() {
    if ("vibrate" in navigator) {
      window.navigator.vibrate([200, 30, 200]);
    }
  },
};
