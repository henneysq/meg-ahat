import logging
import time
import unittest

from experiment_management.experiment_trigger import ExperimentTrigger

class TestTrigger(unittest.TestCase):
        
    def test_trigger(self):
        # NOTE: This test SHOULD fail if no
        # BITSI (or mini-BITISI) is connected

        trigger = ExperimentTrigger()
        trigger.prepare_trigger()
        
        time.sleep(.5)
        trigger.send_trigger(1)
        time.sleep(.5)
        trigger.send_trigger(2)
        time.sleep(.5)
        trigger.send_trigger(4)
        time.sleep(.5)
        trigger.send_trigger(8)
        time.sleep(.5)
        trigger.send_trigger(16)
        time.sleep(.5)
        trigger.send_trigger(32)
        time.sleep(.5)
        trigger.send_trigger(64)
        time.sleep(.5)
        trigger.send_trigger(128)
        time.sleep(.5)

    def test_receive(self):
        # NOTE: This test SHOULD fail if no
        # BITSI (or mini-BITISI) is connected
        trigger = ExperimentTrigger()
        
        trigger.prepare_trigger()
        time.sleep(3)
        trigger.ser.reset_input_buffer()
        trigger.ser.reset_output_buffer()
        
        for _ in range(5):
            time.sleep(1)
            code = trigger.read_response()
            print(f"Read code {code}")
            trigger.ser.reset_input_buffer()
                