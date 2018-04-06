#Set CPU in performance mode
sudo cpupower frequency-set -g performance

sleep 2
#Deactivate turbo boost!
echo 1 | sudo tee  /sys/devices/system/cpu/intel_pstate/no_turbo

sleep 2

#Cleaning?
echo 60 | sudo tee /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
sudo rm /dev/hugepages/*

sleep 2

