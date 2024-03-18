""" Custom LED Controller for Donders

Adds a child class of libLEDController.LEDController
with methods for setting custom current and default
experiment stimulus settings as described in
https://docs.google.com/document/d/1VwtZaO-3iS0U9fAWfoo0XQHD1hfpPfUx__aPgGgaj5E/edit#heading=h.hkt8qg9qozx2

"""
from __future__ import annotations
from typing import Iterable, Final

from libLEDController import LEDController

# Serial devices
SERIAL_DEVICES: Final[tuple[str]] = ("FT32TWG5", "FT51RDMI")

# Labi board info
LEFT_LABI_SERIAL: Final[int] = 57
RIGHT_LABI_SERIAL: Final[int] = 2

# Low current config is the same accross Left and Right devices
DONDERS_DEFAULT_CURRENTS: Final[tuple[int]] = (380, 759, 763, 776, 757, 763)

# Calibrated Left device (blue Labi)
# stimulus={'set1': [0, 3321, 3980, 0, 0, 3980], 'set2': [1450, 0, 0, 3576, 0, 0], 'mode': 'set2'}
DONDERS_DEFAULT_LOWCURRENT_ISF_LEFT: Final[dict] = {
    'set1': [0, 3050, 3250, 0, 0, 3250],
    # 'set1': [0, 3450, 3980, 0, 0, 3980],
    'set2': [1480, 0, 0, 3576, 0, 0],
    'mode': 2,
}
# DONDERS_DEFAULT_LOWCURRENT_ISF_LEFT: Final[dict] = {
#     'set1': [0, 3410, 3980, 0, 0, 3980],
#     'set2': [1405, 0, 0, 3576, 0, 0],
#     'mode': 2,
# }
STROBE_SET_LEFT = [
        int((set1_pwm + set2_pwm) / 1)
        for (set1_pwm, set2_pwm) in list(zip(
            DONDERS_DEFAULT_LOWCURRENT_ISF_LEFT["set1"],
            DONDERS_DEFAULT_LOWCURRENT_ISF_LEFT["set2"],
        ))
    ]
DONDERS_DEFAULT_LOWCURRENT_STROBE_LEFT: Final[dict] = {
    "set1": STROBE_SET_LEFT,
    "set2": [0] * 6,
    "mode": "flicker",
}
CONN_SET_LEFT = [int(pwm / 2) for pwm in STROBE_SET_LEFT]
DONDERS_DEFAULT_LOWCURRENT_CON_LEFT: Final[dict] = {
    "set1": CONN_SET_LEFT,
    "set2": CONN_SET_LEFT,
    "mode": "flicker",
}

# Calibrated Right device (green Labi)
# RIGHT_RED = 3980
RIGHT_RED = 3400
DONDERS_DEFAULT_LOWCURRENT_ISF_RIGHT: Final[dict] = {
    'set1': [0, 3000, RIGHT_RED, 0, 0, RIGHT_RED],
    'set2': [1450, 0, 0, 3375, 0, 0],
    'mode': 2,
    # 'set1': [0, 3150, RIGHT_RED, 0, 0, RIGHT_RED],
    # 'set2': [1450, 0, 0, 3375, 0, 0],
    # 'mode': 2,
}
STROBE_SET_RIGHT = [
        int((set1_pwm + set2_pwm) / 1)
        for (set1_pwm, set2_pwm) in list(zip(
            DONDERS_DEFAULT_LOWCURRENT_ISF_RIGHT["set1"],
            DONDERS_DEFAULT_LOWCURRENT_ISF_RIGHT["set2"],
        ))
    ]
DONDERS_DEFAULT_LOWCURRENT_STROBE_RIGHT: Final[dict] = {
    "set1": STROBE_SET_RIGHT,
    "set2": [0] * 6,
    "mode": "flicker",
}
CONN_SET_RIGHT = [int(pwm / 2) for pwm in STROBE_SET_RIGHT]
DONDERS_DEFAULT_LOWCURRENT_CON_RIGHT: Final[dict] = {
    "set1": CONN_SET_RIGHT,
    "set2": CONN_SET_RIGHT,
    "mode": "flicker",
}



DONDERS_DEFAULT_OFF: Final[dict] = {
    "set1": [0] * 6,
    "set2": [0] * 6,
    "mode": "flicker",
}


class DondersLEDController(LEDController):
    """Custom Donders Experiment LED Controller

    Inherits from the libLEDController.LEDController.

    Adds methods for setting custom current and default
    experiment stimulus settings as described in
    https://docs.google.com/document/d/1VwtZaO-3iS0U9fAWfoo0XQHD1hfpPfUx__aPgGgaj5E/edit#heading=h.hkt8qg9qozx2

    """
    
    def __init__(self, port: str | None = None):
        super().__init__()
        
        self.device_side = None
        
        self._port = None
        if port is not None:
            self._port = port
        
    
    def set_currents(self, currents: Iterable) -> None:
        if not isinstance(currents, Iterable):
            return TypeError

        len_ = len(currents)
        if not len_ == 6:
            error_msg = f"""
                LED current set must be of length 6, got {len_}.
            """
            raise ValueError(error_msg)

        for led_n, current in enumerate(currents):
            super().setCurrent(led_n, current)

    def connect_and_restore_defaults(self) -> None:
        if not self._port is None:
            device = f"/dev/tty.usbserial-{self._port}"
            super().connect(device=device)

        else:        
            for dev in SERIAL_DEVICES:
                try:
                    device = f"/dev/tty.usbserial-{dev}"
                    super().connect(device=device)
                    if self.connected:
                        break
                except AttributeError as error:
                    if "'UARTDevice' object has no attribute '_ser'" in str(error):
                        continue
                    else:
                        raise error
                    
        if not self.connected:
            raise ConnectionError("Could not connect to device.")
        
        self.request_telemetry()
        if self.telemetry["SerialNumber"] == LEFT_LABI_SERIAL:
            self.device_side = "left"
        elif self.telemetry["SerialNumber"] == RIGHT_LABI_SERIAL:
            self.device_side = "right"
        else:
            error_msg = f"Unrecognised device, abborting."
            raise ConnectionRefusedError(error_msg)
        
        self.set_donders_defaults()
        self.storeParameters()

    def set_donders_defaults(self) -> None:
        self.set_donders_default_currents()
        self.set_donders_default_presests()

    def set_donders_default_currents(self) -> None:
        self.set_currents(DONDERS_DEFAULT_CURRENTS)
        self.update()

    def set_donders_default_presests(self) -> None:
        if self.device_side is None:
            error_msg = f"Unrecognised device, abborting."
            raise ConnectionRefusedError(error_msg)
        
        if self.device_side == "left":
            self.set_stimuli(stimuli=DONDERS_DEFAULT_LOWCURRENT_STROBE_LEFT, preset=1)
            self.update()
            self.set_stimuli(stimuli=DONDERS_DEFAULT_LOWCURRENT_ISF_LEFT, preset=2)
            self.update()
            self.set_stimuli(stimuli=DONDERS_DEFAULT_LOWCURRENT_CON_LEFT, preset=3)
            self.update()
            self.set_stimuli(stimuli=DONDERS_DEFAULT_OFF, preset=4)
            self.update()
            
        elif self.device_side == "right":
            self.set_stimuli(stimuli=DONDERS_DEFAULT_LOWCURRENT_STROBE_RIGHT, preset=1)
            self.update()
            self.set_stimuli(stimuli=DONDERS_DEFAULT_LOWCURRENT_ISF_RIGHT, preset=2)
            self.update()
            self.set_stimuli(stimuli=DONDERS_DEFAULT_LOWCURRENT_CON_RIGHT, preset=3)
            self.update()
            self.set_stimuli(stimuli=DONDERS_DEFAULT_OFF, preset=4)
            self.update()
        
    def set_serial_no(self, serial_no: int, pfr_no: int):
        self.queue(f"{pfr_no} {serial_no} id")
        self.storeParameters()
        
    #def __del__(self):
    #   self.turn_off()
    # def read_serial_no(self):
    #     self.request_telemetry)
    #     return self.telemetry[""]

if __name__ == "__main__":
    import time
    dlc = DondersLEDController()
    dlc.connect_and_restore_defaults()
    dlc.turn_on()

    print("Con")
    dlc.display_preset(3)
    time.sleep(5)

    # print("ISF")
    # dlc.display_preset(2)
    # time.sleep(5)
    
    # print("Strobe")
    # dlc.display_preset(1)
    # time.sleep(5)

    # preset_ = dlc.get_preset(1)
    # dlc.set_stimuli(preset_)
    # #dlc.display_preset(1)
    # import pdb; pdb.set_trace()
    # time.sleep(1)

    # dlc.turn_off()