# Code-Server

自用的 Code Server 镜像，每日构建

---

## 使用

Docker 镜像启动参数以 [coder/code-server](https://github.com/coder/code-server) 为准。

启动脚本示例（特别注意替换密码 `YOUR_PASSWORD_HERE`，如果不需要请删除对应环境参数）

```bash
DATA_DIR="$HOME"
# DATA_DIR="/mnt/data"
mkdir -p $DATA_DIR/workspace
mkdir -p $DATA_DIR/docker/vscode/.config
chmod 777 -R $DATA_DIR/docker/vscode
chmod 777 -R $DATA_DIR/workspace

docker run -d \
 --restart always \
 --name vscode \
 --privileged \
 -v $DATA_DIR/workspace:/root/workspace:rw \
 -v $DATA_DIR/docker/vscode:/root/.config:rw \
 -v $HOME/.ssh:/root/.ssh \
 -v $HOME/.gitdir:/root/.gitdir \
 -e PASSWORD=YOUR_PASSWORD_HERE \
 -e TZ=Asia/Shanghai \
 -e PUID=$(id -u ${USER}) \
 -e PGID=$(id -g ${USER}) \
 ofwh/code-server:latest \
 /root/workspace \
 --bind-addr 0.0.0.0:8080
```

部分本地参数说明

> 仓库代码： `/data/workspace`<br>
> 配置映射：`/data/docker/vscode`<br>
> SSH密钥：`$HOME/.ssh`<br>
> GIT配置：`$HOME/.gitdir`

GIT公共配置放置在镜像的 `/root/.gitconfig` 文件中，使用的文件为 [.gitconfig](./src/dotfiles/.gitconfig)

使用 **includeIf** 引用 `/root/.gitdir/github.gitconfig` 以解决每次更新镜像后都需要重复配置 name/email 的问题

---

## 手动构建

默认构建，使用LTS的Node版本，线上最新的pnpm包及其他依赖

```bash
docker build -t ofwh/code-server:latest .
```

也可以指定默认的Node版本(需指定数字版本)

```bash
NODE_VER=20
docker build --progress=plain -t ofwh/code-server:node-v${NODE_VER} -f Dockerfile.node --build-arg NODE_VER=${NODE_VER} .
```
