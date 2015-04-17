#!/usr/bin/python
# -*- coding: utf-8 -*-
#coding:utf-8
# vim: ts=4 sw=4 et
import sys

default_encoding = 'utf-8'
if sys.getdefaultencoding() != default_encoding:
    reload(sys)
    sys.setdefaultencoding(default_encoding)

def main(argv):
    pass

if __name__ == "__main__":
    main(sys.argv[1:])
