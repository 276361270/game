%%game_user Api
-module(game_user).
-export([new/2,delete/1,update_money/2,get_money/1]).

%% create new User session
%% return {ok,pid}
new(UserID,UserName)->
	game_user_sup:start_child(UserID, UserName).
%% delete a user session	
delete(UserPid)->
	game_user_server:delete(UserPid). 	 
%% update userMoney	
update_money(UserPid,Money)->
	game_user_server:update_money(UserPid, Money). 
%% get userMoney	
get_money(UserPid)->
	game_user_server:get_money(UserPid). 
