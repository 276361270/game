#!/bin/sh
cd `dirname $0`
mkdir -p log/sasl
erl -name 'game@192.168.1.8' -pa $PWD/apps/game/ebin $PWD/deps/*/ebin -boot start_sasl -config sys.config -s reloader -s game 
