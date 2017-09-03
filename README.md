vpp-bench
===

Vector Packet Processor is an Linux Foundation (fd.io) project for high-speed packet processing.
In line with the push toward research reproducibility, ```vpp-bench``` is a repository used to keep track of our research data about VPP and, more generally, high-speed software frameworks.

This repo contains:

- the scripts we used to perform the experiments described in the technical report
  available at https://newnet.telecom-paristech.fr/index.php/vpp-bench/
- measurements and statistics from several experiments on VPP
- a sample configuration file for VPP (```startup.conf```)

Development code on VPP (at version 17.04) is regularly pushed to https://github.com/theleos88/vppdev

DPDK code (SDK version 17.01, traffix generator version 3.1.2) is also maintained in https://github.com/theleos88/dpdkdev

### Outline

* [Before starting](https://github.com/theleos88/vpp-bench#before-starting)
* [Tips&Tricks](https://github.com/theleos88/vpp-bench#tipstricks-for-performance-evaluation) - Check common commands
* [Experiments](https://github.com/theleos88/vpp-bench#experiments) - Description of experiments scripts

------

# 1. Before starting

By default, we locate scripts in ```/usr/local/etc/scripts```. This is exported to an environment variable, named ```$CONFIG_DIR```.
If git is not available, or if you just want the scripts directory, export with this command:

```bash
svn export https://github.com/theleos88/vpp-bench/trunk/scripts --force $CONFIG_DIR
```

This will update the config scripts with the latest version. I also put an alias in the bashrc, command ```update-conf``` and ```force-update-conf```.

- After any change in your **local** CONFIG_DIR, run the update-conf.
- To come back to the **remote** version, run the force-update-conf. (It will remove local changes to files. It keeps the local files not staged in git).

*NOTE: vpp-bench was a fork of the repository github.com/TeamRossi/vpp-bench, which is now deprecated.*

## Environment
Source the ```config.sh``` inside the scripts folder to load in your shell the env variables.

## Requirements
Some of the scripts require additional tools or write permission to specific locations:

- write access to ```/tmp/```
- write access to ```$VPP_ROOT``` (see ```config.sh```)
- python in ```$PATH```
- ```$CONFIG_DIR``` in ```$PATH```
- Sudo without password (or, in alternative, run as root)

---

## Conventions

Scripts are organized following a specific convention:

**[tool name]**_**[script name]**

For example:

```bash
vpp_change-frame-size.sh
```
Where:

- **Tool name**: vpp
- **Script name**: change-frame-size.sh

There are currently 5 sets of tools:

- vpp
- dpdk
- lua
- test
- datasets



## TODO

1. Clone the repository to your main vpp source directory
```
git clone [URL]/vpp_dev.git
```

2.a) Source the env variable

2.b) Compile your project
```
cd [name] && make 
```

3. Run one of the scripts.

4. Enjoy vpp.

-----------------------------------------

# 2. Tips&Tricks for performance evaluation

- Check NUMA nodes: each core should be assigned to the same NUMA node of the Line Card
e.g. If core0 is located in NUMA #0 and LC1 is located in NUMA #0, then core0 can be assigned to LC1.

```lstopo    # Check topology of numa nodes```
```cat /sys/bus/pci/devices/[PCI ADDRESS]/numa_node```


-----------------------------------------

# 3. Experiments

#### test_vpp-forwarding-framesize.sh

Performs the test to compute the VPP's forwarding rate as a function of the vector size.
By default, runs for XC or IP forwarding, and with static, roundrobin and uniform mode.
