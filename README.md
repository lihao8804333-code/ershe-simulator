# 二奢模拟器

> 二手奢侈品店经营模拟 · 单文件网页游戏

一个**纯静态单文件**网页游戏。30 天经营一间二手奢侈品店，收货、鉴定、护理、抖音投流、直播带货、同行包展，
打败区域对手后可以连锁扩张。零依赖、零构建、无后端。

---

## 目录结构

```
.
├── 二奢模拟器.html      ← 源文件（改代码改这个）
├── deploy/              ← 发布目录（Netlify 发布的就是这个）
│   ├── index.html       ← 与源文件完全一致的副本
│   ├── _headers         ← Netlify/Cloudflare 的响应头配置
│   └── 部署说明.md       ← 完整部署文档
├── netlify.toml         ← 告诉 Netlify 发布目录是 deploy/
└── .gitignore
```

## 上线

已关联 Netlify，`git push` 即自动部署。

手动部署见 [deploy/部署说明.md](deploy/部署说明.md)。

## 改完代码记得同步

源文件和发布副本是**两份**，改完要同步一次，否则线上不会更新：

```powershell
powershell -ExecutionPolicy Bypass -File .\sync.ps1
```

它会复制并校验 SHA256，输出 `[OK] Synced` 就说明一致了。

然后：

```bash
git add .
git commit -m "说明改了什么"
git push
```

## 想调数值？

[deploy/部署说明.md](deploy/部署说明.md) 第六章有一张完整的对照表（参数名 + 当前值 + 行号），
包括经营天数、初始资金、品牌议价硬度、砍价公式、广告档位、分店经济等。

## 技术说明

- 单文件、零外部依赖（无 CDN、无图片、无网络请求）
- 纯前端，游戏状态存在内存里，刷新即重来
- 白绿主题，颜色集中在 `<style>` 开头的 `:root{}`（第 15~21 行），改那里就能整体换肤
