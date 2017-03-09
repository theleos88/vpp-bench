#!/bin/bash

cd $VPP_ROOT
make wipe-release
#make install-dep
make build-release
#make pkg-deb
#sudo dpkg -i $VPP_ROOT/build-root/*.deb
make build
