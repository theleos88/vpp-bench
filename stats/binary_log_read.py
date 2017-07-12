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

    return bytearray(int_str)




with open('/tmp/neweventfile', 'rb') as f:
    # memory-map the file, size 0 means whole file
    mm = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)

    print("Iterating")

    itr = iter(mm)
    for b in itr:
        print ( list(b), b)
        input("Press Enter to continue...") # Just for Python3
        if (b == b'\x6c'):
            print ("WIIIIIIIIIIIIIIIIIIIIIIIIIN")


        if (  b == repr('@') ):
            #print(b)
            a= parse_data(itr, 3)
            b= parse_data(itr, 4)
            c= parse_data(itr, 4)

#            print(int(a), int(b), int(c))
            print(convert_int(a), convert_int(b), convert_int(c))
#            raw_input("Press Enter to continue...") # Just for Python2, otherwise simple input


    mm.close()
