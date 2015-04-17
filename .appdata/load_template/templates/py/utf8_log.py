#!/usr/bin/python
# -*- coding: utf-8 -*-
#coding:utf-8
# vim: ts=4 sw=4 et
import sys
import logging

# Run as module
logger_name="mylogger"
logger = logging.getLogger(logger_name)

default_encoding = 'utf-8'

if sys.getdefaultencoding() != default_encoding:
    reload(sys)
    sys.setdefaultencoding(default_encoding)

def init_logger():
    # run as main
    global logger
    f_handler = logging.FileHandler("./%s.txt" % logger_name)
    f_formatter = logging.Formatter('[%(asctime)s,%(levelname)s,%(filename)s,%(lineno)d]:%(message)s')
    f_handler.setFormatter(f_formatter)
    logger.addHandler(f_handler)
    #console_log
    c_handler = logging.StreamHandler(sys.stdout)
    c_formatter = logging.Formatter('[%(levelname)s,%(filename)s,%(lineno)d]:%(message)s')
    c_handler.setFormatter(c_formatter)
    logger.addHandler(c_handler)
    logger.setLevel(logging.DEBUG)
    logger = logging.getLogger(logger_name)

def main(argv):
    init_logger()
    logger.info("hello world")
    pass

if __name__ == "__main__":
    main(sys.argv[1:])
