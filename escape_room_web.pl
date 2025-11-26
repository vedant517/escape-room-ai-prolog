/* ========================================
   WEB UI + API SERVER FOR ESCAPE ROOM AI
   ======================================== */

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/html_write)).
:- use_module(library(http/json)).

:- [escape_room].   % load the solver code

/* ---------- HTTP ROUTES ---------- */

:- http_handler('/', home_page, []).
:- http_handler('/solve', solve_handler, []).

/* ---------- START SERVER ---------- */

start_server :-
    http_server(http_dispatch, [port(4000)]),
    format("Server running at http://localhost:4000/~n").

:- initialization(start_server, main).

/* ---------- HOME PAGE (WEB UI) ---------- */

home_page(_Request) :-
    reply_html_page(
        title('AI Escape Room Solver'),
        [
            h1('AI Escape Room Solver'),
            p('Choose a search algorithm:'),
            form([action='/solve', method='GET'], [
                select([name=algo], [
                    option([value=dfs],'Depth-First Search (DFS)'),
                    option([value=bfs],'Breadth-First Search (BFS)'),
                    option([value=a],'A* Search')
                ]),
                input([type=submit, value='Solve'])
            ])
        ]
    ).

/* ---------- SOLVER HANDLER (API) ---------- */

solve_handler(Request) :-
    http_parameters(Request, [algo(Algo, [])]),

    (
        Algo = dfs -> solve_dfs(Path), Method='DFS';
        Algo = bfs -> solve_bfs(Path), Method='BFS';
        Algo = a   -> solve_astar(Path, Cost), Method='A*'
    ),

    reply_html_page(
        title('Solution'),
        [
            h2(['Solution Using ', Method]),
            p(['Path Found: ', Path]),
            ( Algo = a -> p(['Total Cost: ', Cost]) ; '' ),
            p(a([href='/'], 'Back'))
        ]
    ).
