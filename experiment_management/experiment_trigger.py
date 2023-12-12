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


class ExperimentTrigger():
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
        port: str = "/dev/tty.usbserial-AB0MKUNB",
        baudrate: int = 115200,
        bytesize: int = serial.EIGHTBITS,
        parity: str = serial.PARITY_NONE,
        stopbits: float = serial.STOPBITS_ONE,
        timeout: float = 0,
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
        self.pulse_dur = pulse_dur
        self.port = port
        self.baudrate = baudrate
        self.bytesize = bytesize
        self.parity = parity
        self.stopbits = stopbits
        self.timeout = timeout
        self.write_timeout = write_timeout
        
        self.ser = None
        
        # Re-configure BITSI
        #self.prepare_trigger(pulse_dur)
        self.trigger_ready = False
        

    def prepare_trigger(self, pulse_dur: int | None = None) -> None:
        """Prepare the serial connection to BITSI

        Sets the pulse duration to `self.pulse_dur` ms by
        first sending a 0, then a 1 to set the BITSI to
        programming mode and choose the pulse length. The
        final byte is the actual pulse duration is ms.

        Raises:
            ConnectionAbortedError: Raised if the serial port
                could not be opened.
        """
        if self.ser is None:
            self.ser = serial.Serial(
                self.port, self.baudrate, self.bytesize, self.parity, self.stopbits, self.timeout, self.write_timeout
            )
        
        if not self.ser.is_open:
            msg = "Could not open serial port."
            raise serial.SerialException(msg)
        
        if pulse_dur is None:
            pulse_dur = self.pulse_dur

        # Flush the input and output buffers
        self.ser.reset_input_buffer()
        self.ser.reset_output_buffer()

        # Set the BITSI to trigger mode
        self.ser.write(self.trigger_mode)
        self.ser.reset_output_buffer()
        # Give the BITSI a moment to process..
        sleep(0.5)

        # Set the BITSI to pulse mode
        self.ser.write(self.pulse_mode)
        # Convert the specified pulse duration to a byte
        my_byte = pulse_dur.to_bytes(length=1, byteorder="little")
        # Write it
        self.ser.write(my_byte)
        self.ser.reset_output_buffer()
        # Give the BITSI a moment to process..
        sleep(3)
        
        # Flush the input and output buffers
        self.ser.reset_input_buffer()
        self.ser.reset_output_buffer()
        
        self.trigger_ready = True

    def send_trigger(self, code: int) -> int:
        """Send trigger code to BITSI
        
        This method thinly wraps the Serial.write method
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
        
        # Check if the trigger has been prepared
        if not self.trigger_ready:
            error_msg = f"Please run `prepare_trigger` before running experiment"
            raise RuntimeError(error_msg)
        
        # Check that the provided trigger code is in
        # the acceptable range
        if not isinstance(code, int):
            raise TypeError(f"Trigger code must be of type int; got type {type(code)}.")
        if code < 1 or code > 255:
            raise ValueError(f"Trigger must be a positive uint8; got value of {code}")

        # Encode the trigger code as an ASCII character
        my_byte = code.to_bytes(length=1, byteorder="little")
        
        # Write it to the serial port and return
        return self.ser.write(my_byte)

    def read_response(self) -> int:
        """Read ASCII character from the FORP
        
        The fiber optic response pads (FORP) sends
        triggers to the BITSI which can be read as
        ASCII characters. The ASCII-encoded response
        trigger is converted to an integer and returned.
        
        See also the FORP documentation:
        https://intranet.donders.ru.nl/index.php?id=lab-response-fiberoptic&no_cache=1
        
        The expected values are define by the button mapping:
        button color | finger      | buttonbox | press character | release character | ASCII code 
        blue         | right index | right     | a               | A                 | 97 / 65
        yellow       | right middle| right     | b               | B                 | 98 / 66
        green        | right ring  | right     | c               | C                 | 99 / 67
        red          | right pink  | right     | d               | D                 | 100 / 68
        blue         | left index  | left      | e               | E                 | 101 / 69
        yellow       | left middle | left      | f               | F                 | 102 / 70
        green        | left ring   | left      | g               | G                 | 103 / 71
        red          | left pink   | left      | h               | H                 | 104 / 72 
        
        Returns:
            int: Response triggern decoded from ASCII to int.
        """
        response = self.ser.read(1)
        return int.from_bytes(response, byteorder="little")

    def __del__(self) -> None:
        if not self.ser is None:
            self.ser.close()
            del self.ser