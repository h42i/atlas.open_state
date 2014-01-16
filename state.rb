$device = "/dev/ttyGPIO"

$pin_out = "B4"
$pin_in = "B6"

def test_open_state()
    timeout(30) do
        file = File.open($device, "w+")

        file.write($pin_out + "=1\r\n")
        file.write($pin_in + "=0\r\n")

        file.write($pin_in + "?\r\n")

        result = file.readline
        result.strip!

        pin_in_val = result[-1, 1] == '1' ? true : false

        file.close

        pin_in_val
    end
end

def get_open_state()
    test_set = Array.new(8)

    test_set.each do |val|
        val = test_open_state()
        sleep(0.05)
    end

    result = 0

    test_set.each do |val|
        result += val == true ? 1 : 0
    end

    result > 5
end
