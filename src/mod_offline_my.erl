%%%----------------------------------------------------------------------
%%% File    : mod_offline_my.erl
%%% Author  : Orest Kulik <orest@nisdom.com>
%%% Purpose : My Ejabberd offline notification module using
%%% external HTTP services
%%% Created : 26 May 2016 by Orest Kulik <orest@nisdom.com>
%%%----------------------------------------------------------------------

-module(mod_offline_my).
-author('orest@nisdom.com').

-behaviour(gen_mod).

-export([start/2,
         notify/3,
         stop/1]).

-include("ejabberd.hrl").
-include("jlib.hrl").
-include("logger.hrl").

-compile([debug_info, export_all]).

start(Host, _Opts) ->
    inets:start(),
    ssl:start(),
    ejabberd_hooks:add(offline_message_hook, Host, ?MODULE, notify, 10),
    ?DEBUG("mod_offline_my started", []),
    ok.

stop(Host) ->
    ?DEBUG("mod_offline_my stopped", []),
    ejabberd_hooks:delete(offline_message_hook, Host, ?MODULE, notify, 10),
    ok.

notify(From, To, Packet) ->
    ?DEBUG("received offline message from ~p for ~p, with message ~p", [From, To, Packet]),

    FromS = From#jid.luser,
    ToS = To#jid.luser,
    Body = fxml:get_path_s(Packet, [{elem, <<"body">>}, cdata]),
    Thread = fxml:get_path_s(Packet, [{elem, <<"thread">>}, cdata]),
    Host = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, host, fun(Arg) -> Arg end, <<"">>),
    PathPrefix = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, path_prefix, fun(Arg) -> Arg end, <<"">>),

    Url = <<Host/binary, PathPrefix/binary, "notify">>,
    BodyS = <<"{\"from\": \"", FromS/binary, "\", \"to\": \"", ToS/binary, "\", \"message\": \"", Body/binary, "\", \"thread\": \"", Thread/binary, "\"}">>,

    ?DEBUG("mod_offline_my notifying ~s with ~s", [Url, BodyS]),

    httpc:request(post, {binary_to_list(Url), [], "application/json", binary_to_list(BodyS)}, [], []),
    ok.
