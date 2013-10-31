-module(fullerene_connection).

-behaviour(gen_server).

-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {socket}).

start_link(Socket) ->
    gen_server:start_link(?MODULE, [Socket], []).

init([Socket]) ->
    {ok, {Addr, Port}} = inet:peername(Socket),
    inet:setopts(Socket, [{active, true}]),
    lager:warning("Connection from ~p:~B", [Addr, Port]),
    {ok, #state{socket=Socket}}.

handle_call(_Request, _From, State) ->
    {stop, unhandled_call, State}.

handle_cast(_Msg, State) ->
    {stop, unhandled_cast, State}.

handle_info({tcp, Socket, Line}, State=#state{socket=Socket}) ->
    Len = byte_size(Line),
    Line2 = binary:part(Line, 0, Len - 1),
    lager:info("Graphite: ~s", [Line2]),
    {noreply, State};
handle_info({tcp_closed, Socket}, State = #state{socket=Socket}) ->
    lager:info("Disconnection"),
    {stop, normal, State};
handle_info({tcp_error, Socket, Reason}, State = #state{socket=Socket}) ->
    lager:error("Error: ~p", [Reason]),
    {stop, normal, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
