-module(game_model).

-compile(export_all).

insert() ->
    Breed = boss_db_test_parent_model:new(id,
					  <<"wangduan">>),
    {ok, _SavedBreed} = Breed:save().

read() ->
    Puppy = boss_db:find("boss_db_test_parent_model-10"),
    io:format("Puppy's name: ~p~n", [Puppy]).

find() ->
    Puppy =
	boss_db:find("boss_db_test_parent_model-10.wangduan"),
    io:format("find data~p~n", [Puppy]).

exec() ->
    boss_db:execute("SELECT * FROM boss_db_test_parent_models "
		    "where Id > $1 and Id < $2",
		    [8, 10]).

exec_name() ->
    boss_db:execute("SELECT * FROM boss_db_test_parent_models "
		    "where some_text  = $1",
		    ["wangduan"]).

findexc() ->
    List = boss_db:find(boss_db_test_parent_model,
			[{some_text, equals, "wangduan"}]),
    lists:foreach(fun (Model) ->
			  error_logger:info_msg("Module is: ~p,Line is: ~p Message is: ~p",
						[game_model, 34,
						 Model:database_table()])
		  end,
		  List).


