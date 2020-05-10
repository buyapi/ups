#!/usr/bin/env python3
#
# buy_a_pi_ups.py
#

import logging
import os
import signal
import sys

from datetime import datetime, timedelta
from time import sleep
from RPi import GPIO


class LoggingConfig:
    """
    This class sets up basic logging.
    It can also be overridden and redefine the configLogging method to
    setup a different logger.
    """
    DEFAULT_LOG_FORMAT = ("%(asctime)s %(module)s %(funcName)s "
                          "[line:%(lineno)d] %(levelname)s %(message)s")

    def __init__(self, log_file=None, level=logging.WARNING):
        """
        Sets the default log format and level, then creates the logger.
        """
        self.__format = self.DEFAULT_LOG_FORMAT
        self.__log_file = log_file
        self.__level = level
        self.log = self._config_logging()

    def _config_logging(self):
        """
        Run basicConfig and set the log format, file, and level.

        Returns: The logger object.
        """
        logging.basicConfig(
            format=self.__format, filename=self.__log_file, level=self.__level)
        return logging.getLogger()


class BuyAPiUPS(LoggingConfig):
    """
    Script to detect loss of power and shutdown RPi after configured time
    period.
    """
    DEFAULT_LOG_FILE = '/var/log/ups.log'
    GPIO17 = 17
    GPIO27 = 27
    GPIO18 = 18
    CHANNELS = [(GPIO17, GPIO.IN), (GPIO27, GPIO.IN), (GPIO18, GPIO.OUT)]
    _ITERATIONS = 6     # Number of times to run UPS online check.
    _WINDOW = 2         # Allowable deviation from normal.
    _DEFAULT_DELAY = 60 # 60 seconds

    def __init__(self, log_file=DEFAULT_LOG_FILE, exit_no_ups=False,
                 delay=_DEFAULT_DELAY, debug=False):
        """
        Constructor

        log_file    -- Path including the log file
        exit_no_ups -- Cleanly exit the ups script if no HAT.
        delay       -- Delay in seconds to determine how long to wait
                       before shutdown.
        debug       -- Set to True to turn on debug logging, defaults to False.
        """
        super().__init__(log_file=log_file,
                         level=logging.DEBUG if debug else logging.WARNING)
        self.exit_no_ups = exit_no_ups
        self.delay = timedelta(seconds=delay)
        self.pwr_lost_time = None
        self.terminate = False
        self.shutdown = False
        signal.signal(signal.SIGTERM, self.handle_terminate_signal)

    def run(self):
        self.log.info("Starting BuyAPi UPS...")
        self._setup()

        try:
            while not self.terminate:
                running = self._is_ups_running()

                # UPS is running.
                if running:
                    if self._is_power_failure():
                        if self.pwr_lost_time is None:
                            self.pwr_lost_time = datetime.now()
                    else:
                        self.pwr_lost_time = None

                    self.log.debug(
                        "pwr_lost_time: %s, delay: %s GPIO 17: %s",
                        self.pwr_lost_time, self.delay, self.read_gpio_17)
                    now = datetime.now()

                    if (self.pwr_lost_time
                        and (self.pwr_lost_time + self.delay) <= now):
                        self.log.warn("RPi Power lost at: %s, "
                                      "Shutdown at: %s, elapsed time: %s",
                                      self.pwr_lost_time, now,
                                      now - self.pwr_lost_time)
                        self.shutdown = True
                        break
                elif self.exit_no_ups:
                    self.log.info("No UPS HAT waiting to exit.")
                    break
        except BaseException as e:
            self.log.warn("Exception raised: %s", e, exc_info=True)
        finally:
            self._teardown()
            self.log.info("...Existing BuyAPi UPS")

            if self.shutdown:
                os.system("sudo poweroff")

    def _setup(self):
        GPIO.setwarnings(False)
        GPIO.setmode(GPIO.BCM)
        [GPIO.setup(*mode) for mode in self.CHANNELS]
        GPIO.output(self.GPIO18, 0)

    def _is_ups_running(self):
        toggle_high = 0
        toggle_low = 0

        for i in range(0, self._ITERATIONS):
            value = GPIO.input(self.GPIO27)

            if value == 1:
                toggle_high += 1
            else:
                toggle_low += 1

            sleep(0.5)

        result = self._is_close(toggle_high, toggle_low)
        self.log.debug("toggle_high: %s, toggle_low: %s, running: %s",
                       toggle_high, toggle_low, result)
        return result

    def _is_close(self, high, low):
        return abs(high - low) <= self._WINDOW

    def _is_power_failure(self):
        value = self.read_gpio_17
        self.log.debug("GPIO17 value: %s", value)
        return value == 1

    @property
    def read_gpio_17(self):
        return GPIO.input(self.GPIO17)

    def _teardown(self):
        GPIO.cleanup([pin for pin, dir in self.CHANNELS])

    def handle_terminate_signal(self, signum, frame):
        self.log.info("SIGTERM detected shutting down script.")
        self.terminate = True


if __name__ == '__main__':
    import argparse
    import sys
    import traceback

    parser = argparse.ArgumentParser(description=("UPS processing..."))
    parser.add_argument('-l', '--log-file', type=str, default='',
                        dest='log_file',
                        help="Log file path (Do not use relative paths and "
                        "the default is /var/log/ups.log).")
    parser.add_argument('-d', '--delay', type=int, dest='delay',
                        help="Enter the delay before shutdown in seconds "
                        "(default is 60 seconds).")
    parser.add_argument('-e', '--exit-no-ups', action='store_true',
                        default=True, dest='exit_no_ups',
                        help="If set False this scrip will keep running if "
                        "no ups Hat is found (default True).")
    parser.add_argument('-D', '--debug', action='store_true', default=False,
                        dest='debug', help="Run in debug mode.")
    options = parser.parse_args()

    if not options.log_file:
        log_file = BuyAPiUPS.DEFAULT_LOG_FILE

    try:
        ups = BuyAPiUPS(log_file=log_file, delay=options.delay,
                        exit_no_ups=options.exit_no_ups, debug=options.debug)
        ups.run()
    except BaseException as e:
        tb = sys.exc_info()[2]
        traceback.print_tb(tb)
        print("{}: {}".format(sys.exc_info()[0], sys.exc_info()[1]))
        sys.exit(1)
    else:
        sys.exit(0)
