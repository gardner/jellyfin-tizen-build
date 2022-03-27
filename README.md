# Overview

This repository builds jellifin-tizen with three commands. The resulting file is placed in the `output/` directory.

## Requirements

* Docker

## Build process:

    docker build -t jellyfin-tizen-build .

    docker run -v "$(pwd)/output":/output -it jellyfin-tizen-build

    ls -lah output/
    total 18488
    drwxr-xr-x  3 jellyfin  staff    96B 27 Mar 10:21 .
    drwxr-xr-x  8 jellyfin  staff   256B 27 Mar 10:20 ..
    -rw-r--r--  1 jellyfin  staff   9.0M 27 Mar 10:21 Jellyfin.wgt

## Install the binary on your TV

### Steps to install the build on a Samsung TV:

- enable developer mode on the tv
- use the `sdb` command from within the docker container to install the wgt file

### Enable Developer Mode on your TV
On the TV:

- Go to **Apps**
- Type in 12345 (I had to plug in a USB keyboard to the TV to accomplish this)
- In the dialog that pops up:
- - Turn on debug mode
- - Set the IP address to the your local network IP on the machine running docker  (usually 192.168.x.x)
- Find the IP address of the TV by going to `Settings > General > Network > Network Status`

## Run the docker container to use sdb
    docker run -v "$(pwd)"/output:/output -it jellyfin-tizen-build /bin/bash

### Once inside the docker container issue:

    export PATH=$PATH:/tizen/tizen-studio/tools/ide/bin:/tizen/tizen-studio/tools

    tizen@6ca8b1e3dbe1:~$ sdb devices
    * Server is not running. Start it now on port 26099 *
    * Server has started successfully *
    List of devices attached

    tizen@6ca8b1e3dbe1:~$ sdb connect 192.168.1.69
    connecting to 192.168.1.69:26101 ...
    connected to 192.168.1.69:26101

    tizen@6ca8b1e3dbe1:~$ sdb devices
    List of devices attached
    192.168.1.69:26101  	device    	UA63TU3300TX

    tizen@6ca8b1e3dbe1:~$ cd /output/

    tizen@6ca8b1e3dbe1:/output$ tizen install -n Jellyfin.wgt -t UA43TU8500SXNZ
    Transferring the package...


