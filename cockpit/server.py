#!/usr/bin/env python3

import subprocess

from lona_bootstrap_5 import PrimaryButton, SecondaryButton
from lona import LonaApp, LonaView

from lona.html import (
    Table,
    THead,
    TBody,
    CLICK,
    Small,
    HTML,
    Div,
    H1,
    H2,
    Tr,
    Th,
    Td,
)

VERSION = 'v0.0'

IGNORED_WINDOW_CLASSES = [
    'nemo-desktop.Nemo-desktop',  # cinnamon desktop
]


# window manager helper #######################################################
def raise_window_by_window_id(window_id):
    subprocess.check_output(
        ['wmctrl', '-i', '-a', str(window_id)],
        stderr=subprocess.STDOUT,
    )


def get_active_window_id():
    try:
        output = subprocess.check_output(
            ['xdotool', 'getactiveWindow'],
            stderr=subprocess.STDOUT,
        ).decode()

    except subprocess.CalledProcessError:
        return None

    return int(output.strip())


def get_wm_state():
    """
    returns: active_desktop_id, active_window_index, windows
    """

    output = subprocess.check_output(
        ['wmctrl', '-l', '-x'],
        stderr=subprocess.STDOUT,
    ).decode()


    lines = output.splitlines()
    active_window_id = get_active_window_id()

    active_desktop_id = 0
    active_window_index = 0
    windows = {}

    for line in lines:
        window_id, line = line.split(' ', 1)
        desktop_id, line = line.strip().split(' ', 1)
        window_class, line = line.strip().split(' ', 1)
        _, window_title = line.strip().split(' ', 1)

        if window_class in IGNORED_WINDOW_CLASSES:
            continue

        desktop_id = int(desktop_id)
        window_id = int(window_id, base=16)

        if desktop_id not in windows:
            windows[desktop_id] = []

        windows[desktop_id].append(
            (window_id, window_class, window_title, )
        )

        if window_id == active_window_id:
            active_desktop_id = desktop_id
            active_window_index = len(windows[desktop_id]) - 1

    if active_window_id is None:
        active_window_index = None

    return active_desktop_id, active_window_index, windows


# web service #################################################################
app = LonaApp(__file__)

app.add_static_file('lona/style.css', """
    body {
        padding: 1em;
    }

    .x-windows-table tr {
        cursor: pointer;
    }

    .x-windows-table tr.selected {
        background-color: var(--bs-primary);
        color: white;
    }
""")

app.add_template('lona/frontend.js', """
    lona_context.add_disconnect_hook(function(lona_context, event) {
        document.querySelector('#lona').innerHTML = `
            <h1>Cockpit</h1>
            <p>Trying to reconnect...</p>
        `;

        setTimeout(function() {
            lona_context.reconnect();

        }, 1000);
    });
""")


@app.middleware
class SetupStateMiddleware:
    async def on_startup(self, data):
        data.server.state['x-windows'] = {}


@app.route('/')
class Index(LonaView):
    def handle_tr_click(self, input_event):
        input_event.node.class_list.toggle('selected')

        with self.server.state.lock:
            state = self.server.state['x-windows']
            desktop_id = input_event.node.desktop_id
            window_id = input_event.node.window_id

            # select
            if input_event.node.has_class('selected'):
                if desktop_id not in state:
                    state[desktop_id] = []

                state[desktop_id].append(window_id)

            # unselect
            elif desktop_id in state:
                if window_id in state[desktop_id]:
                    state[desktop_id].remove(window_id)

                if len(state[desktop_id]) < 1:
                    state.pop(desktop_id)

    def render_tables(self):
        active_desktop_id, active_window_index, windows = get_wm_state()

        with self.html.lock:
            self.tables.nodes.clear()

            for desktop_id in sorted(windows.keys()):
                _windows = windows[desktop_id]

                tbody = TBody()

                table = Table(
                    THead(
                        Tr(
                            Th('Window Class', width='30%'),
                            Th('Title'),
                        ),
                    ),
                    tbody,
                    _class='table x-windows-table',
                )

                self.tables.append(table)

                for window_id, window_class, window_title in _windows:
                    tr = Tr(
                        events=[CLICK],
                        handle_click=self.handle_tr_click,
                    )

                    tr.nodes.extend([
                        Td(window_class),
                        Td(window_title),
                    ])

                    # state
                    tr.desktop_id = desktop_id
                    tr.window_id = window_id

                    with self.server.state.lock:
                        state = self.server.state['x-windows']

                        if(desktop_id in state and
                           window_id in state[desktop_id]):

                            tr.class_list.add('selected')

                    tbody.nodes.append(tr)

    def handle_request(self, request):
        self.set_title(f'Cockpit {VERSION}')
        self.daemonize()

        self.html = HTML(
            H1(
                'Cockpit ',
                Small(VERSION, style='color: var(--bs-gray)'),
            ),
            H2('X Window Switcher'),
            Div(_id='tables'),

            Div(
                PrimaryButton('Refresh', _id='refresh'),
                ' ',
                SecondaryButton('Clear Selection', _id='clear-selection'),
                _class='float-end',
            ),
        )

        self.tables = self.html.query_selector('div#tables')

        while True:
            self.render_tables()

            input_event = self.await_click(html=self.html)

            if input_event.node_has_id('clear-selection'):
                self.server.state['x-windows'].clear()



@app.route('/switch-x-windows(/)', interactive=False)
class SwitchWindows(LonaView):
    def handle_request(self, request):
        # get current wm state ################################################
        active_desktop_id, active_window_index, windows = get_wm_state()
        windows = windows[active_desktop_id]

        # check if a window is focused ########################################
        if active_window_index is None:
            return {
                'json': {
                    'exit_code': 0,
                }
            }

        # cycle through windows on the current desktop ########################
        next_window_id = None
        config = self.server.state['x-windows']

        # cycle through selection
        if('invert-selection' not in request.GET and
           active_desktop_id in config):

            # find next window id
            _config = config[active_desktop_id]
            active_window_id = windows[active_window_index][0]

            if active_window_id in _config:
                active_window_id_index = _config.index(active_window_id)

            else:
                active_window_id_index = 0

            next_window_id_index = active_window_id_index + 1

            if next_window_id_index >= len(_config):
                next_window_id_index = 0

            next_window_id = _config[next_window_id_index]

            # find next window
            index = active_window_id_index

            for _ in range(len(windows)):
                index += 1

                if index >= len(windows):
                    index = 0

                window_id, window_class, _ = windows[index]

                if window_id == next_window_id:
                    next_window_id = window_id

                    break

        # cycle through inverted selection
        elif('invert-selection' in request.GET and
             active_desktop_id in config):

            _config = config[active_desktop_id]
            next_window_index = active_window_index

            for _ in range(len(windows)):
                next_window_index += 1

                if next_window_index >= len(windows):
                    next_window_index = 0

                if windows[next_window_index][0] not in _config:
                    next_window_id = windows[next_window_index][0]

                    break

        # plain cycle
        else:
            next_window_index = active_window_index + 1

            if next_window_index >= len(windows):
                next_window_index = 0

            next_window_id = windows[next_window_index][0]

        # raise window ########################################################
        if next_window_id is not None:
            raise_window_by_window_id(next_window_id)

        return {
            'json': {
                'exit_code': 0,
            }
        }


@app.route('/switch-x-desktops(/)', interactive=False)
class SwitchXDesktops(LonaView):
    def handle_request(self, request):
        active_desktop_id, active_window_index, windows = get_wm_state()
        next_desktop_id = active_desktop_id + 1

        if(next_desktop_id not in windows or
           active_window_index is None):

            next_desktop_id = 0

        if next_desktop_id in windows:
            raise_window_by_window_id(windows[next_desktop_id][0][0])

        return {
            'json': {
                'exit_code': 0,
            }
        }


app.run()
