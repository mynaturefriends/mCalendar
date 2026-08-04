# Privacy Policy

**Mini Calendar collects nothing, sends nothing, and has no network code in it
at all.**

There is no analytics, no crash reporting, no telemetry, no account, no
"anonymous usage statistics", and no third-party SDK of any kind. The app draws
a calendar from your Mac's system clock and does nothing else.

Last updated: 4 August 2026. Applies to Mini Calendar 1.0.2 and later.

## What the app stores

Six preferences, written by macOS to a plain file on your own Mac:

```
~/Library/Preferences/me.mynaturefriends.mcalendar.plist
```

They are: number of months shown, show date in the menu bar, show weekday in the
menu bar, show week numbers, interface language, and appearance. That is the
complete list.

If you turn on **Launch at login**, the app registers itself with macOS as a
login item (via `SMAppService`). That registration lives in the system, not in
the app, and turning the switch off removes it.

Deleting `mCalendar.app` and the file above removes every trace of the app.

## What the app never touches

- **The network** — no connection is ever opened. The binary does not even link
  a networking framework.
- **Your calendars, events, reminders, or contacts** — Mini Calendar has no
  events feature and does not use EventKit. It never asks for those permissions,
  because it has no use for them.
- **Your files, photos, microphone, camera, or location.**
- **Your keystrokes or screen.** The app has no accessibility or screen-recording
  permissions.

Mini Calendar requests no system permissions at all, so macOS never shows you a
consent prompt for it.

## Verifying this yourself

You do not have to take my word for it:

- The full source is at
  <https://github.com/mynaturefriends/mCalendar> — it is about 700 lines.
- `otool -L /Applications/mCalendar.app/Contents/MacOS/mCalendar` lists the
  frameworks it links. There is no `CFNetwork` and no `Network.framework`.
- `codesign -d --entitlements - /Applications/mCalendar.app` shows the app
  requests no entitlements.
- Point a network monitor (Little Snitch, LuLu, `nettop`) at it and watch it stay
  silent.

## Distribution

Releases are signed with an Apple Developer ID certificate and notarized by
Apple, so macOS can verify the download has not been tampered with. Download only
from the [Releases page](https://github.com/mynaturefriends/mCalendar/releases).

## Changes

If this policy ever changes it will be in this file, in the repository's history,
where you can see exactly what changed and when. Given what the app does, I do
not expect it to change.

## Contact

Questions: open an issue at
<https://github.com/mynaturefriends/mCalendar/issues>.

---

# 隐私政策

**Mini Calendar 不收集任何信息,不发送任何数据,代码里根本没有联网逻辑。**

没有统计分析,没有崩溃上报,没有遥测,不需要账号,没有所谓"匿名使用数据",也没有
任何第三方 SDK。它读取你 Mac 的系统时间画出一张日历,仅此而已。

最后更新:2026年8月4日。适用于 Mini Calendar 1.0.2 及之后的版本。

## 应用保存了什么

六项设置,由 macOS 写在你自己电脑上的一个普通文件里:

```
~/Library/Preferences/me.mynaturefriends.mcalendar.plist
```

分别是:显示月份数、菜单栏是否显示日期、菜单栏是否显示星期、是否显示周数列、
界面语言、外观。全部内容就这些。

如果你打开**开机自动启动**,应用会通过 `SMAppService` 向 macOS 注册为登录项。
这条注册记录保存在系统里,不在应用内,关掉开关即被移除。

删除 `mCalendar.app` 和上面那个文件,应用就不会在你的电脑上留下任何痕迹。

## 应用绝不接触什么

- **网络**——从不建立任何连接。二进制文件甚至没有链接任何网络框架。
- **你的日历、日程、提醒事项、通讯录**——本应用没有日程功能,不使用 EventKit,
  也从不申请这些权限,因为它用不上。
- **你的文件、照片、麦克风、摄像头、位置。**
- **你的按键和屏幕内容**——应用没有辅助功能权限,也没有屏幕录制权限。

Mini Calendar 不申请任何系统权限,所以 macOS 从不会为它弹出授权请求。

## 你可以自己验证

这些话不必只听我说:

- 完整源码在 <https://github.com/mynaturefriends/mCalendar>,大约 700 行。
- `otool -L /Applications/mCalendar.app/Contents/MacOS/mCalendar` 会列出它链接的
  框架,里面没有 `CFNetwork`,也没有 `Network.framework`。
- `codesign -d --entitlements - /Applications/mCalendar.app` 会显示它没有申请
  任何 entitlement。
- 用网络监控工具(Little Snitch、LuLu、`nettop`)盯着它,你会看到它一直是静默的。

## 分发方式

发布版本使用 Apple Developer ID 证书签名并已通过 Apple 公证,macOS 因此可以验证
你下载到的文件未被篡改。请只从
[Releases 页面](https://github.com/mynaturefriends/mCalendar/releases)下载。

## 变更

本政策如有变更,会体现在这个文件里,并保留在仓库的提交历史中——你可以清楚看到
改了什么、什么时候改的。以这个应用的功能而言,我预计不会有变更。

## 联系方式

有疑问请在 <https://github.com/mynaturefriends/mCalendar/issues> 提 issue。
