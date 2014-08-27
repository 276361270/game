#erl -boot start_sasl -config elog.config -pa ebin deps/*/ebin
make
erl -pa apps/*/ebin deps/*/ebin