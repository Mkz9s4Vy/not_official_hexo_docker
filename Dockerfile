# 构建阶段：初始化 Hexo 并安装依赖
FROM node:23-alpine AS builder

WORKDIR /build

# 安装 git (hexo init/主题可能需要) + npm
# 如果 npm install 时需要编译原生插件，可能还需要 build-base
RUN apk add --no-cache --update npm # git # build-base

# 全局安装 hexo-cli 仅仅是为了执行 hexo init
RUN npm install -g hexo-cli

# 初始化 Hexo 项目（这也会在本地 node_modules 安装 hexo）
RUN hexo init .

# 安装特定的渲染器和主题（示例：butterfly）
# 使用 --save 将它们添加到 package.json 的 dependencies 中
RUN npm install hexo-renderer-pug hexo-renderer-stylus hexo-theme-butterfly --save

# 安装 package.json 中定义的所有依赖（包括本地的 hexo）
RUN npm install

# 可选：修复安全审计问题（谨慎使用，可能破坏兼容性）
RUN npm audit fix --force

# 预生成静态文件（可选，因为 entrypoint 无论如何都会重新生成）
# RUN hexo generate

# 运行阶段：提供 Hexo 站点服务
FROM node:23-alpine

# 安装运行时依赖：entrypoint.sh 需要 rsync
RUN apk add --no-cache --update rsync tini

ENV HEXO_SERVER_PORT=4000
WORKDIR /app

# 完整复制构建好的 Hexo 项目（包括包含本地 hexo 的 node_modules）
COPY --from=builder /build /app

# 复制入口点脚本
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# 清理 apk 缓存和 npm 缓存
RUN rm -rf /var/cache/apk/* /tmp/* ~/.npm

EXPOSE ${HEXO_SERVER_PORT}

# 运行入口点脚本
ENTRYPOINT ["tini", "--", "/app/entrypoint.sh"]
