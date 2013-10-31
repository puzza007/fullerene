-module(fullerene_connection_sup).
-behaviour(supervisor).

-export([start_link/0, init/1, start_child/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Mod = fullerene_connection,
    {ok, {{simple_one_for_one, 0, 1}, [
        {Mod, {Mod, start_link, []}, temporary, brutal_kill, worker, [Mod]}
    ]}}.

start_child(Socket) ->
    supervisor:start_child(?MODULE, [Socket]).
