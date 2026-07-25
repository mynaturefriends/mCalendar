import SwiftUI
import AppKit

struct CalendarView: View {
    @EnvironmentObject var settings: Settings
    @State private var anchor = Date()

    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2 // Monday
        c.locale = settings.locale
        return c
    }

    var body: some View {
        VStack(spacing: 12) {
            header
            MonthsGrid(
                firstMonthStart: startOfMonth(anchor),
                monthCount: settings.monthCount,
                showWeeks: settings.showWeekNumbers,
                cal: cal
            )
            footer
        }
        .padding(14)
        .frame(width: 250)
        .preferredColorScheme(settings.colorScheme)
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text(rangeTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            HStack(spacing: 12) {
                Button(action: { shift(by: -1) }) { Image(systemName: "chevron.left") }
                Button(action: { anchor = Date() }) { Image(systemName: "circle") }
                Button(action: { shift(by: 1) }) { Image(systemName: "chevron.right") }
            }
            .buttonStyle(.borderless)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button(action: { (NSApp.delegate as? AppDelegate)?.openSettings() }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
        }
    }

    // "2026年 7–8月" / "Jul – Aug 2026"; single month "2026年 7月" / "Jul 2026".
    private var rangeTitle: String {
        let first = startOfMonth(anchor)
        let last = cal.date(byAdding: .month, value: settings.monthCount - 1, to: first) ?? first
        let ya = cal.component(.year, from: first), yb = cal.component(.year, from: last)
        let ma = cal.component(.month, from: first), mb = cal.component(.month, from: last)
        if settings.isChinese {
            if settings.monthCount == 1 { return "\(ya)年 \(ma)月" }
            return ya == yb ? "\(ya)年 \(ma)–\(mb)月" : "\(ya)年\(ma)月 – \(yb)年\(mb)月"
        }
        let f = DateFormatter(); f.locale = cal.locale; f.dateFormat = "MMM"
        let sa = f.string(from: first), sb = f.string(from: last)
        if settings.monthCount == 1 { return "\(sa) \(ya)" }
        return ya == yb ? "\(sa) – \(sb) \(ya)" : "\(sa) \(ya) – \(sb) \(yb)"
    }

    private func startOfMonth(_ date: Date) -> Date {
        cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
    }

    private func shift(by months: Int) {
        if let d = cal.date(byAdding: .month, value: months, to: startOfMonth(anchor)) {
            anchor = d
        }
    }
}

/// A continuous grid spanning `monthCount` months starting at `firstMonthStart`,
/// with a single weekday header and week-number gutter.
struct MonthsGrid: View {
    let firstMonthStart: Date
    let monthCount: Int
    let showWeeks: Bool
    let cal: Calendar

    private var gutter: CGFloat { showWeeks ? 24 : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Weekday header as its own row, separated from the grid by a hairline.
            HStack(spacing: 0) {
                if showWeeks {
                    Color.clear.frame(width: gutter)
                }
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { i, s in
                    Text(s)
                        .font(.system(size: 10, weight: .semibold))
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .foregroundStyle(isWeekendColumn(i) ? Color.secondary.opacity(0.7) : Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(spacing: 5) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 0) {
                        // The week a month starts in gets the month label instead of
                        // the week number, so month boundaries stay readable.
                        if showWeeks {
                            if let start = monthStarting(in: week) {
                                Text(monthAbbrev(start))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .frame(width: gutter)
                            } else {
                                Text("\(cal.component(.weekOfYear, from: week[0]))")
                                    .font(.system(size: 9.5))
                                    .foregroundStyle(.secondary)
                                    .frame(width: gutter)
                            }
                        }
                        ForEach(week, id: \.self) { day in
                            let idx = monthIndex(of: day)
                            DayCell(
                                date: day,
                                // Only the first (topmost) month is bright; the rest are gray.
                                emphasized: idx == 0,
                                inRange: idx != nil,
                                cal: cal
                            )
                        }
                    }
                }
            }
            // A faint panel behind the day grid (week rows only) separates the
            // calendar area from the week-number gutter.
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
                    .padding(.leading, gutter)
                    .padding(.vertical, -3)
            }
        }
    }

    /// First day of a displayed month if this week contains one, else nil.
    private func monthStarting(in week: [Date]) -> Date? {
        week.first { cal.component(.day, from: $0) == 1 && monthIndex(of: $0) != nil }
    }

    /// "8月" in Chinese, "Aug" in English.
    private func monthAbbrev(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = cal.locale
        f.calendar = cal
        f.dateFormat = "LLL"
        return f.string(from: date)
    }

    /// 0-based index of the displayed month `day` falls in, or nil if outside.
    private func monthIndex(of day: Date) -> Int? {
        let comps = cal.dateComponents(
            [.month],
            from: firstMonthStart,
            to: cal.date(from: cal.dateComponents([.year, .month], from: day)) ?? day
        )
        guard let m = comps.month, m >= 0, m < monthCount else { return nil }
        return m
    }

    private var weekdaySymbols: [String] {
        let s = cal.veryShortStandaloneWeekdaySymbols
        let first = cal.firstWeekday - 1
        return Array(s[first...] + s[..<first])
    }

    private func isWeekendColumn(_ index: Int) -> Bool { index >= 5 }

    private var lastMonthEnd: Date {
        let last = cal.date(byAdding: .month, value: monthCount - 1, to: firstMonthStart) ?? firstMonthStart
        let count = cal.range(of: .day, in: .month, for: last)?.count ?? 30
        return cal.date(byAdding: .day, value: count - 1, to: last) ?? last
    }

    private var gridStart: Date {
        let firstWeekday = cal.component(.weekday, from: firstMonthStart)
        let leading = (firstWeekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -leading, to: firstMonthStart) ?? firstMonthStart
    }

    // Full weeks from the start gutter through the end of the last month.
    private var weeks: [[Date]] {
        let end = cal.startOfDay(for: lastMonthEnd)
        let spanned = (cal.dateComponents([.day], from: gridStart, to: end).day ?? 0) + 1
        let rows = Int(ceil(Double(spanned) / 7.0))
        return (0..<rows).map { r in
            (0..<7).compactMap { c in cal.date(byAdding: .day, value: r * 7 + c, to: gridStart) }
        }
    }
}

struct DayCell: View {
    let date: Date
    /// True when the day belongs to the first (topmost) month.
    let emphasized: Bool
    /// True when the day falls within one of the displayed months.
    let inRange: Bool
    let cal: Calendar

    @State private var hovered = false

    var body: some View {
        let isToday = cal.isDateInToday(date)
        let weekday = cal.component(.weekday, from: date)
        let isWeekend = weekday == 7 || weekday == 1

        Text("\(cal.component(.day, from: date))")
            .font(.system(size: 11.5, weight: isToday ? .bold : .regular))
            .foregroundStyle(isToday ? Color.white : color(isWeekend: isWeekend))
            .frame(width: 24, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isToday ? Color.accentColor
                          : hovered ? Color.primary.opacity(0.12)
                          : .clear)
            )
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onHover { hovered = $0 }
            .animation(.easeOut(duration: 0.12), value: hovered)
    }

    // Tiers: first month bright, other months mid-gray, padding days faint.
    private func color(isWeekend: Bool) -> Color {
        if emphasized { return isWeekend ? .primary.opacity(0.55) : .primary }
        if inRange { return .secondary }
        return Color.secondary.opacity(0.35)
    }
}

/// Content of the standalone settings window.
struct SettingsView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(settings.t("months"))
                Slider(
                    value: Binding(
                        get: { Double(settings.monthCount) },
                        set: { settings.monthCount = Int($0.rounded()) }
                    ),
                    in: 1...6, step: 1
                )
                Text("\(settings.monthCount)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            toggleRow("showDate", $settings.showDate)
            toggleRow("showWeekday", $settings.showWeekday)
            toggleRow("showWeekNums", $settings.showWeekNumbers)
            toggleRow("launchAtLogin", $settings.launchAtLogin)

            HStack {
                Text(settings.t("language"))
                Spacer()
                Picker("", selection: $settings.languageCode) {
                    Text(settings.t("system")).tag("system")
                    Text("English").tag("en")
                    Text("中文").tag("zh-Hans")
                }
                .labelsHidden()
                .fixedSize()
            }

            HStack {
                Text(settings.t("appearance"))
                Spacer()
                Picker("", selection: $settings.appearance) {
                    Text(settings.t("system")).tag(AppearanceMode.system)
                    Text(settings.t("light")).tag(AppearanceMode.light)
                    Text(settings.t("dark")).tag(AppearanceMode.dark)
                }
                .labelsHidden()
                .fixedSize()
            }

            Divider()

            HStack {
                Text("Mini Calendar 1.0 · \(settings.t("author"))")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(settings.t("quit")) { NSApp.terminate(nil) }
            }
        }
        .font(.system(size: 12))
        .padding(16)
        .frame(width: 300)
        .preferredColorScheme(settings.colorScheme)
    }

    private func toggleRow(_ key: String, _ binding: Binding<Bool>) -> some View {
        HStack {
            Text(settings.t(key))
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
    }
}
