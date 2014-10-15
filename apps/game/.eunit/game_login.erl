-module (game_login).

-export ([login/2,logout/1]).

login(UserID, UserName) ->
     game_login_server:login(UserID, UserName). 

logout(UserID) ->
     game_login_server:logout(UserID). 

