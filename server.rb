#!/usr/bin/env ruby
require 'sinatra'

$device = "/dev/ttyACM0"
$pin_one = "F5"
$pin_two = "F6"

def get_open_state
  begin
    file = File.open($device, "w+")
    file.write($pin_one + "=1\r\n")
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

get '/' do
  get_open_state.to_s
end

