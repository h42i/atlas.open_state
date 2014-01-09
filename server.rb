require 'socket'
require './state'

$server = TCPServer.open(7876)

$last_state = get_open_state()
$new_state = get_open_state()

$wait_time = 1

check_change = Thread.new do
    loop do
        $last_state = $new_state
        $new_state = get_open_state()
        
        sleep($wait_time)
    end
end

loop do
    Thread.start($server.accept) do |client|
        while $new_state == $last_state
            sleep($wait_time)
            break
        end

        client.puts($new_state ? 0 : 1)
        client.close()
    end
end
