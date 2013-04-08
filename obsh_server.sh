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
# config
obkey='fuckgfw'
echo "Please input secret key share between server and client:"
read -p "(Default : fuckgfw):" obkey
if [ "$obkey" = "" ]; then
	obkey="fuckgfw"
fi
echo "obkey set to: ${obkey}"

# install
git clone git://github.com/brl/obfuscated-openssh.git
cd obfuscated-openssh
apt-get update
apt-get build-dep -y openssh
./configure; make

# configure
obpath=`pwd`

rm -f sshd_config
touch sshd_config
cat >sshd_config <<EOF
ObfuscatedPort 2200
ObfuscateKeyword ${obkey}

Port 2201
Protocol 2

HostKey ${obpath}/ssh_host_rsa_key

RSAAuthentication yes
PubkeyAuthentication yes

Subsystem       sftp    /usr/libexec/sftp-server
EOF

# keygen
ssh-keygen -f ssh_host_rsa_key
mkdir -p /var/temp
mkdir -p /var/empty

# as service
rm -f /etc/init.d/obsshd
touch /etc/init.d/obsshd
chmod u+x /etc/init.d/obsshd
cat >/etc/init.d/obsshd <<EOF
#!/bin/bash

# obfuscated ssh service script by halida
# USAGE: start|stop
#

export SSH_HOME=${obpath}

case "\$1" in

start)

echo "Starting obfuscated ssh."
\$SSH_HOME/sshd -f \$SSH_HOME/sshd_config
;;

stop)

echo "Stopping obfuscated ssh."
PID=\`ps aux|grep \$SSH_HOME/sshd | grep -v grep | awk ' { print ( \$(2) ) }'\`
kill \$PID
;;


*)

echo "obfuscated ssh service"
echo "Usage: \$0 {start|stop}"
exit 1
esac

exit 0
EOF

update-rc.d obsshd defaults
service obsshd start
