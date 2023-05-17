
# zfs_disk

## Описание/Пошаговая инструкция выполнения домашнего задания:
Для выполнения домашнего задания используйте методичку
Практические навыки работы с ZFS https://docs.google.com/document/d/1xursgUsGDVTLh4B_r0XGw_flPzd5lSJ0nfMFL-HQmFs/edit?usp=share_link
Что нужно сделать?

**Определить алгоритм с наилучшим сжатием.**
**Зачем: отрабатываем навыки работы с созданием томов и установкой параметров. Находим наилучшее сжатие.**
_Шаги:_
1. определить какие алгоритмы сжатия поддерживает zfs (gzip gzip-N, zle lzjb, lz4);
2. создать 4 файловых системы на каждой применить свой алгоритм сжатия;
3. Для сжатия использовать либо текстовый файл либо группу файлов:
4. скачать файл “Война и мир” и расположить на файловой системе wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8, либо скачать файл ядра распаковать и расположить на файловой системе.
_Результат:_
1. список команд которыми получен результат с их выводами;
2. вывод команды из которой видно какой из алгоритмов лучше.
**Определить настройки pool’a.**
**Зачем: для переноса дисков между системами используется функция export/import. Отрабатываем навыки работы с файловой системой ZFS.**
_Шаги:_
1. загрузить архив с файлами локально.
2. https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
3. Распаковать.
4. с помощью команды zfs import собрать pool ZFS;
5. командами zfs определить настройки:
6. размер хранилища;
7. тип pool;
8. значение recordsize;
9. какое сжатие используется;
10. какая контрольная сумма используется.
_Результат:_
1. список команд которыми восстановили pool . Желательно с Output команд;
2. файл с описанием настроек settings.
**Найти сообщение от преподавателей.**
**Зачем: для бэкапа используются технологии snapshot. Snapshot можно передавать между хостами и восстанавливать с помощью send/receive. Отрабатываем навыки восстановления snapshot и переноса файла.**
_Шаги:_
1. скопировать файл из удаленной директории. https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing
2. Файл был получен командой zfs send otus/storage@task2 > otus_task2.file
3. восстановить файл локально. zfs receive
4. найти зашифрованное сообщение в файле secret_message
_Результат:_
1. список шагов которыми восстанавливали;
2. зашифрованное сообщение.


## Результаты:

### Задание 1
Проверяем командой lsblsk список доступных дисков которые есть на виртуальной машине![lsblk](https://user-images.githubusercontent.com/85576634/234539582-461ff77c-40dc-42e8-8ecf-8f13a34dbdf3.jpg)
```bash
# Создание 4 пулов
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi

# устанавливаем различиные методы сжатия
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4

# Скачиваем файл в каждый пул
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done

zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  21.6M   330M     21.5M  /otus1
otus2  17.7M   334M     17.6M  /otus2
otus3  10.8M   341M     10.7M  /otus3
otus4  39.1M   313M     39.0M  /otus4
#
# gzip-9 is most effective
```

### Задание 2

```bash
# получение архива
wget -O archive.tar.gz --no-check-certificate https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
tar -xzvf archive.tar.gz
zpool import -d zpoolexport/ otus
zpool import -d zpoolexport/ otus newotus

 zpool status
  pool: newotus
 state: ONLINE
  scan: none requested
config:

        NAME                                 STATE     READ WRITE CKSUM
        newotus                              ONLINE       0     0     0
          mirror-0                           ONLINE       0     0     0
            /home/vagrant/zpoolexport/filea  ONLINE       0     0     0
            /home/vagrant/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: otus1
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

errors: No known data errors

zfs get available newotus
# NAME     PROPERTY   VALUE  SOURCE
# newotus  available  350M   -     
zfs get readonly newotus
# NAME     PROPERTY  VALUE   SOURCE 
# newotus  readonly  off     default
zfs get recordsize newotus
# NAME     PROPERTY    VALUE    SOURCE
# newotus  recordsize  128K     local 
zfs get compression newotus
# NAME     PROPERTY     VALUE     SOURCE
# newotus  compression  zle       local 
zfs get checksum newotus
# NAME     PROPERTY  VALUE      SOURCE
# newotus  checksum  sha256     local 
```

### Задание 3

```bash
wget -O otus_task2.file --no-check-certificate https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
zfs receive newotus/test@today < otus_task2.file
find /newotus/test -name "secret_message"
# /newotus/test/task1/file_mess/secret_message
cat /newotus/test/task1/file_mess/secret_message
# https://github.com/sindresorhus/awesome
```
