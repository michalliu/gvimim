#!/usr/bin/python
# -*- coding: utf-8 -*-
#coding:utf-8
# vim: ts=4 sw=4 et
import sys
import logging
import argparse

# Run as module
logger_name="startTask"
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

class Task(object):

    def __init__(self):
        parser = argparse.ArgumentParser(
            description='Pretends to be git',
            usage='''task <command> [<args>]

The most commonly used git commands are:
   commit     Record changes to the repository
   fetch      Download objects and refs from another repository
''')
        parser.add_argument('command', help='Subcommand to run')
        # parse_args defaults to [1:] for args, but you need to
        # exclude the rest of the args too, or validation will fail
        args = parser.parse_args(sys.argv[1:2])
        if not hasattr(self, args.command):
            print 'Unrecognized command %s' % args.command
            parser.print_help()
            exit(1)
        # use dispatch pattern to invoke method with same name
        getattr(self, args.command)()

    def commit(self):
        parser = argparse.ArgumentParser(
            description='Record changes to the repository')
        # prefixing the argument with -- means it's optional
        parser.add_argument('--amend', action='store_true')
        # now that we're inside a subcommand, ignore the first
        # TWO argvs, ie the command (git) and the subcommand (commit)
        args = parser.parse_args(sys.argv[2:])
        print 'Running git commit, amend=%s' % args.amend

    def fetch(self):
        parser = argparse.ArgumentParser(
            description='Download objects and refs from another repository')
        # NOT prefixing the argument with -- means it's not optional
        parser.add_argument('repository')
        args = parser.parse_args(sys.argv[2:])
        print 'Running git fetch, repository=%s' % args.repository

def main(argv):
    init_logger()
    Task()

if __name__ == "__main__":
    main(sys.argv[1:])

