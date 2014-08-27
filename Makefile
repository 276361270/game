all: clean build package

clean:
	rebar clean

deps:
	rebar get-deps

build: deps
	rebar compile

package: build
<<<<<<< HEAD
	cd rel&&rebar generate -f
=======
	rebar generate -f
>>>>>>> 5d9521840ff865e04e8215d0be00c4c4262e787a

console: package
	rel/game/bin/game console

console_clean: package
	rel/game/bin/game console_clean

