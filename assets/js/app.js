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

Hooks.clearTermOnClick = {
  mounted() {
    this.el.onclick = () => {window.term.clear()};
  },
  updated() {
    this.el.onclick = () => {window.term.clear()};
  }
}

Hooks.wave = {
  mounted() {
    console.log("Mounted wave")
    let el = this.el;
    this.el.onclick = () => {
      console.log("Clicked wave")
      el.classList.add('clicked');
      setTimeout(function() {
        el.classList.remove('clicked');
      }, 500);
    }
  }

}

Hooks.Terminal = {
  mounted() {
    console.log("Mounting terminal");
    let term = new Terminal({
      cursorBlink: true,
    });
    let lv = this;
    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon);
    term.open(this.el);

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
      term.write(atob(message));
    })

    term.onKey(event => {
      const ev = event.domEvent;
      const printable = !ev.altKey && !ev.ctrlKey && !ev.metaKey;
      console.log(ev.keyCode)
      if (ev.keyCode === 13) {
        // Enter
        lv.pushEvent("send_keystroke", "\x0d");
      } else if (ev.keyCode === 9) {
        // Backspace
        lv.pushEvent("send_keystroke", "\x09");
      } else if (ev.keyCode === 8) {
        // Backspace
        lv.pushEvent("send_keystroke", "\x08");
      } else if (ev.keyCode === 27){
        lv.pushEvent("send_keystroke", "\x1b");
      } else if (ev.keyCode == 37) {
        console.log("left arrow")
        lv.pushEvent("send_keystroke", "\u001b[D");
      } else if (ev.keyCode == 38) {
        console.log("up arrow")
        lv.pushEvent("send_keystroke", "\u001b[A");
      } else if (ev.keyCode == 39) {
        console.log("right arrow")
        lv.pushEvent("send_keystroke", "\u001b[C");
      } else if (ev.keyCode == 40) {
        console.log("down arrow")
        lv.pushEvent("send_keystroke", "\u001b[B");
      } else if (ev.key == 'c' && ev.ctrlKey) {
        console.log("ctrl c")
        lv.pushEvent("send_keystroke", "\x03");
      } else if (ev.key == 'a' && ev.ctrlKey) {
        console.log("ctrl a")
        lv.pushEvent("send_keystroke", "\x01");
      } else if (ev.key == 'b' && ev.ctrlKey) {
        console.log("ctrl b")
        lv.pushEvent("send_keystroke", "\x02");
      } else if (ev.key == 'd' && ev.ctrlKey) {
        console.log("ctrl d")
        lv.pushEvent("send_keystroke", "\x04");
      } else if (ev.key == 'v' && ev.ctrlKey) {
        console.log("ctrl v/paste")
        navigator.clipboard.readText()
          .then(text => {
            for (var i = 0; i < text.length; i++)
            {
              lv.pushEvent("send_keystroke", text.charAt(i));
            }
            console.log('clipboard:', text)
          })
          .catch(err => {
            console.log('Something went wrong', err);
          })
        //lv.pushEvent("send_keystroke", "\x04");
      } else {
        lv.pushEvent("send_keystroke", ev.key);
      }
    })
    fitAddon.fit();
    lv.pushEvent("set_dimensions", {height: term.rows, width: term.cols});


    window.onresize = () => {
      fitAddon.fit();
      console.log("Detected resize");
      lv.pushEvent("set_dimensions", {height: term.rows, width: term.cols});
    }

    window.addEventListener('beforeunload', function(e) {
      lv.pushEvent("unmounted", {"state": true});
    })


    window.term = term;

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

