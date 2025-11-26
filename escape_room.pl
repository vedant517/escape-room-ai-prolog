/* ========================================
   AI ESCAPE ROOM SOLVER (Core Logic)
   ======================================== */

:- use_module(library(lists)).

/* ---------- WORLD MODEL ---------- */

room(entrance).
room(hall).
room(armory).
room(lab).
room(secret_tunnel).
room(vault).
room(exit).

connected(entrance, hall).
connected(hall, armory).
connected(hall, lab).
connected(armory, secret_tunnel).
connected(lab, secret_tunnel).
connected(secret_tunnel, vault).
connected(vault, exit).

key_at(armory, red_key).
trap(lab).
trap(secret_tunnel).

portal(hall, vault).   % teleport

start_room(entrance).
goal_room(exit).

/* ---------- HEURISTIC FOR A* ---------- */

h(exit, 0).
h(vault, 1).
h(secret_tunnel, 2).
h(lab, 3).
h(armory, 3).
h(hall, 4).
h(entrance, 5).
h(_, 6).

/* ---------- MOVE COSTS ---------- */

move(Current, Next, Cost) :-
    ( connected(Current, Next)
    ; connected(Next, Current)
    ; portal(Current, Next)
    ),
    move_cost(Next, Cost).

move_cost(Room, 5) :- trap(Room), !.
move_cost(_, 1).

/* ========================================
   DEPTH-FIRST SEARCH (DFS)
   ======================================== */

solve_dfs(Path) :-
    start_room(Start),
    goal_room(Goal),
    dfs(Start, Goal, [Start], Rev),
    reverse(Rev, Path).

dfs(Goal, Goal, Path, Path).
dfs(Current, Goal, Visited, Path) :-
    move(Current, Next, _),
    \+ member(Next, Visited),
    dfs(Next, Goal, [Next|Visited], Path).

/* ========================================
   BREADTH-FIRST SEARCH (BFS)
   ======================================== */

solve_bfs(Path) :-
    start_room(Start),
    goal_room(Goal),
    bfs([[Start]], Goal, Rev),
    reverse(Rev, Path).

bfs([[Goal|Rest]|_], Goal, [Goal|Rest]).
bfs([Curr|Others], Goal, Path) :-
    Curr = [Current|_],
    findall(
        [Next|Curr],
        (move(Current, Next, _), \+ member(Next, Curr)),
        New
    ),
    append(Others, New, Queue),
    bfs(Queue, Goal, Path).

/* ========================================
   A* SEARCH
   ======================================== */

solve_astar(Path, Cost) :-
    start_room(Start),
    goal_room(Goal),
    h(Start, H0),
    astar([node(Start, [], 0, H0)], [], Goal, Rev, Cost),
    reverse(Rev, Path).

astar([node(State, Path, G, _)|_], _, Goal, [State|Path], G) :-
    State == Goal.

astar([node(State, Path, G, H)|Open], Closed, Goal, Sol, Cost) :-
    findall(
        node(Next, [State|Path], G1, H1),
        (
            move(State, Next, C),
            \+ member(Next, Closed),
            \+ in_open(Next, Open),
            G1 is G + C,
            h(Next, H1)
        ),
        Children
    ),
    insert_nodes(Open, Children, NewOpen),
    astar(NewOpen, [State|Closed], Goal, Sol, Cost).

in_open(State, [node(State,_,_,_)|_]).
in_open(State, [_|T]) :- in_open(State, T).

insert_nodes(Open, [], Open).
insert_nodes(Open, [N|Ns], R) :-
    insert_node(Open, N, O2),
    insert_nodes(O2, Ns, R).

insert_node([], N, [N]).
insert_node([N1|Ns], N, [N,N1|Ns]) :-
    f(N, F), f(N1, F1), F =< F1, !.
insert_node([N1|Ns], N, [N1|R]) :-
    insert_node(Ns, N, R).

f(node(_,_,G,H), F) :- F is G + H.
