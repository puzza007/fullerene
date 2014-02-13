-module(fullerene).

-behaviour(gen_nb_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3, sock_opts/0, new_connection/2]).

-record(state, {}).

start_link() ->
    Port = application:get_env(fullerene, port, 2003),
    lager:warning("Starting Fullerene listener on 127.0.0.1:~B", [Port]),
    gen_nb_server:start_link(?MODULE, "127.0.0.1", Port, []).

init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

sock_opts() ->
    [binary, {packet, line}, {reuseaddr, true}].

new_connection(Socket, State) ->
    case fullerene_connection_sup:start_child(Socket) of
        {ok, Pid} ->
            ok = gen_tcp:controlling_process(Socket, Pid),
            ok;
        Error ->
            lager:error("Error: ~p", [Error])
    end,
    {ok, State}.
