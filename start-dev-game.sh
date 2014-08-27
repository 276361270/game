#!/bin/sh
#-s reloader -s game 
cd `dirname $0`
mkdir -p log/sasl
erl -sname game -pa $PWD/apps/game/ebin $PWD/deps/*/ebin  -config game.config -s reloader -s game 