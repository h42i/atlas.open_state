require 'socket'
require 'timeout'

$hostname = 'atlas.hasi'
$port = 7876

def test_state_change()
    socket = TCPSocket.open($hostname, $port)

    message = []

    timeout(5) do
        message, client_address = socket.recvfrom(1024)
    end

    socket.close()

    message[0].to_i == 1 ? true : false
end

while true
    begin 
        state = test_state_change()

        puts(state)

        # do stuff here, the open status changed
    rescue Timeout::Error
        # nothing changed.
    end
end
