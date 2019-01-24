
# install redis:

download latest version from http://download.redis.io/releases/

```
tar -xvf redis-5.0.3.tar.gz
cd redis-5.0.3

make

# install to /usr/local/bin
make install 

```
## 2. config redis

config file:
```
mkdir ~/redis
touch ~/redis/redis.conf
```
provide a password:
```
echo test123 | shasum -a 256
```

set password: 
```
requirepass 9572d7f4e812df12cd8c0d26e7308864c33cbb51b004cbe962ad545bc377a4a2
```

## 3. start server

```
redis-server ~/redis/redis.conf &

```

Or Passing arguments via the command line:
```
./redis-server --port 6379 &
```

## 4. restart server

```
redis-server ~/redis/redis.conf restart
```

## 5. stop server

pkill redis-server
