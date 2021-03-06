Docker LEMP basic configuration
===========================
### Docker multicontainer: Nginx (latest), php7.4-fpm, MySQL 8

### Requirements
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Installation
Create work directory:
```sh
$ mkdir -p /srv/docker
```

Clone repository
```sh
$ git clone https://github.com/columbworkshop/websrv.git
```

Set MYSQL database variables in `.env` file
```sh

MYSQL_USER=user
MYSQL_PASSWORD=password
MYSQL_DATABASE=sites
MYSQL_ROOT_PASSWORD=root_passwordo
DB_CONNECTION=mysql
DB_HOST=mysql
```

Run `init.sh` script to create `vars.php` file in `www/default/public` directory for db connection tests
Example of `vars.php` file:
```sh
<?php $dbname = sites; $dbuser = user; $dbpass = password; $dbhost = mysql; ?>
```

Start docker compose
```sh
$ docker-compose up -d

Creating network "websrv_network01" with driver "bridge"
Creating php   ... done
Creating mysql ... done
Creating nginx ... done
Creating redis ... done
```

### Checkup
Check containers state:
```sh
$ docker-compose ps

Name               Command               State                                                    Ports
-------------------------------------------------------------------------------------------------------------------------------
mysql   bash -c chown -R mysql:mys ...   Up      3306/tcp, 33060/tcp
nginx   /docker-entrypoint.sh ngin ...   Up      0.0.0.0:443->443/tcp,:::443->443/tcp, 0.0.0.0:6003->6003/tcp,:::6003->6003/tcp,
                                                 0.0.0.0:80->80/tcp,:::80->80/tcp
php     bash -c cron && exec docke ...   Up      6003/tcp, 9000/tcp
redis   /opt/bitnami/scripts/redis ...   Up      6379/tcp

```

Check if webserver running and shows phpinfo
- [http://localhost](http://localhost)

Check if db connection is running
- [http://localhost/dbtest.php](http://localhost/dbtest.php)

### Folder's structure
List the contents
```sh
├── README.md
│
├── config
│   ├── nginx
│   │   └── default.conf
│   ├── php-fpm
│   │   └── php-fpm.conf
│   │   └── php.ini
│   └── mysql
│       └── conf.d
│       └── my.cnf
│       └── mysql.conf.d   
│
├── docker-compose.yml
│
├── logs
│   ├── .gitignore
│   ├── nginx
│   │   ├── access.log
│   │   └── error.log
│   ├── mysql
│   │   ├── error.log
│   │   └── log_output.log
│   └── php
│       └── cron.log
│
├── www
│   └── default
│       └── public
│           ├── index.php
│           ├── vars.php
│           └── dbtest.php
├── php
│   ├── Dockerfile
│   └── cronjobs
│ 
├── mysqldumps
│   ├── .gitignore
│   └── mysqldump-XXXX.gz
│
├── ssl
│   ├── fullchain.pem 
│   └── privkey.pem
│
├── .data (_mysql persistent data_)
├── .env
├── .git
└── .gitignore
 
```

### Web site Configuration
Adding new site (for example `new-site`)
1. add files for the new site in directory `www/new-site/public/index.php` # index.php for exapmle 
2. add new nginx configuration file for site in local directory `config/nginx` with root directive in config file `root /var/www/html/new-site/public;`
3. restart nginx container - `docker-compose restart nginx`

### Network connection to services
All network connections can be established by names of services.
#### Connection to Mysql:
```
<?php
$link = mysql_connect('mysql', '_USERNAME_', '_PASSWORD_');
if (!$link) {
    die('Could not connect: ' . mysql_error());
}
echo 'Connected successfully';
mysql_close($link);
?>
```
#### Connection to Redis 
```
<?php 
   //Connecting to Redis server 
   $redis = new Redis(); 
   $redis->connect('redis', 6379); 
   echo "Connection to server sucessfully"; 
   //check whether server is running or not 
   echo "Server is running: ".$redis->ping(); 
?>
```
 
### Basic operations
List the containers
```sh
$ docker-compose ps

     Name                  Command             State                     Ports
-------------------------------------------------------------------------------------------------
mysql   bash -c chown -R mysql:mys ...   Up      3306/tcp, 33060/tcp
nginx   /docker-entrypoint.sh ngin ...   Up      0.0.0.0:443->443/tcp,:::443->443/tcp, 0.0.0.0:6003->6003/tcp,:::6003->6003/tcp,
                                                 0.0.0.0:80->80/tcp,:::80->80/tcp
php     bash -c cron && exec docke ...   Up      6003/tcp, 9000/tcp
redis   /opt/bitnami/scripts/redis ...   Up      6379/tcp
```

Stop containers docker compose
```sh
$ docker-compose stop

```

Restart all containers
```sh
$ docker-compose restart

```

Restart one container by it's name (mysql for example)
```sh
$ docker-compose restart mysql

```

Remove containers
```sh
$ docker-compose rm -f
```

### Tips
Connect to Docker container (mysql for example)
```sh
$ docker exec -it mysql /bin/bash 
```

Stop all containers
```sh
$ docker-compose stop
```

### Mysql dump
Make full dump of database for running container `mysql`  

```sh
docker exec mysql /usr/bin/mysqldump -u root --password=root_passwordo --all-databases | gzip > mysqldumps/mysqldump-$(date +%Y%m%d-%H:%M:%S).gz
```

### PHP Cron jobs
To make cron job for php you can edit `php/cronjobs` file and add one job in one string, for example:
```sh
* * * * * echo "Hello world" >> /var/log/php/cron.log
```
After file was updated - restart and rebuild php container (it'll be partial rebuild and it's very fast)
```sh
docker-compose stop php
docker-compose up -d --build php
```

### Certbot 
To check if you can get SSL cert for domain `example.org` use the command with `--dry-run` option:
```sh
docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d example.org
```

To get real SSL cert for domain `example.org` use the command without `--dry-run` option:
```sh
docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ -d example.org
```

All certificates will be saved in `certbot/conf` directory and can be copied to `ssl` folder.
`ssl` folder has linked as volume to nginx container 
