all: clean build package

clean:
	rebar clean

deps:
	rebar get-deps

build: deps
	rebar compile

package: build
	cd rel&&rebar generate -f
console: package
	rel/game/bin/game console
console_clean: package
	rel/game/bin/game console_clean

