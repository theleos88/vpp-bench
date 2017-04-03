import sys
import math


# def print_ip_prefix(prefix)
def iptostring(number):
    b1 = (number / 2**24) % 256
    b2 = (number / 2**16) % 256
    b3 = (number / 2**8) % 256
    b4 = number % 256

    if (b1 == 0):
        return None
    else:
        return str(b1)+"."+str(b2)+"."+str(b3)+"."+str(b4)


def get_ip(number):
    prefix = math.log(number)/math.log(2)
    intpart = int(prefix)

    if not number:
        return

    for i in xrange(2**intpart):
        s = i << (32-intpart)
        a = iptostring(s)
        if a is not None:
            print a+"/"+str(intpart)

'''
    if (intpart != prefix):
        intpart += 1

        for j in range (i+1,number):
            s = j << (32-intpart)
            print iptostring(s)+"/"+str(intpart)
'''

def print_mac(mac):
    s = ""
    for k in mac:
        s+='{:02}'.format(k%99)+":"
    print s[:-1]


def get_mac(number):
    if not number:
        return

    mac = [11,22,33,44,55,66]
    position=5
    counter=00

    for i in range(0,number):
        for j in range (0,6):
            mac[j]+=1
            if mac[j] % 99 != 0:
                break
            else:
                mac[j]=1
                continue
        print_mac(mac)

def usage():
    print "Creates a dataset of L2/L3 addresses. Must manually redirect"
    print "L2: sequential mac addresses, starting from 11:22:33:44:55:66"
    print "L3: coverage of the 32 bit IP space with prefixes"
    print ""
    print "Usage: python",__file__, "<number-ip-prefixes | number-mac-addresses <mac>>"
    print "Example ip: python",__file__," 200000 > /tmp/iptable.dat"
    print "Example mac: python",__file__," 1250 mac > /tmp/mactable.dat"
    print "\n\n"

if __name__ == "__main__":
    if (len(sys.argv) < 2):
        usage()
        exit(1)
    elif (len(sys.argv)<3):
        get_ip(int(sys.argv[1]))
    else:
        get_mac(int(sys.argv[1]))
