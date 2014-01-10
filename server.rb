require 'socket'
require './state'

$server = TCPServer.open(7876)

$state = false
$wait_time = 1

check_change = Thread.new do
    loop do
        $state = get_open_state() 

        sleep($wait_time)
    end
end

loop do
    Thread.start($server.accept) do |client|
        last_state = $state

        sleep($wait_time) while $state == last_state

        client.puts($state == true ? 1 : 0)
        client.close()
    end
end
