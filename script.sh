#!/bin/bash

# создание 4 пулов
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi

# установка сжатия
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4

# скачивание файла в каждый из пулов
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done

# [root@zfs vagrant]# zfs list
# NAME    USED  AVAIL     REFER  MOUNTPOINT
# otus1  21.6M   330M     21.5M  /otus1
# otus2  17.7M   334M     17.6M  /otus2
# otus3  10.8M   341M     10.7M  /otus3
# otus4  39.1M   313M     39.0M  /otus4
#
# gzip-9 is most effective


# получение архива
wget -O archive.tar.gz --no-check-certificate https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
tar -xzvf archive.tar.gz
zpool import -d zpoolexport/ otus
zpool import -d zpoolexport/ otus newotus

# получение нового файла
wget -O otus_task2.file --no-check-certificate https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
zfs receive newotus/test@today < otus_task2.file
find /newotus/test -name "secret_message"
cat /newotus/test/task1/file_mess/secret_message
