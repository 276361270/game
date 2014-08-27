#!/bin/sh
cd `dirname $0`
mkdir -p log/sasl
erl -sname center -pa $PWD/apps/game/ebin $PWD/deps/*/ebin -boot start_sasl -config center.config -s reloader -s game 
