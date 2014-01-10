require 'open-uri'
require '/home/hasi/atlas.open_state/state'

while true
  begin
    open("http://spaceapi.hasi.it/set_open/" + get_open_state.to_s, :proxy => nil)

    sleep 10
  rescue
  end
end
