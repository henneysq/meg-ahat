"""Trigger module to interact with BITSI at DCCN

This module implements a class to send triggers
to the BITSI during experiments conducted with
python.

Please note that the module is based on pyserial 3.5
(https://pypi.org/project/pyserial/) which can be
installed with pip by:

>>> pip install "pyserial==3.5"

Example of using the ExperimentTrigger in your python script:

>>> from experiment_trigger import ExperimentTrigger as ET
>>> et = ET()
>>> et.send_trigger(65)

"""

from __future__ import annotations

import serial
from time import sleep


class ExperimentTrigger(serial.Serial):
    """Serial wrapper for BITSI triggers

    This class inherits from the `Serial` class from pyserial
    (https://pyserial.readthedocs.io/en/latest/pyserial_api.html)
    and acts as a thin wrapper with standard values specified in the
    DCCN BITSI documentation
    (https://intranet.donders.ru.nl/index.php?id=lab-bitsi&no_cache=1&sword_list%5B%5D=bitsi)

    At instantiation, it re-programs the BITSI to ensure it
    is properly set up, and sets the pulse duration to
    a value specified by the `pulse_dur` argument (defaults
    to 30 [ms]).

    """

    # Byte arrays for programming BITSI
    trigger_mode = bytearray([0, 2, 0])  # Setting trigger mode
    pulse_mode = bytearray([0, 1])  # Setting pulse duration

    def __init__(
        self,
        pulse_dur: int = 30,
        port: str = "COM1",
        baudrate: int = 115200,
        bytesize: int = serial.EIGHTBITS,
        parity: str = serial.PARITY_NONE,
        stopbits: float = serial.STOPBITS_ONE,
        timeout: float = 1,
        write_timeout: float = 2,
    ) -> None:
        """Initialise the serial parent object and re-configure BITSI

        The default argument values ensures correct interaction with the BITSI.
        In some cases, it might be desired to use a different pulse duration,
        to ensure that the recording equipment on the other side samples it
        correctly, or to eliminate overlap between triggers sent close in time.

        Args:
            pulse_dur (int, optional): Trigger pulse duration [ms]. Defaults to 30.
            port (str, optional): Device name. Defaults to "COM1".
            baudrate (int, optional): Baud rate. Defaults to 115200.
            bytesize (int, optional): Number of data bits. Defaults to serial.EIGHTBITS.
            parity (str, optional): Enable parity checking. Defaults to serial.PARITY_NONE.
            stopbits (float, optional): Number of stop bits. Defaults to serial.STOPBITS_ONE.
            timeout (float, optional): Read timout in seconds. Defaults to 1.
            write_timeout (float, optional): Write timeout in seconds. Defaults to 2.
        """
        super().__init__(
            port, baudrate, bytesize, parity, stopbits, timeout, write_timeout
        )

        # Re-configure BITSI
        self._prepare_trigger(pulse_dur)

    def _prepare_trigger(self, pulse_dur) -> None:
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

        # Flush the input and output buffers
        self.reset_input_buffer()
        self.reset_output_buffer()

        # Set the BITSI to trigger mode
        self.write(self.trigger_mode)
        self.reset_output_buffer()
        # Give the BITSI a moment to process..
        sleep(0.5)

        # Set the BITSI to pulse mode
        self.write(self.pulse_mode)
        # Convert the specified pulse duration to a byte
        my_byte = pulse_dur.to_bytes(length=1, byteorder="little")
        # Write it
        self.write(my_byte)
        self.reset_output_buffer()
        # Give the BITSI a moment to process..
        sleep(0.5)

    def send_trigger(self, code: int) -> int:
        """Send trigger code to BITSI
        
        This method simpy wraps the Serial.write method
        to take an unsigned 8-bit integer instead.
        It checks that the provided integer code is
        positive (to avoid setting the BITSI to programming
        mode) and is below 255.

        Args:
            code (int): Positive uint8 valued trigger code
                for the BITSI interface.

        Raises:
            TypeError: Raised if non-integer code is given.
            ValueError: Raised if code is not >0 and <255.
        """
        
        # Check that the provided trigger code is in
        # the acceptable range
        if not isinstance(code, int):
            raise TypeError(f"Trigger code must be of type int; got type {type(code)}.")
        if code < 1 or code > 255:
            raise ValueError(f"Trigger must be a positive uint8; got value of {code}")

        # Encode the trigger code as an ASCII character
        my_byte = code.to_bytes(length=1, byteorder="little")
        
        # Write it to the serial port and return
        return self.write(my_byte)

    def __del__(self) -> None:
        self.close()
        return super().__del__()