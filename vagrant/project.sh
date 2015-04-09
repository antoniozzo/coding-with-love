#!/bin/bash

darwin=false;
case "`uname`" in
	Darwin*) darwin=true ;;
esac

if $darwin; then
	sedi="/usr/bin/sed -i ''"
else
	sedi="sed -i"
fi

while true; do
	read -p "Enter project name: " pNAME
	if [ -z $pNAME ]; then
		echo "No project name entered."
	else
		break
	fi
done

while true; do
	read -p "Enter project dir: [Default: ${pNAME}]: " pDIR
	pDIR=${pDIR:-$pNAME}
	if [ -d "$pDIR" ]; then
		echo "This directory already exists."
	else
		break
	fi
done

URL=https://vagrantcloud.com/ubuntu/trusty64
NUM=$(find ../ -maxdepth 1 -type d -print | wc -l | sed -e 's/^[ \t]*//')

# config vm
read -p "Do you wish to configure the VM yourself? [Default: no]: " pCONF
if [[ $pCONF =~ ^[Yy]$ ]]; then
	pCONF=true
fi

# start vagrant
read -p "Do you want to start vagrant after install? [Default: yes]: " pVAGRANT
pVAGRANT=${pVAGRANT:-yes}

# box name
unset pBOX
if [ pCONF == true ]; then
	read -p "Enter box name [Default: ubuntu/trusty64]: " pBOX
fi
pBOX=${pBOX:-ubuntu/trusty64}

# box url
unset pBOXURL
if [ pCONF == true ]; then
	read -p "Enter box URL [Default: ${URL}]: " pBOXURL
fi
pBOXURL=${pBOXURL:-$URL}

# vm synced directory
unset pTDIR
if [ pCONF == true ]; then
	read -p "Enter synced folder [Default: /var/www]: " pTDIR
fi
pTDIR=${pTDIR:-/var/www/}

# memory size
unset pMEM
if [ pCONF == true ]; then
	read -p "Enter memory size [Default: 1024]: " pMEM
fi
pMEM=${pMEM:-1024}

# ip address
unset pIP
IP=192.168.80.$NUM
if [ pCONF == true ]; then
	read -p "Enter private network IP (Required for vhosting) [Default: ${IP}]: " pIP
fi
pIP=${pIP:-$IP}

# vhost
unset pVHOST
if [ pCONF == true -a ! -z $pIP ]; then
	read -p "Enter vhost name (Requires sudo) [Default: ${pNAME}.dev]: " pVHOST
fi
pVHOST=${pVHOST:-$pNAME.dev}

# install git
unset pGIT
if [ pCONF == true ]; then
	read -p "Install GIT on the VM? [Default: yes]: " pGIT
fi
pGIT=${pGIT:-yes}

# install node
unset pNODE
if [ pCONF == true ]; then
	read -p "Install NODE on the VM? [Default: yes]: " pNODE
fi
pNODE=${pNODE:-yes}

# install php
unset pPHP
if [ pCONF == true ]; then
	read -p "Install PHP on the VM? [Default: yes]: " pPHP
fi
pPHP=${pPHP:-yes}

# php options
if [[ $pPHP =~ ^[Yy] ]]; then

	# public directory
	unset pPUBDIR
	DIR="${pTDIR}public"
	if [ pCONF == true ]; then
		read -p "Enter public dir [Default: ${pTDIR}public]: " pPUBDIR
	fi
	pPUBDIR=${pPUBDIR:-$DIR}

	# install composer
	unset pCOMPOSER
	if [ pCONF == true ]; then
		read -p "Install COMPOSER on the VM? [Default: yes]: " pCOMPOSER
	fi
	pCOMPOSER=${pCOMPOSER:-yes}
fi

# install mysql
unset pMYSQL
if [ pCONF == true ]; then
	read -p "Install MYSQL on the VM? [Default: yes]: " pMYSQL
fi
pMYSQL=${pMYSQL:-yes}

# mysql options
if [[ $pMYSQL =~ ^[Yy] ]]; then

	# database name
	unset pDBNAME
	if [ pCONF == true ]; then
		read -p "Enter database name [Default: db]: " pDBNAME
	fi
	pDBNAME=${pDBNAME:-db}

	# database pass
	unset pDBPASS
	if [ pCONF == true ]; then
		read -p "Enter database password [Default: root]: " pDBPASS
	fi
	pDBPASS=${pDBPASS:-root}
fi

# port forward
unset pFORWARD
if [ pCONF == true ]; then
	read -p "Use port forwarding? [Default: no]: " pFORWARD
fi
pFORWARD=${pFORWARD:-no}

# port forwarding options
if [[ $pFORWARD =~ ^[Yy] ]]; then

	# apache port
	if [[ $pPHP =~ ^[Yy] ]]; then
		read -p "apache port: " pAPACHEPORT
	fi

	# mysql port
	if [[ $pMYSQL =~ ^[Yy] ]]; then
		read -p "mysql port: " pMYSQLPORT
	fi

	# ssh port
	read -p "ssh port: " pSSHPORT
fi

git clone https://github.com/antoniozzo/vagrant-template.git $pDIR/tmp; rm -rf $pDIR/tmp/.git; mv $pDIR/tmp/* $pDIR/; rm -rf $pDIR/tmp; cd $pDIR

$sedi "s|pNAME|${pNAME}|g" Vagrantfile
$sedi "s|pBOXNAME|${pBOX}|g" Vagrantfile
$sedi "s|pBOXURL|${pBOXURL}|g" Vagrantfile
$sedi "s|pTDIR|${pTDIR}|g" Vagrantfile
$sedi "s|pMEM|${pMEM}|g" Vagrantfile

if [ ! -z $pIP ]; then
	$sedi "s|#pIP ||g" Vagrantfile
	$sedi "s|pIP|${pIP}|g" Vagrantfile

	if [ ! -z $pVHOST ]; then
		echo "vhost requires sudo"
		sudo bash -c "echo -e '${pIP}\t${pVHOST}' >> /etc/hosts"
	fi
fi

if [[ $pGIT =~ ^[Yy] ]]; then
	$sedi "s|#pGIT ||g" Vagrantfile
fi

if [[ $pNODE =~ ^[Yy] ]]; then
	$sedi "s|#pNODE ||g" Vagrantfile
fi

if [[ $pPHP =~ ^[Yy] ]]; then
	$sedi "s|#pPHP ||g" Vagrantfile
	$sedi "s|pPUBDIR|${pPUBDIR}|g" provision/php.sh

	if [[ $pCOMPOSER =~ ^[Yy] ]]; then
		$sedi "s|#pCOMPOSER ||g" Vagrantfile
	fi
fi

if [[ $pMYSQL =~ ^[Yy] ]]; then
	$sedi "s|#pMYSQL ||g" Vagrantfile
	$sedi "s|pDBNAME|${pDBNAME}|g" provision/mysql.sh
	$sedi "s|pDBPASS|${pDBPASS}|g" provision/mysql.sh

	if [[ $pPHP =~ ^[Yy] ]]; then
		$sedi "s|#pPHPMYSQL ||g" provision/mysql.sh
	fi
fi

if [ ! -z $pAPACHEPORT ]; then
	$sedi "s|#pAPACHEPORT ||g" Vagrantfile
	$sedi "s|pAPACHEPORT|${pAPACHEPORT}|g" Vagrantfile
fi

if [ ! -z $pMYSQLPORT ]; then
	$sedi "s|#pMYSQLPORT ||g" Vagrantfile
	$sedi "s|pMYSQLPORT|${pMYSQLPORT}|g" Vagrantfile
fi

if [ ! -z $pSSHPORT ]; then
	$sedi "s|#pSSHPORT ||g" Vagrantfile
	$sedi "s|pSSHPORT|${pSSHPORT}|g" Vagrantfile
fi

if [[ $pVAGRANT =~ ^[Yy] ]]; then
	vagrant up
	echo -e "\n\nYour project is running in http://${pVHOST}\n\n"
fi

