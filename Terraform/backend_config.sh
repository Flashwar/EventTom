#!/bin/bash
sudo apt-get update
git clone https://github.com/Flashwar/EventTom.git
cd EventTom
echo "export SECRET_KEY=${var.SECRET_KEY_DJANGO}" >> /etc/environment
echo "export REDIS_SERVERIP=${aws_elasticache_cluster.eventtom_redis.cache_nodes[0].address}" >> /etc/environment
echo "export DATABASE_URL=postgresql://${aws_db_instance.eventtom_rds.username}:${aws_secretsmanager_secret_version.eventtom_secret_manager.secret_string}@${aws_db_instance.eventtom_rds.address}:5432/${aws_db_instance.eventtom_rds.db_name}" >> /etc/environment
echo "export WEBSITE_HOSTNAME=${aws_lb.eventtom_backend_alb.dns_name}" >> /etc/environment

pip3 install -r requirements.txt
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:8000