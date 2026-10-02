# 二奢模拟器

一个无需安装的网页经营小游戏。你经营一家二手奢侈品店，在 30 天内收货、鉴定、护理、投流、直播带货，并与本区对手争夺市占率；取胜后可进入区域扩张阶段，开设分店。

[在线试玩](https://ershe-simulator.netlify.app)

## 快速开始

无需安装依赖或启动服务。

1. 下载或克隆仓库。
2. 双击打开 `二奢模拟器.html`。
3. 在浏览器中直接开始游戏。

游戏进度会保存在浏览器的 localStorage 中；关闭页面后可继续。重新开局、清除浏览器站点数据或使用无痕模式，可能会清除存档。

## 游戏内容

- 收货与压价：判断货源、谈价并控制库存成本。
- 鉴定与护理：自家鉴定免费但有误判可能；外部鉴定收费且结果准确。
- 抖音投流与直播：用流量带来客户，同时管理退货风险。
- 同行包展：低价扫货或快速甩货，真假风险更高。
- 市场竞争：与本区对手争夺市占率，解锁后扩张到更多区域。
- 结算战报：完成经营后生成可保存、分享的成绩图。

## 项目结构

```text
二奢模拟器.html     主源码；日常修改这里
deploy/
  index.html         Netlify 实际发布的页面，需与主源码保持一致
  _headers           静态站点响应头与缓存策略
netlify.toml         Netlify 发布目录配置
sync.ps1             同步主源码到 deploy/index.html
set-qr.ps1           将二维码写入分享配置
```

## 修改游戏内容

大部分数值都集中在 `二奢模拟器.html` 顶部，搜索对应常量即可：

| 想修改的内容 | 搜索名称 |
| --- | --- |
| 品牌、款式与价格 | `BRANDS` |
| 品相与价值倍率 | `CONDITIONS` |
| 客户画像与出价 | `CUSTOMER_TYPES` |
| 广告投放档位 | `AD_TIERS` |
| 直播档位与退货风险 | `LIVE_TIERS` |
| 区域、开店成本与对手 | `REGIONS` |
| 主题颜色 | CSS 中的 `:root{}` |

修改后，请运行 `sync.ps1`，或手动将 `二奢模拟器.html` 同步到 `deploy/index.html`，再部署。

## 分享战报图

结算页可生成 750 × 1180 的战报图。分享文案与可选网址在源码顶部的 `PROMO` 中配置：

```js
const PROMO = {
  hookLine: '我 {days} 天做到「{rank}」，净资产 {net}\n你能到哪一档？',
  shareFoot: '你也来试试',
  shareSub: '看你能把 50 万滚成什么样',
  gameUrl: 'https://ershe-simulator.netlify.app',
  trackerUrl: ''
};
```

- `{days}`、`{rank}`、`{net}` 会替换为玩家实际成绩。
- `gameUrl` 留空时，战报图底部不显示网址。
- `qr` 与 `ctaTitle` 默认留空；填写后可启用二维码和结算页转化卡片。
- `trackerUrl` 留空时只输出浏览器控制台日志，不会发送网络请求。

当前支持的埋点事件：`game_start`、`act1_cleared`、`game_over`、`share_card_open`。

## 部署到 Netlify

仓库已包含 `netlify.toml`。在 Netlify 中关联该仓库后，发布目录会自动使用 `deploy/`，不需要构建命令。

每次发布前请确认 `deploy/index.html` 已同步为最新主源码。

## 技术说明

- 纯静态单页应用：无后端、无构建步骤、无第三方依赖。
- 页面不加载 CDN、字体或游戏图片。
- 存档保存在 localStorage；第二幕的区域竞争进度会一并保存。
- 默认不采集个人信息；只有配置 `trackerUrl` 后才会发送匿名事件数据。
