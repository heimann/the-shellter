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

    term.writeln('Welcome to The Shellter');
    term.writeln('');
    term.prompt();
    let curr_line = '';

    term.onKey(event => {
      const ev = event.domEvent;
      const printable = !ev.altKey && !ev.ctrlKey && !ev.metaKey;

      if (ev.keyCode === 13) {
        console.log(curr_line);
        if (curr_line === 'logout') {
          lv.pushEvent("logout", "");
        }
        term.prompt();
        curr_line = '';
      } else if (ev.keyCode === 8) {
     // Do not delete the prompt
      if (term._core.buffer.x > 2) {
        term.write('\b \b');
      }
    } else if (printable) {
      curr_line += event.key;
      term.write(event.key);
    }
    })
    term.focus();

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

