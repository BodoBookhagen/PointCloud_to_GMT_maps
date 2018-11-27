#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 26 13:18:52 2018

@author: bodo
"""
# Taken from: https://graphicdesign.stackexchange.com/questions/90809/export-adobe-photoshop-color-table-act-file-as-csv-file
# act2csv.py quick script no warranties whatsoever
import struct
import csv

DATA = []

with open("NEO_div_vegetation_a.act", "rb") as actFile:
    for _ in range(256):
        raw = actFile.read(3)
        color = struct.unpack("3B", raw)
        DATA.append(color)

with open('test.csv', 'wb') as csvfile:
    csvWriter = csv.writer(csvfile)
    csvWriter.writerows(DATA)
