require 'socket'
require './state'

server = TCPServer.open(7876)

loop {
    Thread.start(server.accept) do |client|
        last_state = get_open_state()
        new_state = get_open_state()

        while last_state == new_state
            last_state = new_state
            last_state = get_open_state()

            sleep(0.5)
        end

        client.puts(get_open_state() ? 0 : 1)
        client.close
    end
}
