require 'net/http'

original_verbosity = $VERBOSE
$VERBOSE = nil
TCPSocket = EventMachine::Synchrony::TCPSocket
$VERBOSE = original_verbosity