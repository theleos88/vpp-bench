import os
import math
import subprocess

'''
# First step of the parser
# Input: res.* 
# Output: results.DATA 
#
# Converts all the raw data in a unique file,
# containing avg and STD deviation of the measurements.

'''

if __name__ == '__main__':

    #FILES = 1188   #240 for general, it is the result of `ls -l res* | wc -l`


    # Get files from current directory
    FILES = subprocess.Popen('ls -1 /tmp/res*.parsed', shell=True, stdout=subprocess.PIPE)

    # Open result file
    datafile = open("/tmp/results.DATA", "w")

    # Open all files
    for i in FILES.stdout:
        f = open(i.strip(), "r")
        out = open (i.strip()+"_dict.DATA", "w" )

        pkts = float(0)
        t = float(0)
        t_first = float(0)
        t_last = float(0)

        count = 0

        avg_rate = float(0)
        avg_vec_size = float(0)

        variance = float(0)

        sum_vec = float(0)
        points = []

        sum_clk = float(0)
        vec_per_clk = {}

        # Read lines
        for lines in f.readlines():
            if (":" in lines) and ("-" not in lines) :  # - is for clk counter.

                count+=1    # Increment event

                parts = lines.split(":")

#                # Create first time
#    '''
#                if (count==1):
#                    t_first = float(parts[0].strip())
#
#                t_last = float(parts[0].strip())
#                sum_vec+=float(parts[2].strip())
#                points.append(float(parts[2].strip()))
#    '''


                vec = int( parts[2].strip().split(" ")[0])
                if (vec not in vec_per_clk.keys() ):
                    vec_per_clk[vec] = []

                vec_per_clk[vec].append(float(parts[4].strip()))

                sum_clk+=float(parts[4].strip())
                points.append(float(parts[4].strip()))


        # Build dictionary {VEC:[CLK cycles]}
        for poin in vec_per_clk.keys():
            s = "VECSIZE: "+str(poin)+ " List clk: "
            for l in vec_per_clk[poin]:
                s+=str(l) + " "

        out.write(s+"\n")
        out.close()


        # Now we have data
        f.close()

        # Window size in seconds
        #t = t_last - t_first

        # Average rate
        #avg_rate = (sum_vec / t)

        # Average vector size
        # avg_vec = (sum_vec / count)

        sum_clk = (sum_clk / count)

        # Now calculate variance
        for entry in points:
            variance += math.pow( math.fabs(entry - sum_clk ), 2)

        variance = variance/count

        #datafile.write("Window: "+str(i)+" DURATION: "+"{:.4f}".format(t)+ " T_START: "+"{:.4f}".format(t_first) + " T_STOP: " + "{:.4f}".format(t_last) + " RATE: "+"{:.3f}".format(avg_rate*64*8)+  " AVG_VEC_SIZE: "+ "{:.4f}".format(avg_vec) + " VARIANCE: "+ "{:.4f}".format(variance) + " MIN/MAX: " + str( min(points) )+"/"+ str(max(points))+"\n"  );
        datafile.write("Window: "+str(i)+" AVG_CLK: "+ "{:.4f}".format(sum_clk) + " VARIANCE: "+ "{:.4f}".format(variance) + " MIN/MAX: " + str( min(points) )+"/"+ str(max(points))+"\n"  );
        #print("Window: "+str(i)+" DURATION: "+"{:.4f}".format(t)+ " T_START: "+"{:.4f}".format(t_first) + " T_STOP: " + "{:.4f}".format(t_last) + " RATE: "+"{:.3f}".format(avg_rate*64*8)+  " AVG_VEC_SIZE: "+ "{:.4f}".format(avg_vec) + " VARIANCE: "+ "{:.4f}".format(variance) + " MIN/MAX: " + str( min(points) )+"/"+ str(max(points))+"\n"  );

    # Writing to final file
    datafile.close()
