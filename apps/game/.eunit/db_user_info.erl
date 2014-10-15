%%string()
%%binary()
%%datetime()
%%date()
%%timestamp() [e.g. returned by erlang:now()]
%%integer()
%%float()
-module (db_user_info,[Id,UserName::string(),UserPassword::string(),LoginTime::date() ,UserMoney::float() ]).
-compile(export_all).