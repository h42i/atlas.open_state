require 'socket'
require 'timeout'
require '/home/hasi/atlas.open_state/state'

$change_server = TCPServer.open(7876)
$state_server = TCPServer.open(7877) 

$state = false
$wait_time = 0.5

check_change = Thread.new do
    loop do
        begin
            $state = test_open_state()
        rescue
            # just don't die
        end
    end
end

loop do
    Thread.start($change_server.accept) do |client|
        begin
            last_state = $state

            timeout(60) do
                sleep($wait_time) while $state == last_state
            end

            client.puts($state == true ? 1 : 0)
            client.close()

            Thread.current.terminate()
        rescue
            client.close()

            Thread.current.terminate()
        end
    end
end

loop do
    Thread.start($state_server.accept) do |client|
        begin
            client.puts($state == true ? 1 : 0)
            client.close()

            Thread.current.terminate()
        rescue
            client.close()

            Thread.current.terminate()
        end
    end
end
