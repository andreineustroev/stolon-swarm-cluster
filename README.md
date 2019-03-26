1. Собрать образ
~~~
docker build -t andreineustroev/stolon:11.2 .
docker push andreineustroev/stolon:11.2
~~~
(Опционально)Можно использовать другое имя образа, для этого его нужно поменять и в docker-compose файлах
~~~
sed -i 's$andreineustroev/stolon:11.2$new_image_name$g' docker-compose.yml
sed -i 's$andreineustroev/stolon:11.2$new_image_name$g' docker-compose-pg.yml
~~~
2. настроить docker swarm
на одной из нод
~~~
docker swarm init
docker swarm join-token manager
~~~
на остальных выполнить команду которую выведет docker swarm join-token manager
3. Перенести на любую из нод эту директорию
4. Назначить лейблы нодам !!! консул нод должно быть нечетное количество (1 мастер и 2 слейва) !!!
Например так
~~~
docker node update --label-add consul=master host1 && \
docker node update --label-add consul=slave host2 && \
docker node update --label-add consul=slave host3 && \
docker node update --label-add nodename=node1 host1 && \
docker node update --label-add nodename=node2 host2 && \
docker node update --label-add nodename=node3 host3
~~~
5. Задеплоить консул в стеке consul
~~~
docker stack deploy --compose-file docker-compose.yml consul
~~~
Дождаться инициализации консула
~~~
команда curl http://127.0.0.1:8500/v1/status/peers
~~~
должна вернуть 3 ip адреса
6. Исполнить комманду инициализации кластера stolon
~~~
./stolonctl --cluster-name=stolon-cluster --store-backend=consul --store-endpoints http://127.0.0.1:8500 init
~~~
7. В файле spec.json можно поправить настройки pg, сейчас там параметры для тестовых виртуалок с 1Гб оперативной памяти
Описание параметров https://github.com/sorintlab/stolon/blob/master/doc/cluster_spec.md
8. Настроить кластер
~~~
./stolonctl --cluster-name=stolon-cluster --store-backend=consul --store-endpoints http://127.0.0.1:8500 update --patch -f spec.json
~~~
9. Запустить кластер  в стеке pg
~~~
docker stack deploy --compose-file docker-compose-pg.yml pg
~~~
10. Можно посмотреть статус кластера
~~~
./stolonctl --cluster-name=stolon-cluster --store-backend=consul --store-endpoints http://127.0.0.1:8500 status
~~~
В инициализированном состоянии
~~~
=== Active sentinels ===

ID      LEADER
324d180f    true
748a14ad    false

=== Active proxies ===

ID
3f8add14
b2ac2ddc
f1aa20ba

=== Keepers ===

UID HEALTHY PG LISTENADDRESS    PG HEALTHY  PG WANTEDGENERATION PG CURRENTGENERATION
keeper1 true    keeper1:5432        true        2           2   
keeper2 true    keeper2:5432        true        2           2   
keeper3 true    keeper3:5432        true        4           4   

=== Cluster Info ===

Master: keeper3

===== Keepers/DB tree =====

keeper3 (master)
├─keeper2
└─keeper1

~~~
* Посмотреть настройки кластера
~~~
./stolonctl --cluster-name=stolon-cluster --store-backend=consul --store-endpoints http://127.0.0.1:8500 spec
~~~
Пример настроек
~~~{
    "synchronousReplication": true,
    "additionalWalSenders": null,
    "additionalMasterReplicationSlots": null,
    "usePgrewind": true,
    "initMode": "new",
    "pgParameters": {
        "datestyle": "iso, mdy",
        "default_text_search_config": "pg_catalog.english",
        "dynamic_shared_memory_type": "posix",
        "effective_cache_size": "256MB",
        "lc_messages": "en_US.utf8",
        "lc_monetary": "en_US.utf8",
        "lc_numeric": "en_US.utf8",
        "lc_time": "en_US.utf8",
        "log_timezone": "UTC+3",
        "maintenance_work_mem": "128MB",
        "max_connections": "100",
        "max_wal_size": "1GB",
        "min_wal_size": "80MB",
        "shared_buffers": "256MB",
        "timezone": "UTC",
        "wal_buffers": "1MB",
        "wal_level": "replica",
        "work_mem": "1MB"
    },
    "pgHBA": null,
    "automaticPgRestart": false
}
~~~
11. (Опционально) Отключить синхронную репликацию
~~~
./stolonctl --cluster-name=stolon-cluster --store-backend=consul --store-endpoints http://127.0.0.1:8500 update --patch '{ "synchronousReplication" : false }'
~~~