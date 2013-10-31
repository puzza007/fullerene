-module(fullerene_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Enabled = application:get_env(fullerene, enabled, false),
    Workers = case Enabled of
                  true ->
                      [?CHILD(fullerene_connection_sup, supervisor), ?CHILD(fullerene, worker)];
                  false ->
                      []
              end,
    {ok, { {one_for_one, 5, 10}, Workers} }.
