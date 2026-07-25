# Mini Calendar (mCalendar)

A minimal, keyboard-free macOS menu bar calendar. Click the date in your menu
bar to see one continuous grid spanning up to six months — nothing more,
nothing less.

## Why

I built Mini Calendar for one small, recurring moment: when I'm planning
something and just need to *see* a calendar — what weekday a date falls on,
how the next few weeks line up. Opening the full Calendar app for that always
felt like too much.

So this app does exactly one thing: click the menu bar, and a calendar is in
front of you. No events, no reminders, no accounts — and there never will be.
This is intentional: I'm not going to keep integrating features. A calendar
you can glance at, instantly, that stays out of the way — that's the whole
product.

## 为什么做这个

做这个应用的初衷很简单:做计划的时候,我常常只是想**看一眼日历**——某天是星期几、
接下来几周怎么排。为了看个日期去打开完整的日历应用,总觉得太重了。

所以它只做一件事:点一下菜单栏,日历就在眼前。没有日程、没有提醒、不用登录
账号——将来也不会有。这是有意为之:我不打算继续往里集成功能。一个点开就能
看到日历、看完就退开的小工具,这就是它的全部。

## Features

- **Menu bar label** shows the current date and weekday (each can be toggled
  off; falls back to a calendar icon)
- **Continuous multi-month view**: 1–6 months in a single scrolling-free grid,
  the current month bright, following months dimmed
- **Week numbers** in the left gutter, with the month abbreviation marking the
  week each month starts (column can be hidden)
- **Today** highlighted, `‹ ◯ ›` to page months / jump back to today
- **Monday-first** weeks, weekends dimmed
- **Light / dark / system** appearance
- **English / 中文** interface (or follow the system language)
- Right-click the menu bar icon for About / Quit
- Settings live in a standalone window (gear button in the popover)

## Download

Grab `mCalendar-x.y.zip` from the
[Releases page](https://github.com/mynaturefriends/mCalendar/releases), unzip,
and drag `mCalendar.app` into `/Applications`.

> **First launch**: the app is not notarized yet, so macOS will warn about an
> unidentified developer. Right-click the app → **Open** → **Open** once; after
> that it launches normally. (中文:首次打开请右键 →「打开」。)

## Requirements

- macOS 13+
- Xcode 15+ (Swift 5.9) to build

## Build & Run

Open `mCalendar.xcodeproj` in Xcode and hit **⌘R**.

Command line alternatives:

```sh
# Release app + distribution zip, output under build/
./scripts/release.sh

# Or via Xcode's build system directly
xcodebuild -project mCalendar.xcodeproj -scheme mCalendar -configuration Release build

# Or run the bare executable via SwiftPM (no app bundle)
swift run
```

The app is a menu-bar-only agent (`LSUIElement`): it shows no Dock icon and no
main window. To launch it at login, add the built app to
**System Settings → General → Login Items**.

## 简介

一个极简的 macOS 菜单栏日历:点击菜单栏上的日期,弹出一张连续显示 1–6 个月的
日历。支持周数列、今天高亮、浅色/深色外观、中英文界面,设置在独立窗口中,
菜单栏图标右键可退出。

## License

[MIT](LICENSE) © 2026 Zhou Yang
