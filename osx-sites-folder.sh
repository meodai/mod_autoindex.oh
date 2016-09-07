#!/usr/bin/env bash

# this script does that:
# https://coolestguidesontheplanet.com/get-apache-mysql-php-phpmyadmin-working-osx-10-10-yosemite/

# store $USER because it could be ROOT after sudo
ME=$USER;

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Start OSX apache
sudo apachectl start
mkdir ~/Sites

# create new bash profile
sudo cat >/etc/apache2/users/$ME.conf <<EOF
<Directory "/Users/$ME/Sites/">
    AllowOverride All
    Options Indexes MultiViews
    Options +FollowSymLinks
    Require all granted
</Directory>
EOF

# changes chmod of username.conf file
sudo chmod 644 /etc/apache2/users/$ME.conf

# creates a multiline variable containing the lines to uncomment in httpd.conf
read -r -d '' directives << EOM
LoadModule authz_core_module libexec/apache2/mod_authz_core.so
LoadModule authz_host_module libexec/apache2/mod_authz_host.so
LoadModule userdir_module libexec/apache2/mod_userdir.so
LoadModule include_module libexec/apache2/mod_include.so
LoadModule rewrite_module libexec/apache2/mod_rewrite.so
Include /private/etc/apache2/extra/httpd-userdir.conf
EOM

# set for delimiter to new line and saves the old delimiter
IFSBack="$IFS"
IFS=$"\n"

# uncomments lines in httpd.conf
echo "Configure apatche:"
for directive in directives;
do
  sudo sed -i "s|^#$directive|$directive|g" /etc/apache2/httpd.conf
done;

directive='Include /private/etc/apache2/users/*.conf';
sudo sed -i "s|^#$directive|$directive|g" /etc/apache2/extra/httpd-userdir.conf;


# set IFS back to what it was
IFS="$IFSBack"

unset directive;
unset directives;
unset IFSBack
unset ME

# restart apatche
sudo apachectl restart;

# open your user directory in the browser
open http://localhost/~$USER/
