# 用于自动完善Camunda容器配置目录
1. 环境参数:
    - `EXPOSED_PORT`: 默认 `8080`, 可以设置到docker0 `EXPOSED_PORT=172.17.0.1:8080`
    - `CAMUNDA_VERSION`: 默认 `7.1.0`
    - `MARIADB_CLIENT_VERSION`: 默认 `2.3.0`
    > 配置了 `CAMUNDA_VERSION` 和 `MARIADB_CLIENT_VERSION` 之后，容器会直接从官网下载，如果您有更快速的镜像，可以直接设置`CAMUNDA_WAR_URL` 和 `MARIADB_CLIENT_URL` 来加速下载
    - `DB_HOST`: 默认 `172.17.0.1`
    - `DB_NAME`: 默认 `camunda`
    - `DB_USER`: 默认 `test`
    - `DB_PASS`: 默认 `test`

2. 使用方法:
```bash
cd /path/to/your/container
docker run --rm -v $PWD:/container \
    -e EXPOSED_PORT=172.17.0.1:8080 \
    -e CAMUNDA_VERSION=7.1.0 \
    -e MARIADB_CLIENT_VERSION=2.3.0 \
    -e DB_USER=genee \
    -e DB_PASS=123456 \
    genee/camunda-container-setup
```