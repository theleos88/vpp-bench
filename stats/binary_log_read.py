import io
import binascii
import os
import mmap
import itertools


def convert_int( bytarr):
    #return int(binascii.hexlify(b), 16)
    return(int.from_bytes(bytarr, byteorder='big', signed=False)  ) #For python3



def parse_data(itr, size):
    int_str = []
    for i in range(0,size):
        int_str.append( next(itr) )

    d = b"".join(int_str)
    return(int.from_bytes(d, byteorder='big', signed=False)  ) #For python3



if __name__ == '__main__':

    with open('/tmp/neweventfile', 'rb') as f:
        # memory-map the file, size 0 means whole file
        mm = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)

        itr = iter(mm)
        for b in itr:

            if (b == b'@'):
                try:
                    e= parse_data(itr, 3)   # Binary file dependent
                    f= parse_data(itr, 4)   # First data
                    g= parse_data(itr, 4)   # Second data
                    h= parse_data(itr, 8)   # Timestamp
                    print ("Id",e,"Vector",f,"Clock",g,"TS",h)
                except:
                    print ("")

        mm.close()
