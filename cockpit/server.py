#!/usr/bin/env python3

from subprocess import check_output

from lona_bootstrap_5 import PrimaryButton
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


# window manager helper #######################################################
def raise_window_by_window_id(window_id):
    check_output(['wmctrl', '-i', '-a', str(window_id)])


def get_active_window_id():
    output = check_output(['xdotool', 'getactiveWindow']).decode()

    return int(output.strip())


def get_wm_state():
    """
    returns: active_desktop_id, active_window_index, windows
    """

    output = check_output(['wmctrl', '-l', '-x']).decode()
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


@app.middleware
class SetupStateMiddleware:
    async def on_startup(self, data):
        data.server.state['x-windows'] = {}
        data.server.state['f'] = get_wm_state


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
                _class='float-end',
            ),
        )

        self.tables = self.html.query_selector('div#tables')

        while True:
            self.render_tables()
            self.await_click(html=self.html)


@app.route('/switch-x-windows(/)', interactive=False)
class SwitchWindows(LonaView):
    def handle_request(self, request):
        # get current wm state ################################################
        active_desktop_id, active_window_index, windows = get_wm_state()
        windows = windows[active_desktop_id]

        # cycle through windows on the current desktop ########################
        next_window_id = None
        config = self.server.state['x-windows']

        # cycle by window id
        if active_desktop_id in config:

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


app.run()
