# Overview

This repository builds jellifin-tizen with three commands. The resulting file in places in the `output/` directory.

# Requirements

* Docker

# Build process:

    docker build -t jellyfin-tizen-build .

    docker run -v "$(pwd)"/output:/output -it jellyfin-tizen-build

    ls -lah output/
    total 18488
    drwxr-xr-x  3 gardner  staff    96B 27 Mar 10:21 .
    drwxr-xr-x  8 gardner  staff   256B 27 Mar 10:20 ..
    -rw-r--r--  1 gardner  staff   9.0M 27 Mar 10:21 Jellyfin.wgt