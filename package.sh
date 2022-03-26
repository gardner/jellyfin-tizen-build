#!/bin/bash

export PATH=$PATH:/tizen/tizen-studio/tools/ide/bin
tizen certificate -a Gardner -p 1234 -c NZ -s Aukland -ct Aukland -o Tizen -n Gardner -e gardner@example.org -f tizencert
tizen security-profiles add -n Gardner -a /tizen/tizen-studio-data/keystore/author/tizencert.p12 -p 1234
tizen cli-config "profiles.path=/tizen/tizen-studio-data/profile/profiles.xml"
sed -i 's/\/tizen\/tizen-studio-data\/keystore\/author\/tizencert.pwd/1234/g' /tizen/tizen-studio-data/profile/profiles.xml
sed -i 's/\/tizen\/tizen-studio-data\/tools\/certificate-generator\/certificates\/distributor\/tizen-distributor-signer.pwd/tizenpkcs12passfordsigner/g' /tizen/tizen-studio-data/profile/profiles.xml
sed -i 's/password=""/password="tizenpkcs12passfordsigner"/g' /tizen/tizen-studio-data/profile/profiles.xml
chmod 755 /tizen/tizen-studio-data/profile/profiles.xml
cd /tizen/jellyfin-tizen
tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock"
/tizen/expect_script
