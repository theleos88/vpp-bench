
###################################################
# Change here the default vector sizes or the experiments
declare -ia 'framesizes=(256 128 64 32 512)'
declare -ia 'rates=(500 1000 1500 2000 2500 3000 3500 4000 4500 5000 5500 6000 6500 7000 7500 8000 8500 9000 9999)'

# Currently only xc
#declare -a 'txtype=("xc" "ip" "mix")'
declare -a 'txtype=("xc")'
###################################################

#Iterating over VLIB_FRAME_SIZE and for three experiments
EXP=""
echo "" > /tmp/log_test_vpp_elog.log

cd $VPP_ROOT

for h in "${rates[@]}"; do

    for j in "${txtype[@]}"; do

        for i in "${framesizes[@]}"; do
			vpp_reset.sh

			git checkout vector_log
            vpp_change-frame-size.sh $i
            vpp_compile.sh

			sleep 1

            if [ "$j" == "xc" ]; then
                echo "Compiling with Frame size: $i, Xconnect";
                EXP="XC"
                vpp_start-default.sh &
				sleep 10

				vpp_setup-xconnect.sh


            elif [ "$j" == "ip" ]; then
                echo "Compiling with Frame size: $i, IP 128k";
                EXP="IP-130k"
                vpp_start-default.sh &
                sleep 10

                vpp_setup-linecards-address.sh
                vpp_add-ip-table.sh

            elif [ "$j" == "mix" ]; then
                echo "Compiling with Frame size: $i, L2 128k";
                EXP="L2-128k"
                #vpp_start-default.sh vpp$RANDOM &
                #vpp_set-linecards-address.sh
                #vpp_add-l2-table.sh

            else
                continue
            fi
#			cd $MOONDIR; sudo ./build/MoonGen experiments_traffic/throughput.lua --dpdk-config=/home/leos/vpp-bench/scripts/moongen_txgen/dpdk-conf.lua 1 0  -r $h &
			cd $MOONDIR; sudo ./build/MoonGen experiments_traffic/throughput.lua  0 1  -r $h &
			sleep 40

			vpp_loop-eventlogger.sh "$j" "$i" "$h"

            sudo killall vpp_main
            sudo kill -INT "`pidof MoonGen`"
			sleep 1
        done;
    done;
done


cd /tmp/
sudo mv *dat* $HOME/data/



echo "*****************************************"
echo "Done. Check result file at $RESULT_FILE"
echo "*****************************************"
