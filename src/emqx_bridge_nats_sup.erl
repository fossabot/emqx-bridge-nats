%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_bridge_nats_sup).

-behaviour(supervisor).

-include("emqx_bridge_nats.hrl").

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, _} = application:ensure_all_started(teacup_nats),
    NatsAddress = application:get_env(?APP, address, "127.0.0.1"),
    NatsPort = application:get_env(?APP, port, 4222),
    PoolOpts = [
                {pool_size, 10},
                {pool_type, round_robin},
                {auto_reconnect, 3},
                {address, NatsAddress},
                {port, NatsPort}
            ],
    PoolSpec = ecpool:pool_spec(?APP, ?APP, emqx_bridge_nats_conn, PoolOpts),
    {ok, { {one_for_one, 10, 100}, []} }.

