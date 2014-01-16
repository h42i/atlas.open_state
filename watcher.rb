require 'socket'
require 'timeout'
require 'open-uri'

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

        open("http://spaceapi.hasi.it/set_open/" + state.to_s, :proxy => nil)

        # do stuff here, the open status changed
    rescue Timeout::Error
        # nothing changed.
    rescue
        # really, really bad.
    end
end
