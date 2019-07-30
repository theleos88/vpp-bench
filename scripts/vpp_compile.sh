#!/bin/bash

# This script simply recompiles all VPP

cd $VPP_ROOT
make wipe-release
rm -rf build-root/.ccache/
rm -rf build-root/install-vpp-native
rm -rf build-root/build-vpp-native/

make install-ext-deps
make build-release
