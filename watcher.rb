require 'open-uri'
require 'state'

while true
  begin
    open("http://spaceapi.hasi.it/set_open/" + get_open_state.to_s, :proxy => nil)

    sleep 10
  rescue
  end
end
