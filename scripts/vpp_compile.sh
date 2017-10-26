#!/bin/bash

# This script simply recompiles all VPP

cd $VPP_ROOT
#make wipe-release
sudo make build-release
