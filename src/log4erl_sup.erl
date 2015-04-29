-module(log4erl_sup).

-author("Ahmed Al-Issaei").
-license("MPL-1.1").

-behaviour(supervisor).

-include("../include/log4erl.hrl").

%% API
-export([start_link/0]).
-export([add_logger/1]).
-export([add_guard/4]).

%% Supervisor callbacks
-export([init/1]).

-define(gv(K, P), proplists:get_value(K, P)).
-define(gv(K, P, D), proplists:get_value(K, P, D)).

start_link() ->
    R = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    ?LOG2("Result in supervisor is ~p~n",[R]),
    add_logger(?DEFAULT_LOGGER),
    lists:foreach(
        fun({LName, Appenders}) ->
            LName1 = log4erl_utils:to_atom(LName),
            add_logger(LName1),
            lists:foreach(
                fun({Mod, AName, Conf}) ->
                    add_guard(LName1, Mod, log4erl_utils:to_atom(AName),
                              {conf, Conf})
                end, Appenders)
        end, ?gv(loggers, application:get_all_env(), [])),
    R.

add_guard(Logger, Appender, Name, Conf) ->
    C = {Name,
	 {logger_guard, start_link ,[Logger, Appender, Name, Conf]},
	 permanent,
	 10000,
	 worker,
	 [logger_guard]},
    ?LOG2("Adding ~p to ~p~n",[C, ?MODULE]),
    supervisor:start_child(?MODULE, C).
    
add_logger(Name) when is_atom(Name) ->
    N = atom_to_list(Name),
    add_logger(N);
add_logger(Name) when is_list(Name) ->
    C1 = {Name,
	  {log_manager, start_link ,[Name]},
	  permanent,
	  10000,
	  worker,
	  [log_manager]},
    ?LOG2("Adding ~p to ~p~n",[C1, ?MODULE]),
    supervisor:start_child(?MODULE, C1).

%%======================================
%% supervisor callback functions
%%======================================
init([]) ->
    ?LOG("Starting supervisor~n"),
    {ok, {{one_for_one, 3, 10}, []}}.
