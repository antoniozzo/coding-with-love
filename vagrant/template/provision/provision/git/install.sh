#!/usr/bin/env bash
 
echo "Installing git.."
sudo apt-get -y install git

gitignore=$(cat <<EOF
### OSX
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

### Vagrant
acceptance_config.yml
boxes/*
/.vagrant
/website/docs/.vagrant
/website/www/.vagrant
/vagrant-spec.config.rb

### Composer
composer.lock
/vendor/

### Npm
node_modules/

### Wordpress
wp/
/wp-content/advanced-cache.php
/wp-content/backup-db/
/wp-content/backups/
/wp-content/blogs.dir/
/wp-content/cache/
/wp-content/upgrade/
/wp-content/uploads/
/wp-content/wp-cache-config.php
EOF)

if [ ! -f $1/.gitignore ]; then
	echo "${gitignore}" > $1/.gitignore
fi