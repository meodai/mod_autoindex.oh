#!/bin/sh

echo -n "Enter folder path > "
read newFolder
sed -i -e "s#OhSiteFolderPath#${newFolder}#g" .htaccess