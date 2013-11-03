#!/usr/bin/env ruby
require 'open-uri'

$device = "/dev/ttyGPIO"
$pin_one = "B4"
$pin_two = "B6"

def get_open_state
  begin
    file = File.open($device, "w+")
    
    file.write($pin_one + "=1\r\n")
    file.write($pin_two + "=0\r\n")

    file.write($pin_two + "?\r\n")
        
    result = file.readline
    result.strip!

    pin_two_value = result[-1, 1] == '1' ? true : false

    file.write($pin_one + "=0\r\n")
    file.close

    pin_two_value
  rescue
    false
  end
end

while true
  begin
    open("http://spaceapi.hasi.it/set_open/" + get_open_state.to_s, :proxy => nil)

    sleep 10
  rescue
  end
end
