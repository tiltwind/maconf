# docker ce install (macOS ARM)

macOS 无法原生安装 Docker Engine(CE),需借助 Colima 在轻量级 Linux 虚拟机中运行 Docker 守护进程,再用 Homebrew 安装 docker CLI 客户端连接。

> **Colima 的作用**:Docker Engine(CE)只能跑在 Linux 上,macOS 内核不支持。Colima(Containers on Lima)基于 Lima 在后台启动一个最小化的 Linux 虚拟机(Apple 芯片上用原生 ARM 虚拟化,性能开销小),并在其中安装、运行 Docker 守护进程(dockerd);同时它把虚拟机里的 Docker socket 暴露给宿主机,使本机的 `docker` / `docker-compose` 命令可以直接连接使用。
>
> 简单说:**Colima = 提供并管理跑 Docker 守护进程的 Linux 虚拟机**,是 Docker Desktop 的开源、免授权费替代方案(无 GUI、命令行管理、资源占用更低)。

## 1. 安装 Homebrew(已安装可跳过)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. 安装 docker CLI、docker-compose 与 Colima

```bash
brew install docker docker-compose colima
```

## 3. 启动 Colima(创建并运行 Linux 虚拟机)

```bash
# 默认启动
colima start

# 指定资源(ARM 架构,4 核 8G 内存 60G 磁盘)
colima start --arch aarch64 --cpu 4 --memory 8 --disk 60
```

## 4. 验证安装

```bash
docker version
docker info
docker run --rm hello-world
```

## 5. 常用 Colima 管理命令

```bash
colima status      # 查看状态
colima stop        # 停止
colima restart     # 重启(修改配置后需重启)
colima delete      # 删除虚拟机
```

# docker config

镜像加速等配置写在 Colima 虚拟机内的 `/etc/docker/daemon.json`,可通过 `colima ssh` 进入虚拟机查看或编辑,修改后执行 `colima restart` 生效。

```bash
colima ssh
cat /etc/docker/daemon.json
```

```json
{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "registry-mirrors": [
"https://proxy.1panel.live",
"https://docker.1panel.top",
"https://docker.1ms.run",
"https://docker.ketches.cn",
"https://docker.hpcloud.cloud",
"https://docker.1panel.live",
"http://mirrors.ustc.edu.cn",
"http://mirror.azure.cn"
  ]
}
```

Colima 虚拟机内可能没有 `vi`/`nano` 等编辑器,推荐用以下方式修改配置。

## 方法:用 Colima 配置文件(推荐)

Colima 支持在它自己的配置里声明 docker 守护进程参数,启动时会自动写入虚拟机的 `daemon.json`,无需进虚拟机、也不依赖编辑器;且配置由 Colima 托管,虚拟机重建/删除后可复现。

```bash
colima stop
colima start --edit     # 打开 Colima 配置(用宿主机的默认编辑器)
```

在配置文件里找到 `docker:` 段,填入(会合并进 `/etc/docker/daemon.json`):

```yaml
docker:
  dns:
    - 8.8.8.8
    - 8.8.4.4
  registry-mirrors:
    - https://docker.1panel.live
    - https://docker.1ms.run
    - http://mirrors.ustc.edu.cn
```

保存退出后 Colima 会自动重启并应用。后续修改也可再次执行 `colima start --edit`,或直接编辑 `~/.colima/default/colima.yaml` 后 `colima restart`。

# 常见 docker 服务安装

> **Apple 芯片(ARM)注意**:部分镜像(如 SQL Server、Oracle 官方镜像)只提供 amd64 架构,在 ARM 上运行需要 x86 模拟。建议启用 Rosetta 加速:
> ```bash
> colima start --vm-type vz --vz-rosetta --memory 8
> ```
> 运行 amd64 镜像时显式指定平台:`docker run --platform linux/amd64 ...`

## SQL Server

官方镜像 `mssql/server` 仅 amd64,ARM 上需配合 Rosetta + `--platform`;也可用原生 ARM 的 `azure-sql-edge`(功能为 SQL Server 子集)。

```bash
# 原生 ARM 替代(Azure SQL Edge)
docker run --name sqlserver \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=Str0ng#Passw0rd" \
  -p 1433:1433 \
  mcr.microsoft.com/azure-sql-edge:latest

# 官方镜像(amd64,需 Rosetta)
docker run -d --name sqlserver \
  --platform linux/amd64 \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=Str0ng#Passw0rd" \
  -p 1433:1433 \
  -v sqlserver-data:/var/opt/mssql \
  mcr.microsoft.com/mssql/server:2022-latest
```

连接:`sa` / `Str0ng#Passw0rd`,端口 `1433`(密码需满足复杂度:大小写+数字+符号,至少 8 位)。

## Oracle

官方 `database/free` 镜像为 amd64;社区镜像 `gvenzl/oracle-free` 提供 arm64 支持,Apple 芯片首选。

```bash
# 社区镜像(支持 arm64,推荐)
docker run --name oracle \
  -e ORACLE_PASSWORD=Str0ng#Passw0rd \
  -p 1521:1521 \
  -v oracle-data:/opt/oracle/oradata \
  gvenzl/oracle-free:latest

# 官方镜像(amd64,需 Rosetta)
docker run -d --name oracle \
  --platform linux/amd64 \
  -e ORACLE_PWD=Str0ng#Passw0rd \
  -p 1521:1521 \
  container-registry.oracle.com/database/free:latest
```

连接:服务名 `FREEPDB1`,用户 `system` / 上面设置的密码,端口 `1521`。

## MySQL

```bash
docker run --name mysql \
  -e MYSQL_ROOT_PASSWORD=Str0ng#Passw0rd \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0
```

## PostgreSQL

```bash
docker run --name postgres \
  -e POSTGRES_PASSWORD=Str0ng#Passw0rd \
  -e POSTGRES_DB=testdb \
  -p 5432:5432 \
  -v pg-data:/var/lib/postgresql \
  postgres:18
```

## 常用容器管理命令

```bash
docker ps -a                 # 查看容器
docker logs -f <name>        # 查看日志
docker exec -it <name> bash  # 进入容器
docker stop/start <name>     # 停止/启动
docker rm -f <name>          # 删除容器
docker volume ls             # 查看数据卷
```



## docker-compose
```bash
brew install docker-compose
docker-compose up
docker-compose down

# 显式指定文件
docker-compose -f docker-compose.yml up
# 后台启动
docker-compose -f docker-compose.yml up -d

```