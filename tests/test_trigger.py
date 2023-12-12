import logging
import time
import unittest
from unittest.mock import MagicMock

from experiment_management.experiment_trigger import ExperimentTrigger


class TestTrigger(unittest.TestCase):
    
    def test_trigger(self):
        trigger = ExperimentTrigger()
        # trigger_mock.write = MagicMock()
        
        
        # try:
        time.sleep(1)
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

        # except Exception as e:
        #     logging.info("Caught exception while connecting serial port:\n" + str(e))
        #     trigger.ser = MagicMock()
        #     trigger.ser.write = MagicMock()
        #     trigger.ser.read = MagicMock(return_value=bytearray([42]))

    def test_receive(self):
        trigger = ExperimentTrigger()
        # trigger_mock.write = MagicMock()
        
        
        # try:
        trigger.prepare_trigger()
        time.sleep(3)
        trigger.ser.reset_input_buffer()
        trigger.ser.reset_output_buffer()
        
        for _ in range(5):
            time.sleep(1)
            code = trigger.read_response()
            print(f"Read code {code}")
            trigger.ser.reset_input_buffer()
                
            
            # try:
            #     pass
            # except KeyboardInterrupt:
            #     pass
        # except:
        #     pass