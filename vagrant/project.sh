#!/bin/bash

num=$(find ../ -maxdepth 1 -type d -print | wc -l | sed -e 's/^[ \t]*//')

# METHODS
###########################################

insert() {
	sed -i '' "s|${2}|${3}|g" $1
}

getValue() {
	local value
	if [[ $2 =~ ^[Yy] ]]; then
		if [[ ! -z $1 ]]; then
			read -p "${3} [Default: ${1}]: " value
		else
			read -p "${3}: " value
		fi
	fi
	value=${value:-$1}
	echo $value
}

yesOrNo() {
	local value
	value=$(getValue $1 $2 "${3}")
	if [[ $value =~ ^[Yy] ]]; then
		echo 1
	else
		echo 0
	fi
}

# PROMPTS
###########################################

while true; do
	name=$(getValue "" yes "Enter project name")

	if [ -z $name ]; then
		echo "No project name entered."
	else
		dir=$(getValue $name yes "Enter project dir")

		if [ -d $dir ]; then
			echo "This directory already exists."
		else
			break
		fi
	fi
done

vagrant=$(yesOrNo yes yes "Do you want to start vagrant after install? (HIGH CPU USAGE)")
ask=$(getValue no yes "Do you wish to configure the VM yourself?")
boxName=$(getValue ubuntu/trusty64 $ask "Enter box name")
boxUrl=$(getValue https://vagrantcloud.com/ubuntu/trusty64 $ask "Enter box URL")
syncDir=$(getValue /var/www $ask "Enter synced folder")
memory=$(getValue 1024 $ask "Enter memory size")
ip=$(getValue 192.168.80.$num $ask "Enter private network IP (Required for vhosting)")

if [ ! -z $ip ]; then
	vhost=$(getValue $name.dev $ask "Enter vhost name (Requires sudo)")
fi

git=$(yesOrNo yes $ask "Install GIT on the VM?")
node=$(yesOrNo yes $ask "Install NODE on the VM?")
php=$(yesOrNo yes $ask "Install PHP on the VM?")
pubDir=$(getValue ${syncDir} $ask "Enter public dir")

if [ $php == 1 ]; then
	composer=$(yesOrNo yes $ask "Install COMPOSER on the VM? (Needed for Wordpress)")
fi

if [ $composer == 1 ]; then
	wordpress=$(yesOrNo yes $ask "Install Wordpress?")
fi

if [ $node == 1 ]; then
	gulp=$(yesOrNo yes $ask "Use gulp?")
fi

mysql=$(yesOrNo yes $ask "Install MYSQL on the VM?")

if [ $mysql == 1 ]; then
	dbName=$(getValue db $ask "Enter database name")
	dbPass=$(getValue root $ask "Enter database password")
fi

forward=$(yesOrNo no $ask "Use port forwarding?")

if [ $forward == 1 ]; then
	if [ $php == 1 ]; then
		apachePort=$(getValue "" yes "apache port")
	fi

	if [ $mysql == 1 ]; then
		mysqlPort=$(getValue "" yes "mysql port")
	fi

	sshPort=$(getValue "" yes "ssh port")
fi

assetDir=$dir
if [ $wordpress == 1 ]; then
	assetDir=$dir/wp-content/themes/$name/assets
fi

assetDir=$(getValue $assetDir $ask "Enter asset dir")

# INSERTS
###########################################

if [ $gulp == 1 ]; then
	git clone https://github.com/maeertin/coding-with-love.git $assetDir/tmp; rm -rf $assetDir/tmp/.git; mv $assetDir/tmp/assets/* $assetDir/; rm -rf $assetDir/tmp;
	insert $assetDir/package.json "\[name\]" $name
	insert $assetDir/bower.json "\[name\]" $name
fi

if [ $wordpress == 1 ]; then
	git clone https://github.com/maeertin/coding-with-love.git $dir/tmp; rm -rf $dir/tmp/.git; mv $dir/tmp/wordpress/* $dir/; rm -rf $dir/tmp;
	insert $dir/composer.json "\[name\]" $name
fi

git clone https://github.com/antoniozzo/vagrant-template.git $dir/tmp; rm -rf $dir/tmp/.git; mv $dir/tmp/* $dir/; rm -rf $dir/tmp; cd $dir
inserts=( name boxName boxUrl syncDir memory ip vhost git node php pubDir composer mysql dbName dbPass apachePort mysqlPort sshPort app )
for i in ${inserts[@]}; do
	insert Vagrantfile "\[${i}\]" ${!i}
done

if [ ! -z $ip -a ! -z $vhost ]; then
	echo "Will create a vhost in /etc/hosts, please provide password"
	sudo bash -c "echo -e '${ip}\t${vhost}' >> /etc/hosts"
fi

# if [ $vagrant == 1 ]; then
# 	vagrant up
# 	echo -e "\n\nYour project is running at http://${vhost}\n\n"
# fi
