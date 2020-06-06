// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}
Hooks.vibratePhone = {
    mounted() {
        if ("vibrate" in navigator) {
            window.navigator.vibrate([200, 30, 200]);
        }
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

document.addEventListener('animationend', e => {
    if (e.target.closest('.tv.final-jeopardy .wager')) {
        let player_id = e.target.closest('.details.active').dataset['player_id'];
        let current = e.target.closest('.details.active');
        let next = current.nextElementSibling;
        window.setTimeout(
            function() { updateScoreboard(player_id); },
            500
        );
        window.setTimeout(
            function() { fun(current, next); },
            4000
        );
    }
})
// document.addEventListener('click', e => {
//     updateScoreboard(53);
// });

function updateScoreboard(player_id) {
    let podium = document.querySelector('.scoreboard .podium[data-player_id="'+player_id+'"]');
    podium.querySelector('.score').classList.add('revealed');
}
function fun(current, next) {
    if (next) {
        current.classList.remove('active');
        next.classList.add('active');
    }
}
