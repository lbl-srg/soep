#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os, sys, shutil
from io import open
import tempfile

def replace_in_file(old_string, new_string, file_name):
    temp_file = tempfile.mktemp(".bak")
    with open(file_name, mode="rt", encoding="utf-8") as fin, open(temp_file, mode="wt", encoding="utf-8") as fout:
        for line in fin:
            fout.write(line.replace(old_string, new_string))
    os.remove(file_name)
    shutil.move(temp_file, file_name)

if __name__ == "__main__":
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    arg3 = sys.argv[3]
    replace_in_file(arg1, arg2, arg3)
