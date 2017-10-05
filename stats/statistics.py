import sys
import os
import numpy

files = os.listdir("./")
#files = os.listdir("/tmp")
files.sort()



for file in files:
    if ".DATA" in file:    # For AVG vec size

        f = open(file)
        vecpercall = []

        for line in f:
            vecpercall.append( float(line.rstrip()) )

        print file, numpy.mean(vecpercall), numpy.max(vecpercall), numpy.min(vecpercall), numpy.std(vecpercall)
        f.close()

