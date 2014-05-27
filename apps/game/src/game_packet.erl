-module(game_packet).
-vsn("1.01").
-export([binary_to_packet/1, packet_to_binary/1, term_to_packet/1, packet_to_term/1 ,term_to_packet_with_checksum/1,packet_to_term_with_checksum/1,test/0]).
-compile([export_all]).

t(A)->A+2.

-spec test() -> any().

test() ->
	Bin1 = <<11234:32/big>>,
	Packet = binary_to_packet(Bin1),
	Bin1 = packet_to_binary(Packet),
	Bin2 = <<1,2,3,4,5,6,7,8,9,10>>,
	Packet1 = binary_to_packet(Bin2),
	Bin2 = packet_to_binary(Packet1),
	Term = 1000000,
	TermPacket = term_to_packet(Term),
	Term = packet_to_term(TermPacket),
	erlang:display("Packet test completed").
-spec binary_to_packet(binary()) -> binary().
binary_to_packet(B) ->
	Size = byte_size(B),
	<<Size:32/big, B/binary>>.

-spec packet_to_binary(binary()) -> binary().
packet_to_binary(Packet) ->
	<<_:32/big,B/binary>> = Packet,
	B.

-spec term_to_packet(any()) -> binary().
term_to_packet(Term) ->
	B = term_to_binary(Term),
	binary_to_packet(B).


-spec packet_to_term(binary()) -> any().
packet_to_term(Packet) ->
	B = packet_to_binary(Packet),
	binary_to_term(B).


-spec term_to_packet_with_checksum(any()) -> binary().
term_to_packet_with_checksum(Term) ->
	B = term_to_binary(Term),
	Size = byte_size(B),
	CheckSum = erlang:md5(B),
	<<Size:32/big,CheckSum/binary,B/binary>>.


-spec packet_to_term_with_checksum(binary()) -> any().
packet_to_term_with_checksum(Packet) ->
	<<_:32/big,CheckSum:128,Binary/binary>> = Packet,
	CheckCheckSumBinary = erlang:md5(Binary),
	<<CheckCheckSum:128>> = CheckCheckSumBinary, 
	safe_packet_to_term_with_checksum(CheckSum,CheckCheckSum,Binary).


-spec safe_packet_to_term_with_checksum(integer(),integer(),binary()) -> any().

%Valid checksum 
safe_packet_to_term_with_checksum(CheckSum,CheckSum,Binary)->
	binary_to_term(Binary);


%Invalid checksumpa	
safe_packet_to_term_with_checksum(_,_,_)->
	throw("!!!!!WARNING Data corrupt!!!!!").