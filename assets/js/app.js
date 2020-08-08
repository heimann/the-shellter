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

import { Terminal } from "xterm"; 
import { FitAddon } from 'xterm-addon-fit';

let Hooks = {}

Hooks.Terminal = {
  mounted() {
    let term = new Terminal({
      cursorBlink: true,
    });
    let lv = this;
    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon);
    term.open(this.el);
    fitAddon.fit();

    term.prompt = () => {
      term.write('\r\n$ ');
    };

    term.writeln('');

    function writeDelayed(term, text, delay) {
      setTimeout(function() {term.writeln(text)}, delay);
    }
    writeDelayed(term, ' ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄    ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄ ▄▄▄     ▄▄▄     ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄   ', 50)
    writeDelayed(term, '█       █  █ █  █       █  █       █  █ █  █       █   █   █   █   █       █       █   ▄  █  ', 100)
    writeDelayed(term, '█▄     ▄█  █▄█  █    ▄▄▄█  █  ▄▄▄▄▄█  █▄█  █    ▄▄▄█   █   █   █   █▄     ▄█    ▄▄▄█  █ █ █  ', 150)
    writeDelayed(term, '  █   █ █       █   █▄▄▄   █ █▄▄▄▄▄█       █   █▄▄▄█   █   █   █     █   █ █   █▄▄▄█   █▄▄█▄ ', 200)
    writeDelayed(term, '  █   █ █   ▄   █    ▄▄▄█  █▄▄▄▄▄  █   ▄   █    ▄▄▄█   █▄▄▄█   █▄▄▄  █   █ █    ▄▄▄█    ▄▄  █', 250)
    writeDelayed(term, '  █   █ █  █ █  █   █▄▄▄    ▄▄▄▄▄█ █  █ █  █   █▄▄▄█       █       █ █   █ █   █▄▄▄█   █  █ █', 300)
    writeDelayed(term, '  █▄▄▄█ █▄▄█ █▄▄█▄▄▄▄▄▄▄█  █▄▄▄▄▄▄▄█▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█ █▄▄▄█ █▄▄▄▄▄▄▄█▄▄▄█  █▄█', 350)

    setTimeout(function() {
      term.prompt();
      term.focus();
    }, 400)


    let curr_line = '';

    this.handleEvent("message", ({message}) => {
      term.write(message);
    })

    term.onKey(event => {
      const ev = event.domEvent;
      const printable = !ev.altKey && !ev.ctrlKey && !ev.metaKey;
      if (ev.keyCode === 13) {
        console.log("carriage return");
        lv.pushEvent("send_keystroke", "\x0d");
      } else {
        lv.pushEvent("send_keystroke", ev.key);
      }
    })

  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

