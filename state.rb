$device = "/dev/ttyGPIO"
$pin_one = "B4"
$pin_two = "B6"

def test_open_state
  begin
    file = File.open($device, "w+")
    
    file.write($pin_one + "=1\r\n")
    file.write($pin_two + "=0\r\n")

    file.write($pin_two + "?\r\n")
        
    result = file.readline
    result.strip!

    pin_two_value = result[-1, 1] == '1' ? true : false

    file.close

    sleep(0.1)

    pin_two_value
  rescue
    false
  end
end

def get_open_state()
    test_set = Array.new(3) { |i|
        test_open_state()
    }

    result = 0

    test_set.each do |val|
        result += val == true ? 1 : 0
    end

    result > 5
end
