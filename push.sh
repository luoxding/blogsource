#!/bin/bash
# git add -A && git commit -m "$(date +%F" "%T)" && git push
# git add -A && git commit -m "$(date +%Y-%m-%d_%H-%M-%S)" && git push

# git init -b main
# git remote add origin git@github.com:luoxding/luoxding.github.io.git

# 源文件
git pull
git add -A
git commit -m "update: $(date +%F" "%T)"
git push

# 网页文件
#cd blog/public/
#git pull --rebase origin main
#git add -A
#git commit -m "repo backup: $(date +%Y-%m-%d" "%H:%M:%S)"
#git push origin main

#git pull --rebase origin main
#git add .
#git commit -m "first"
#git push origin main




echo "更新完成~"