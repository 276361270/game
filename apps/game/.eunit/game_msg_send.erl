-module (game_msg_send).

-export ([send_message/3,send_message_to_all/2,send_message_to_all/3]).


%--------------------------------------------------------------------
%% @doc  send message to all  slef() not send
%% @spec MsgTag => {text,Msg}|{binaray,Msg}
%% @end
%%--------------------------------------------------------------------

send_message_to_all(SendPid,MsgTag)->
	send_message_to_all(SendPid,MsgTag,false).

%--------------------------------------------------------------------
%% @doc  send message to all  
%% @spec MsgTag => {text,Msg}|{binaray,Msg}
%% @end
%%--------------------------------------------------------------------

send_message_to_all(SendPid,MsgTag,SendSelf)->
	lists:foreach(fun([Pid,SocketType])->
				case SendSelf of 
					true ->send(Pid,SocketType,MsgTag);
					false-> case Pid=:=SendPid of 
							false -> send(Pid,SocketType,MsgTag);
							true->ok 
						end				
				end
		end, game_store:dirty_lookall()).
%--------------------------------------------------------------------
%% @doc send message to person 
%% @spec  MsgTag => {text,Msg}|{binaray,Msg}
%% @end
%%--------------------------------------------------------------------

send_message(SendPid,RecivePid,MsgTag) when SendPid=/=RecivePid->
	{Table,Pid,SocketType}= game_store:dirty_lookup(RecivePid), 	
	send(Pid,SocketType,MsgTag).
%--------------------------------------------------------------------
%% @doc cast message to person
%% @spec 
%% @end
%%--------------------------------------------------------------------

%%send message
send(RecivePid,SocketType,MsgTag)->
	case SocketType of 
		tcp->gen_server:cast(RecivePid,MsgTag);
		web-> RecivePid!MsgTag
	end.