// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Signature from "./hooks/signature";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: {Signature: Signature},
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

window.addEventListener(`phx:score-updated`, (e) => {
  let el = document.getElementById(`podium-${e.detail.contestant_name}-score`)
  if(el) {
    attr = e.detail.correct ? "data-increase-score" : "data-decrease-score";
    liveSocket.execJS(el, el.getAttribute(attr));
    span = document.querySelector(`#podium-${e.detail.contestant_name}-score span`);
    span.innerText = `$${Math.abs(e.detail.to)}`;
    if (e.detail.to < 0) {
      span.classList.add("text-error");
    } else {
      span.classList.remove("text-error");
    }
    if (Math.abs(e.detail.to) >= 10000) {
      span.classList.add("text-[.7em]");
    } else {
      span.classList.remove("text-[.7em]");
    }
  }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
