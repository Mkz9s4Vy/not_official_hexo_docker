#!/bin/sh
set -e

# 定义 npx hexo 调用方式 (更健壮)
HEXO_CMD="npx hexo"
CONFIG_FILE="_config.yml"

# 调试：打印当前目录和初始文件列表
echo "当前工作目录：$(pwd)"
echo "/app 目录内容 (同步前):"
ls -la /app

# 检查 /user-data 目录是否存在且不为空
if [ -d "/user-data" ] && [ "$(ls -A /user-data)" ]; then
  echo "🔧 检测到 /user-data 中的用户数据，正在同步 (覆盖模式，不删除)..."
  # 使用 rsync 同步用户数据，覆盖 /app 中的同名文件
  # 排除 node_modules 以保留依赖
  rsync -ar --include='_config.butterfly.yml' --include='_config.yml' --exclude='node_modules' --exclude='source/_posts/hello-world.md' /user-data/ /app/
  echo "🔄 同步完成。"

  # 调试：打印同步后的文件列表，并检查关键配置文件
  echo "/app 目录内容 (同步后):"
  ls -la /app
  echo "检查关键配置文件是否存在于 /app 中:"
  ls -l /app/_config.yml /app/_config.butterfly.yml > /dev/null 2>&1 && echo "  ✅ _config.yml 和 _config.butterfly.yml 存在" || echo "  ⚠️ 注意：_config.yml 或 _config.butterfly.yml 在同步后未找到！"
  echo "检查 /app/source 目录是否存在:"
  ls -ld /app/source > /dev/null 2>&1 && echo "  ✅ source 目录存在" || echo "  ⚠️ 注意：/app/source 目录在同步后未找到！"

  echo "🧹 正在清理缓存 (hexo clean)..."
  # 清理 Hexo 缓存 (db.json) 和 public 目录
  # 使用 --cwd 确保在正确的目录下执行
  $HEXO_CMD clean --cwd /app

  echo "⚙️ 正在使用同步后的配置重新生成站点 (hexo generate)..."
  # 使用清理缓存后的状态生成静态文件
  $HEXO_CMD generate --cwd /app

else
  echo "ℹ️ 未在 /user-data 中找到用户数据或目录为空。使用镜像内建的默认站点。"
  # 即使使用默认配置，最好也清理并生成一次
  echo "🧹 正在清理缓存 (hexo clean)..."
  $HEXO_CMD clean --cwd /app
  echo "⚙️ 正在生成默认站点 (hexo generate)..."
  $HEXO_CMD generate --cwd /app
fi

echo "🚀 正在端口 ${HEXO_SERVER_PORT} 上启动 Hexo 服务器..."
# 启动 Hexo 服务器
exec $HEXO_CMD server -p ${HEXO_SERVER_PORT} --cwd /app
