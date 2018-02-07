.PHONY: *

all: init 

build-base:
	docker build -t build-env -f Dockerfile.build .

init:
	composer install

reset:
	docker exec -it magento php bin/magento setup:install \
	--base-url=http://$$(curl checkip.amazonaws.com) \
	--db-host=mariadb --db-name=magento --db-user=root --db-password=mariaSql \
	--admin-firstname=Magento --admin-lastname=User --admin-email=user@example.com \
	--admin-user=admin --admin-password=admin123 --language=en_US \
	--currency=USD --timezone=America/Chicago --use-rewrites=1 
	docker exec -it magento git clone https://github.com/magento/magento2-sample-data.git
	docker exec -it magento	php -f magento2-sample-data/dev/tools/build-sample-data.php -- --ce-source="."
	docker exec -it magento	php bin/magento setup:upgrade
	docker exec -it magento chown -R www-data:www-data /var/www/html/ 

up: 
	docker-compose up -d

down:
	docker-compose down
