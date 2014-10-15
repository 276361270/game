%%the room api
-module(game_room).
-export([new/3,delete/1,update_room_maxuser/2,update_room_pass/2]).

%% create new Room
new(RoomName,RoomPass,RoomOwer)->
	game_room_sup:start_child(RoomName, RoomPass, RoomOwer).
%% delete Room	
delete(RoomPid)->
	game_room_server:delete(RoomPid).
%% update room password	
update_room_pass(RooomPid,PassWord)->
	game_room_server:update_room_pass(RooomPid, PassWord). 
%% update room maxuser	
update_room_maxuser(RoomPid,MaxUser)->
	game_room_server:update_room_maxuser(RoomPid, MaxUser).
%% user leave room
user_leave_room(RoomPid,UserPid)->
	game_room_server:user_leave_room(RoomPid, UserPid).
%% user jion room
user_jion_room(RoomPid,UserPid)->	
	game_room_server:user_jion_room(RoomPid, UserPid). 
