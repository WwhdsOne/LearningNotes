---
tags:
  - linux
  - proxy
  - clash
  - tool
---

# Linux 一键安装 Clash / Mihomo 代理

> GitHub: [nelvko/clash-for-linux-install](https://github.com/nelvko/clash-for-linux-install) | ⭐ 12.5k | Shell

Linux 上一键安装配置 clash/mihomo 代理环境的工具，支持 root/普通用户、主流发行版和容器化环境（如 AutoDL）。

## 一键安装

```bash
git clone --branch master --depth 1 https://gh-proxy.org/https://github.com/nelvko/clash-for-linux-install.git \
  && cd clash-for-linux-install \
  && bash install.sh
```

## 常用命令

| 命令 | 作用 |
|------|------|
| `clashctl on` / `clashon` | 开启代理 |
| `clashctl off` / `clashoff` | 关闭代理 |
| `clashctl status` | 查看内核状态 |
| `clashctl proxy` | 控制系统代理 |
| `clashctl ui` | 打开 Web 控制台 |
| `clashctl secret` | 管理 Web 密钥 |
| `clashctl sub` | 订阅管理 |
| `clashctl upgrade` | 升级内核 |
| `clashctl tun` | Tun 模式（全流量代理） |
| `clashctl mixin` | Mixin 自定义配置 |

## 核心特性

- 自动检测端口占用，冲突时随机分配
- 自动识别系统架构和初始化系统
- 支持 `subconverter` 本地订阅转换
- Mixin 配置可深度合并到原始订阅
- 同时支持 `clash` 和 `mihomo` 内核
- Tun 模式实现 Docker 等容器全流量代理

## 相关笔记

- [[linux/问题合集]]
- [[Docker/docker入门]]
- [[linux/好用的命令工具]]
