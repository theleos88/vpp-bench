vpp-bench
===

This repo contains:
- the plugins developed to be integrated in vpp
- The scripts we used to perform our experiments.


## Before starting

```bash
svn export https://github.com/theleos88/vpp-bench/trunk/scripts --force /usr/local/etc/scripts
```

This will update the config scripts with the latest version. I also put an alias in the bashrc, command ```update-conf```.


*NOTE: vpp-bench is a fork of the repository github.com/TeamRossi/vpp-bench. Pull requests may be issued to update the configuration to the most recent one*.

---

## Environment
Source the ```config.sh``` inside the scripts folder to load in your shell the env variables.

---

## Conventions

Scripts are organized following a specific convention:
**tool-name**_**script_name**

For example:

```bash
vpp_change-frame-size.sh
```
Where:
**Tool name**: vpp
**Script name**: change-frame-size.sh

## TODO

1. Clone the repository to your main vpp source directory
``` 
git clone [URL]/vpp_dev.git
```

2.

a) Source the env variable

b) Compile your project
```
cd [name] && make 
```

3. Enjoy vpp


## Experiments

 - start-vpp-xconnect.sh

Starting vpp in xconnect mode.
