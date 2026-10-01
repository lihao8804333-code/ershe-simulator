# 二奢模拟器

一个网页小游戏。你盘下一间二手奢侈品店，30 天里收货、鉴定、护理、投抖音、直播带货，
还得跟本区的老对手抢市占率。赢了就能去别的区开分店。

单文件，没有依赖，没有后端。双击就能玩。

## 改代码

改 `二奢模拟器.html`。`deploy/index.html` 是它的副本，发布用的，别直接改那边。

改完记得同步一次，不然线上还是旧版本：

```
powershell -ExecutionPolicy Bypass -File .\sync.ps1
```

看到 `[OK] Synced` 就成了，它会顺便校验两边的 SHA256 是否一致。然后：

```
git add .
git commit -m "改了什么"
git push
```

Netlify 关联了仓库的话，push 完自动部署。

## 目录

```
二奢模拟器.html     源文件，改这个
deploy/            发布目录，只有这里面的东西会上线
  index.html       源文件的副本
  _headers         响应头配置
sync.ps1           源文件同步到 deploy/
set-qr.ps1         把二维码内嵌进游戏（可选）
netlify.toml       告诉 Netlify 发布目录是 deploy/
```

`deploy/` 里的东西全都会公开访问到，所以里面只放游戏本身。

## 分享战报图

玩到结算页可以生成一张 750×1180 的成绩图，发给朋友或者扔群里。

图上写什么在源码顶部的 `PROMO` 里，改文案不用碰逻辑：

```js
const PROMO={
  hookLine:'我 {days} 天做到「{rank}」，净资产 {net}\n你能到哪一档？',
  shareFoot:'你也来试试',
  shareSub:'看你能把 50 万滚成什么样',
  gameUrl:'',        // 填上游戏网址，会显示在图底部，传播效果更好
  trackerUrl:''      // 埋点地址，留空就只打控制台
};
```

`{days}` `{rank}` `{net}` 会自动换成玩家的实际成绩。

下面还有二维码和转化卡片的配置，默认全是关的（`qr` 和 `ctaTitle` 留空）。那两个是给回收业务导流用的，纯分享用不上。

埋点有四个事件：`game_start`、`act1_cleared`、`game_over`、`share_card_open`。不填 `trackerUrl` 就只打 console，不发任何请求，也不采集个人信息。

## 想调数值

参数集中在源码顶部的几个常量里（`BRANDS`、`CONDITIONS`、`CUSTOMER_TYPES`、`AD_TIERS`、
`LIVE_TIERS`、`REGIONS` 这些），搜名字就能找到。改完刷新页面即可，主题色在 `<style>`
开头的 `:root{}` 里（第 15~21 行）。

## 一些技术上的事

单文件，零依赖 —— 没有 CDN、没有字体文件、没有图片、没有网络请求。状态全在内存里，刷新重来。

主题色集中在 `<style>` 开头的 `:root{}`（第 15~21 行），改那里就能整体换肤。

游戏用 localStorage 存进度，中途退出可以接着玩。存档带版本号和完整性校验，结构对不上会自动丢弃，不会白屏。

**改文案时注意 emoji。** 现在用的都是 Unicode 10.0 及以下的字符（2017 年前），
Windows 7 都能正常显示。别引入 Unicode 11.0 以后的新 emoji —— 旧系统字体里没有，
会渲染成一个方框。战报图有兜底逻辑，但结算页是普通 HTML，没兜底。
