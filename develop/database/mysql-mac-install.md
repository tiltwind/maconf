# install mysql on MACOS

## download:
```
curl -C - -O https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.17-macos10.14-x86_64.tar.gz

# linux
# curl -C - -O https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz

tar -xvf mysql-*.tar.gz 

sudo mv mysql-8.0.17-macos10.14-x86_64 /usr/local/mysql
```

## configuration

vi /etc/profile
```
export PATH=$PATH:/usr/local/mysql/bin
```

/etc/my.cnf
```
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mysql according to the
# instructions in http://fedoraproject.org/wiki/Systemd

[mysqld_safe]
log-error=/var/log/mysql/mysql.log
pid-file=/var/run/mysql/mysql.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d
```

create dir:
```
sudo mkdir /etc/my.cnf.d
sudo mkdir /var/lib/mysql
```

## initial:

```
sudo mysqld --initialize --user=mysql
2017-10-01T07:43:27.892775Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2017-10-01T07:43:27.895962Z 0 [Warning] Setting lower_case_table_names=2 because file system for /var/lib/mysql/ is case insensitive
2017-10-01T07:43:28.090970Z 0 [Warning] InnoDB: New log files created, LSN=45790
2017-10-01T07:43:28.114923Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2017-10-01T07:43:28.180792Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 36b0e50e-a67c-11e7-b10e-01e26d7c2546.
2017-10-01T07:43:28.198305Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2017-10-01T07:43:28.203532Z 1 [Note] A temporary password is generated for root@localhost:  HdK!uzyRf8CD
➜  mysql
```

## start:
```
sudo mysqld --user=root &
```

## change password:
```
mysql -uroot -p
   #输入数据库初始化时产生的密码： HdK!uzyRf8CD
   #-------------------
   # 如果连接发生这样的错误，尝试以下方式解决：ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)
   # sudo chown -R mysql:mysql /var/lib/mysql
   # ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock

# SET PASSWORD FOR 'root'@'localhost' = PASSWORD('p0ss0rd');

SET PASSWORD FOR 'root'@'localhost' = 'p0ss0rd';
ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
```

## create db user:
```

#创建独立数据库用户
CREATE SCHEMA `auth` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
CREATE USER 'auth'@'localhost' IDENTIFIED BY 'p0ssw0rd';

GRANT ALL PRIVILEGES ON auth.* to 'auth'@'localhost';
```

