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
Hooks.FinalJeopardyReveal = {
    updateScoreboard(player_id) {
        let podium = document.querySelector('.scoreboard .podium[data-player_id="'+player_id+'"]');
        podium.querySelector('.score').classList.add('revealed');
    },
    fun (current, next) {
        if (next) {
            current.classList.remove('active');
            next.classList.add('active');
        } else {
            // we're done, time to tell the backend to advance to game over
            this.pushEvent("next", {})
        }
    },
    mounted() {
        document.addEventListener('animationend', e => {
            if (e.target.closest('.tv.final-jeopardy .details .wager')) {
                let player_id = e.target.closest('.details.active').dataset['player_id'];
                let current = e.target.closest('.details.active');
                let next = current.nextElementSibling;
                let self = this;
                window.setTimeout(
                    function() { self.updateScoreboard(player_id); },
                    1000
                );
                window.setTimeout(
                    function() { self.fun(current, next); },
                    5000
                );
            }
        })
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
