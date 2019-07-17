<!---
markmeta_author: wongoo
markmeta_date: 2019-07-17
markmeta_title: redis install
markmeta_categories: app
markmeta_tags: redis
-->

# Install Mongodb

检查最新版本: https://www.mongodb.com/download-center/community

```
curl -O https://fastdl.mongodb.org/osx/mongodb-osx-ssl-x86_64-4.0.5.tgz
tar -zxvf mongodb-osx-ssl-x86_64-4.0.5.tgz

mv mongodb-osx-x86_64-4.0.5/ /app/mongodb

# add the following line to your shell’s rc file (e.g. ~/.bashrc):

export PATH=$PATH:/app/mongodb/bin

mkdir -p /app/mongodb/data
mkdir -p /app/mongodb/log

```

start.sh

```

#!/bin/bash
export MONGO_HOME=/app/mongodb

$MONGO_HOME/bin/mongod --dbpath $MONGO_HOME/data --bind_ip=127.0.0.1 --fork --logpath $MONGO_HOME/log/mongod.log &
```

add admin:
```
> mongo

use admin

db.createUser(
   {
     user: "super",
     pwd: "supWDxsf67%H",
     roles: [ "root"]
   }
)
```

 create app user:
 
```
# start mongodb client
> mongo

use app
db.createUser(
   {
     user: "appuser",
     pwd: "my_app_pass",
     roles: [ "readWrite", "dbAdmin" ]
   }
)
db.getUsers()

db.createUser(
   {
     user: "content",
     pwd: "content",
     roles: [ "readWrite", "dbAdmin" ]
   }
)

db.createUser(
   {
     user: "auth",
     pwd: "auth",
     roles: [ "readWrite", "dbAdmin" ]
   }
)
```
