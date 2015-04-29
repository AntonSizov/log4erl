-module(log4erl_app).

-author("Ahmed Al-Issaei").
-license("MPL-1.1").

-behaviour(application).

-include("../include/log4erl.hrl").

%% Application callbacks
-export([start/2, stop/1]).

%%======================================
%% application callback functions
%%======================================
start(_Type, []) ->
    ?LOG("Starting log4erl app~n"),
    log4erl_sup:start_link().

stop(_State) ->
    log_filter_codegen:reset(),
    ok.
