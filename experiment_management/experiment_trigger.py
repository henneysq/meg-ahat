from __future__ import annotations

import serial

class ExperimentTrigger(serial.Serial):
    
    level_mode = bytearray([0, 2, 255])
    trigger_mode = bytearray([0,2,0])
    pulse_mode = bytearray([0,1])
    values = bytearray()
    
    pulse_dur = 5
    
    def __init__(self, port: str | None = "COM1", baudrate: int = 115200, bytesize: int = serial.EIGHTBITS, parity: str = serial.PARITY_NONE, stopbits: float = serial.STOPBITS_ONE, timeout: float | None = 1, write_timeout: float | None = 2) -> None:
        super().__init__(port, baudrate, bytesize, parity, stopbits, timeout, write_timeout)
        
    def prepare_trigger(self) -> None:
        if not self.is_open():
            msg = "Could not open serial port."
            raise ConnectionAbortedError(msg)
        
        self.reset_input_buffer()
        self.reset_output_buffer()
        
        self.write(self.pulse_mode)
        
        my_byte = b"%x" % self.pulse_dur
        self.write(my_byte)
        
    def send_trigger(self, code):
        my_byte = b"%x" % code
        self.write(my_byte)