vpp_dev
===

This repo contains:
- the plugins developed to be integrated in vpp
- The scripts we used to perform our experiments.

---

## Environment
Source the ```config.sh``` inside the scripts folder to load in your shell the env variables.

### Cloning only a the scripts in your folder

```bash
cd $SOME-DIR
svn export https://github.com/TeamRossi/vpp_dev/trunk/scripts/
```

## TODO

1. Clone the repository to your main vpp source directory
``` 
git clone [URL]/vpp_dev.git
```

2.a Source the env variable

2.b Compile your project
```
cd [name] && make 
```

3. Enjoy vpp

