#!/bin/bash

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

git clone https://github.com/antoniozzo/vagrant-template.git $pDIR/tmp
rm -rf $pDIR/tmp/.git
mv $pDIR/tmp/* $pDIR/
rm -rf $pDIR/tmp
cd $pDIR

read -p "Do you wish to configure the VM yourself? [Default: no]: " pCONF
if [[ $pCONF =~ ^[Yy] ]]; then
	read -p "Enter box name [Default: ubuntu/trusty64]: " pBOX
	read -p "Enter box URL [Default: https://vagrantcloud.com/ubuntu/trusty64]: " pBOXURL
	read -p "Enter synced folder [Default: /var/www]: " pTDIR
	read -p "Enter memory size [Default: 1024]: " pMEM
	read -p "Enter private network IP (Required for vhosting) [Default: ${IP}]: " pIP
	if [ ! -z $pIP ]; then
		read -p "Do you wish use a vhost? (Requires sudo) [Default: ${pNAME}.dev]: " pVHOST
	fi
	read -p "Do you wish to install GIT on the VM? [Default: yes]: " pGIT
	read -p "Do you wish to install NODE on the VM? [Default: yes]: " pNODE
	read -p "Do you wish to install PHP on the VM? [Default: yes]: " pPHP
	if [[ $pPHP =~ ^[Yy] ]]; then
		read -p "Enter public dir [Default: ${pTDIR}public]: " pPUBDIR
		read -p "Do you wish to install COMPOSER on the VM? [Default: yes]: " pCOMPOSER
	fi
	read -p "Do you wish to install MYSQL on the VM? [Default: yes]: " pMYSQL
	if [[ $pMYSQL =~ ^[Yy] ]]; then
		read -p "Enter database name [Default: db]: " pDBNAME
		read -p "Enter database password [Default: root]: " pDBPASS
	fi
	read -p "Do you want to use port forwarding? [Default: no]: " pFORWARD
	if [[ $pFORWARD =~ ^[Yy] ]]; then
		if [[ $pPHP =~ ^[Yy] ]]; then
			read -p "apache port: " pAPACHEPORT
		fi
		if [[ $pMYSQL =~ ^[Yy] ]]; then
			read -p "mysql port: " pMYSQLPORT
		fi
		read -p "ssh port: " pSSHPORT
	fi
	read -p "Do you want to start vagrant after install? [Default: yes]: " pVAGRANT
else
	unset pBOX
	unset pBOXURL
	unset pTDIR
	unset pMEM
	unset pVHOST
	unset pGIT
	unset pNODE
	unset pPHP
	unset pCOMPOSER
	unset pMYSQL
	unset pDBNAME
	unset pDBPASS
	unset pVAGRANT
	unset pIP
	unset pPUBDIR
	unset pAPACHEPORT
	unset pMYSQLPORT
	unset pSSHPORT
fi

pBOX=${pBOX:-ubuntu/trusty64}
pTDIR=${pTDIR:-/var/www/}
pMEM=${pMEM:-1024}
pVHOST=${pVHOST:-$pNAME.dev}
pGIT=${pGIT:-yes}
pNODE=${pNODE:-yes}
pPHP=${pPHP:-yes}
pCOMPOSER=${pCOMPOSER:-yes}
pMYSQL=${pMYSQL:-yes}
pDBNAME=${pDBNAME:-db}
pDBPASS=${pDBPASS:-root}
pVAGRANT=${pVAGRANT:-yes}

URL=https://vagrantcloud.com/ubuntu/trusty64
pBOXURL=${pBOXURL:-$URL}

IP=192.168.80.$(find ../ -maxdepth 1 -type d -print | wc -l | sed -e 's/^[ \t]*//')
pIP=${pIP:-$IP}

DIR=$pTDIRpublic
pPUBDIR=${pPUBDIR:-$DIR}

sed -i '' "s|pNAME|${pNAME}|g" Vagrantfile
sed -i '' "s|pBOXNAME|${pBOX}|g" Vagrantfile
sed -i '' "s|pBOXURL|${pBOXURL}|g" Vagrantfile
sed -i '' "s|pTDIR|${pTDIR}|g" Vagrantfile
sed -i '' "s|pMEM|${pMEM}|g" Vagrantfile

if [ ! -z $pIP ]; then
	sed -i '' "s|#pIP ||g" Vagrantfile
	sed -i '' "s|pIP|${pIP}|g" Vagrantfile

	if [ ! -z $pVHOST ]; then
		sudo bash -c "echo -e '${pIP}\t${pVHOST}' >> /etc/hosts"
	fi
fi

if [[ $pGIT =~ ^[Yy] ]]; then
	sed -i '' "s|#pGIT ||g" Vagrantfile
fi

if [[ $pNODE =~ ^[Yy] ]]; then
	sed -i '' "s|#pNODE ||g" Vagrantfile
fi

if [[ $pPHP =~ ^[Yy] ]]; then
	sed -i '' "s|#pPHP ||g" Vagrantfile
	sed -i '' "s|pPUBDIR|${pPUBDIR}|g" provision/php.sh

	if [[ $pCOMPOSER =~ ^[Yy] ]]; then
		sed -i '' "s|#pCOMPOSER ||g" Vagrantfile
	fi
fi

if [[ $pMYSQL =~ ^[Yy] ]]; then
	sed -i '' "s|#pMYSQL ||g" Vagrantfile
	sed -i '' "s|pDBNAME|${pDBNAME}|g" provision/mysql.sh
	sed -i '' "s|pDBPASS|${pDBPASS}|g" provision/mysql.sh

	if [[ $pPHP =~ ^[Yy] ]]; then
		sed -i '' "s|#pPHPMYSQL ||g" provision/mysql.sh
	fi
fi

if [ ! -z $pAPACHEPORT ]; then
	sed -i '' "s|#pAPACHEPORT ||g" Vagrantfile
	sed -i '' "s|pAPACHEPORT|${pAPACHEPORT}|g" Vagrantfile
fi

if [ ! -z $pMYSQLPORT ]; then
	sed -i '' "s|#pMYSQLPORT ||g" Vagrantfile
	sed -i '' "s|pMYSQLPORT|${pMYSQLPORT}|g" Vagrantfile
fi

if [ ! -z $pSSHPORT ]; then
	sed -i '' "s|#pSSHPORT ||g" Vagrantfile
	sed -i '' "s|pSSHPORT|${pSSHPORT}|g" Vagrantfile
fi

if [[ $pVAGRANT =~ ^[Yy] ]]; then
	vagrant up
fi

