up:
	docker-compose up -d

stop:
	docker-compose stop

down:
	docker-compose down

down-rmi:
	docker-compose down --rmi all
ps:
	docker-compose ps

migrate-fresh:
	docker-compose exec app php artisan migrate:fresh

migrate-refresh:
	docker-compose exec app php artisan migrate:refresh

seed:
	docker-compose exec app php artisan db:seed

tinker:
	docker-compose exec app php artisan tinker

cache-clear:
	docker-compose exec app php artisan cache:clear

view-clear:
	docker-compose exec app php artisan view:clear

config-clear:
	docker-compose exec app php artisan config:clear

phpunit:
	docker-compose exec app vendor/bin/phpunit --testdox

phpcsfix:
	docker-compose exec app vendor/bin/php-cs-fixer fix -v

phpcs:
	docker-compose exec app vendor/bin/phpcs --standard=phpcs.xml --extensions=php .

phpmd:
	docker-compose exec app vendor/bin/phpmd . text ruleset.xml --suffixes php --exclude node_modules,resources,storage,vendor

nginx-t:
	docker-compose exec nginx ash -c 'nginx -t'

nginx-reload:
	docker-compose exec nginx ash -c 'nginx -s reload'

nginx-reload:
	docker-compose exec nginx ash -c 'nginx -s stop'

mysql:
	docker-compose exec db bash -c 'mysql -u $$MYSQL_USER -p$$MYSQL_PASSWORD $$MYSQL_DATABASE'

circleci:
	cd app/backend && circleci build