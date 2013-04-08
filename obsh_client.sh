#!/bin/bash

# run as root
if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this tool!\n"
    exit 1
fi
clear

printf "
this is the install script for obfuscated-openssh, 
more info, please check:
http://blog.linjunhalida.com/blog/obfuscated-openssh/
"

# install
git clone git://github.com/brl/obfuscated-openssh.git
cd obfuscated-openssh
apt-get update
apt-get build-dep -y openssh
./configure; make

echo 'usage: "./ssh -zZ secretkey"'
