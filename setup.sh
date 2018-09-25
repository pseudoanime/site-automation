#!/usr/bin/env

sudo -u vagrant git pull origin master
if [ ! -f .env.dev ]; then
    if [ ! -f .env.example ]; then
        laravel new
     fi
    cp .env.example .env
    echo -n "WHAT IS THE NAME OF THE DATABASE FOR THIS APP"
    read DATABASE
    echo "UPDATING DATABASE CONFIGURATION FILE"
    sed -i "s/DB_DATABASE=homestead/DB_DATABASE=$DATABASE/" .env
    sed -i "s/DB_USERNAME=homestead/DB_USERNAME=root/" .env
    sed -i "s/DB_PASSWORD=secret/DB_PASSWORD=vagrant/" .env
    php artisan key:generate
    cp  .env .env.qa
    cp .env .env.live
else
    cp .env .env.dev
    DATABASE=`sed -n '/^DB_DATABASE/p' .env`;
    DATABASE=${DATABASE#"DB_DATABASE="}
fi
echo "RUNNING COMPOSER"
sudo -u vagrant composer install
sudo -u vagrant composer update
echo "CREATING MYSQL DATABASE"
mysql -uroot -pvagrant -e "create DATABASE $DATABASE"
echo "MIGRATING AND SEEDING"
php artisan migrate:refresh --seed
    echo -n "WHAT IS THE SITENAME FOR THIS APP"
    read SITENAME
cd /etc/nginx/sites-available/
cp forum.dev $SITENAME
sed -i "s/forum.labs/$SITENAME/" $SITENAME
nginx-modsite -e
service php7.2-fpm reload
