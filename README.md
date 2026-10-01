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

在 Netlify 关联本仓库后，`git push` 即自动部署（步骤见 [deploy/部署说明.md](deploy/部署说明.md) 第九章）。

也可以不进 Netlify 后台，直接用命令行发布：

```powershell
cd deploy
netlify deploy --prod
```

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
## 工具

| 文件 | 作用 |
|---|---|
| `sync.ps1` | 源码 → deploy/ 同步（改完代码跑一次） |
| `set-qr.ps1` | 把二维码内嵌进游戏（`-ImagePath 图片路径`，`-Clear` 清除） |

## 文档

| 文件 | 内容 |
|---|---|
| `deploy/部署说明.md` | 各平台部署方式、更新流程、全部可调参数对照表 |
| `deploy/国内部署指南.md` | **微信分享必读** —— 备案约束、香港过渡方案、Nginx、HTTPS |
| `deploy/nginx.conf` | 可直接用的 Nginx 配置 |

## 推广配置（重要）

游戏里内置了**分享战报图**和**转化入口**，都集中在源码顶部的一个 `PROMO` 对象里，改文案不用动逻辑：

```js
const PROMO={
  qr:'',                          // 你的微信二维码：留空 / './qr.png' / base64
  qrLabel:'扫码 · 免费估价',
  ctaTitle:'你的包，现在值多少钱？',
  ctaDesc:'专业估价师 1 对 1 免费估价<br>上门回收 · 当场打款 · 全国包邮',
  ctaBtn:'💬 免费估价',
  ctaTip:'长按识别下方二维码，添加估价师微信',
  hookLine:'我 30 天做到 {rank}，净资产 {net}\n你的包值多少？来测一测',
  trackerUrl:''                   // 埋点上报地址，留空只打 console
};
```

**放二维码最简单的办法**：把你的二维码存成 `qr.png`，放进 `deploy/` 文件夹，然后把 `qr` 改成 `'./qr.png'`。

埋点事件：`game_start`（开局）、`act1_cleared`（通关第一幕）、`game_over`（终局）、`share_card_open`（点生成战报）、`cta_click`（点估价按钮）。填了 `trackerUrl` 就上报，不填只在控制台打印。