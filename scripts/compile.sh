#!/bin/bash

cd $VPP_ROOT
make wipe-release
make build-release
