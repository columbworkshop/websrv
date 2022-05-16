#!/bin/bash
#mkdir -p /srv/docker
#git clone https://github.com/columbworkshop/websrv.git

export $(egrep -v '^#' .env | xargs)
#
echo "<?php \$dbname = "$MYSQL_DATABASE"; \$dbuser = "$MYSQL_USER"; \$dbpass = "$MYSQL_PASSWORD"; \$dbhost = "mysql"; ?>"  > ./www/default/public/vars.php
