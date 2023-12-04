from __future__ import annotations

import serial
from time import sleep


class ExperimentTrigger(serial.Serial):
    #level_mode = bytearray([0, 2, 255])
    trigger_mode = bytearray([0, 2, 0])
    pulse_mode = bytearray([0, 1])
    #values = bytearray()

    pulse_dur = 30

    def __init__(
        self,
        port: str | None = "COM1",
        baudrate: int = 115200,
        bytesize: int = serial.EIGHTBITS,
        parity: str = serial.PARITY_NONE,
        stopbits: float = serial.STOPBITS_ONE,
        timeout: float | None = 1,
        write_timeout: float | None = 2,
    ) -> None:
        super().__init__(
            port, baudrate, bytesize, parity, stopbits, timeout, write_timeout
        )

        self._prepare_trigger()

    def _prepare_trigger(self) -> None:
        """Prepare the serial connection to BITSI

        Sets the pulse duration to `self.pulse_dur` ms by
        first sending a 0, then a 1 to set the BITSI to
        programming mode and choose the pulse length. The
        final byte is the actual pulse duration is ms.

        Raises:
            ConnectionAbortedError: Raised if the serial port
                could not be opened.
        """
        if not self.is_open:
            msg = "Could not open serial port."
            raise ConnectionAbortedError(msg)

        self.reset_input_buffer()
        self.reset_output_buffer()

        self.write(self.trigger_mode)
        self.reset_output_buffer()
        #self.flush()

        self.write(self.pulse_mode)
        my_byte = self.pulse_dur.to_bytes(length=1, byteorder="little")
        self.write(my_byte)
        self.reset_output_buffer()
        
        sleep(.5)
        
        very_first_trigger = 99
        self.write(very_first_trigger.to_bytes(length=1, byteorder="little"))
        self.reset_input_buffer()
        self.reset_output_buffer()

    def send_trigger(self, code: int):
        """Send trigger code to BITSI

        Args:
            code (int): Positive uint8 valued trigger code
                for the BITSI interface.

        Raises:
            TypeError: Raised if non-integer code is given.
            ValueError: Raised if code is not >0 and <255.
        """
        if not isinstance(code, int):
            raise TypeError(f"Trigger code must be of type int; got type {type(code)}.")
        if code < 1 or code > 255:
            raise ValueError(f"Trigger must be a positive uint8; got value of {code}")

        my_byte = code
        self.write(my_byte).to_bytes(length=1, byteorder="little")
