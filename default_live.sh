#!/usr/bin/env bash
HOME_MCUS=/var/www/html/$2
WORK_SPACE_JENKIN=/var/lib/jenkins/workspace/$2/$3
HOME_CONFIG=/var/www/html/source_config/production

#--------------------------------------------------------------------------------------
#get params from jenkins
DOMAIN=$1
PATH_DEFAULT_DOMAIN_CONFIG="/etc/nginx/sites-available/"
PATH_DOMAIN_CONFIG=${PATH_DEFAULT_DOMAIN_CONFIG}${DOMAIN}".conf"
SITEROOT=${HOME_MCUS}
#copy default config
rm ${PATH_DOMAIN_CONFIG};
rm "/etc/nginx/sites-enabled/"${DOMAIN}".conf";
#copy and link config
cp "${PATH_DEFAULT_DOMAIN_CONFIG}default.conf" ${PATH_DOMAIN_CONFIG};
ln -s ${PATH_DOMAIN_CONFIG} "/etc/nginx/sites-enabled/"${DOMAIN}".conf";

#replace params
sed -i -e "s|DOMAIN|$DOMAIN|g" ${PATH_DOMAIN_CONFIG};
sed -i -e "s|SITEROOT|${SITEROOT}|g" ${PATH_DOMAIN_CONFIG};
#restart nginx
service nginx restart
#restart API
#sudo sh /home/deploy_scripts/Live/live_api.sh
#sudo sh /home/deploy_scripts/Live/live_admin.sh
#sudo sh /home/deploy_scripts/Live/afftrust.sh
echo 'Rename domain in Admin config';
cd /var/www/html/Admin_Live/public;
DOMAIN='http://'$DOMAIN'/'
sed -i -e "s|DOMAIN|$DOMAIN|g" /var/www/html/Admin_Live/public/app.config.js
#--------------------------------------------------------------------------------------

echo "****** Copy master souce code from jenkin workspace to Live ******";
rsync -az --delete --exclude='.git/' --exclude='/storage/framework/sessions/' ${WORK_SPACE_JENKIN}/ ${HOME_MCUS}/;

echo "****** Working with config file and content... ******";

cd ${HOME_MCUS}/config
mv config.php.production config.php
mv app.php.production app.php

sudo cp -r ${HOME_CONFIG}/database.php ${HOME_MCUS}/config/
sed -i "s@RANDOM_VERSION@$RANDOM@g" config.php

cd ${HOME_MCUS}/app/Exceptions
mv Handler.php.production Handler.php

echo "****** Working with permission... ******";

chown -R apache:apache ${HOME_MCUS}/storage
chown -R apache:apache ${HOME_MCUS}/storage/logs
chown -R apache:apache ${HOME_MCUS}/storage/framework
chown -R apache:apache ${HOME_MCUS}/vendor/

chmod -R 777 ${HOME_MCUS}/storage/logs
chmod -R 777 ${HOME_MCUS}/vendor/
chmod -R 777 ${HOME_MCUS}/storage
chmod -R 777 ${HOME_MCUS}/storage/framework

# End

echo "Copy robot.txt"
[ -f /var/www/html/robots.txt ] && sudo cp /var/www/html/robots.txt ${HOME_MCUS} || echo "File robots.txt not exist! Skip copy"