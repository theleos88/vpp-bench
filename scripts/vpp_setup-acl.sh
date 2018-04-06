#!/bin/bash
sudo killall vpp_main
sleep 5

echo "VPP START DEFAULT: $1"
$CONFIG_DIR/vpp_start-default.sh &
sleep 25

:'
echo "Setting Up interfaces"
sudo -E $BINS/vppctl -s /tmp/cli.sock set int state TenGigabitEthernetb/0/1 up

sudo -E $BINS/vppctl -s /tmp/cli.sock set int state TenGigabitEthernetb/0/0 up

echo "Setting Xconnect 1->0"
sudo -E $BINS/vppctl -s /tmp/cli.sock set int l2 xconnect TenGigabitEthernetb/0/1 TenGigabitEthernetb/0/0
'


echo "Parsing ruleset: $2"
sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin add filename $2 permit
#sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin add filename /home/valerio/Ruleset/1k_1/acl1_seed_1.rules

echo "Applying rules"
#sudo -E $BINS/vppctl -s /tmp/cli.sockacl-plugin apply sw_if_index 2 input 0 1
sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin apply sw_if_index 2 input 0

sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show partition sw_if_index 2 input 0

#echo "ACL_VAT"
#sudo $SFLAG $BINS/vpp_api_test chroot prefix $1 plugin_path $VPP_PLUGIN_PATH in /home/valerio/vpp1704/vat-acl-script


