#!/bin/bash

# This script simply recompiles all VPP

cd $VPP_ROOT
make wipe-release
rm -r build-root/.ccache/
rm -r build-root/install-vpp-native
rm -r build-root/build-vpp-native/

make install-ext-deps
make build-release
