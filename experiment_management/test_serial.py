import time
import serial

ser = serial.Serial(
    port = "/dev/tty.usbserial-A9007URC",
    baudrate = 115200,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    timeout = 1,
    write_timeout = 2
)

time.sleep(5)
ser.reset_input_buffer()
ser.reset_output_buffer()
time.sleep(.5)
# for _ in range(3):
#     print(ser.readline())
time.sleep(.5)
for _ in range(30):
    code = ser.read()
    print(code)
    time.sleep(.5)