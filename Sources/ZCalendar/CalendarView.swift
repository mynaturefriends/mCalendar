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
        VStack(spacing: 10) {
            header
            MonthGrid(monthStart: startOfMonth(anchor), cal: cal)
            Divider()
            MonthGrid(monthStart: startOfMonth(nextMonth), cal: cal)
            footer
        }
        .padding(12)
        .frame(width: 240)
        .preferredColorScheme(settings.colorScheme)
    }

    private var header: some View {
        HStack(spacing: 6) {
            Button(settings.t("today")) { anchor = Date() }
                .buttonStyle(.borderless)
                .font(.system(size: 12, weight: .medium))
            Spacer()
            Button(action: { shift(by: -1) }) { Image(systemName: "chevron.left") }
            Button(action: { shift(by: 1) }) { Image(systemName: "chevron.right") }
        }
        .buttonStyle(.borderless)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.secondary)
    }

    private var footer: some View {
        HStack {
            Spacer()
            Menu {
                Picker(settings.t("language"), selection: $settings.languageCode) {
                    Text(settings.t("system")).tag("system")
                    Text("English").tag("en")
                    Text("中文").tag("zh-Hans")
                }
                Picker(settings.t("appearance"), selection: $settings.appearance) {
                    Text(settings.t("system")).tag(AppearanceMode.system)
                    Text(settings.t("light")).tag(AppearanceMode.light)
                    Text(settings.t("dark")).tag(AppearanceMode.dark)
                }
                Divider()
                Button(settings.t("quit")) { NSApp.terminate(nil) }
            } label: {
                Image(systemName: "gearshape")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
        }
    }

    private var nextMonth: Date {
        cal.date(byAdding: .month, value: 1, to: startOfMonth(anchor)) ?? anchor
    }

    private func startOfMonth(for date: Date) -> Date { startOfMonth(date) }

    private func startOfMonth(_ date: Date) -> Date {
        cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
    }

    private func shift(by months: Int) {
        if let d = cal.date(byAdding: .month, value: months, to: startOfMonth(anchor)) {
            anchor = d
        }
    }
}

struct MonthGrid: View {
    let monthStart: Date
    let cal: Calendar

    private let weekColWidth: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(monthTitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, weekColWidth)

            HStack(spacing: 0) {
                Color.clear.frame(width: weekColWidth)
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { i, s in
                    Text(s)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isWeekendColumn(i) ? Color.secondary : Color.primary.opacity(0.65))
                        .frame(maxWidth: .infinity)
                }
            }

            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    Text("\(cal.component(.weekOfYear, from: week[0]))")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .frame(width: weekColWidth)
                    ForEach(week, id: \.self) { day in
                        DayCell(date: day, monthStart: monthStart, cal: cal)
                    }
                }
            }
        }
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = cal.locale
        f.calendar = cal
        f.setLocalizedDateFormatFromTemplate("yMMMM")
        return f.string(from: monthStart)
    }

    private var weekdaySymbols: [String] {
        let s = cal.veryShortStandaloneWeekdaySymbols
        let first = cal.firstWeekday - 1
        return Array(s[first...] + s[..<first])
    }

    // Column index 5 and 6 are Sat/Sun when the week starts on Monday.
    private func isWeekendColumn(_ index: Int) -> Bool { index >= 5 }

    private var weeks: [[Date]] {
        guard let range = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
        let firstWeekday = cal.component(.weekday, from: monthStart)
        let leading = (firstWeekday - cal.firstWeekday + 7) % 7
        guard let start = cal.date(byAdding: .day, value: -leading, to: monthStart) else { return [] }
        let rows = Int(ceil(Double(leading + range.count) / 7.0))

        return (0..<rows).map { r in
            (0..<7).compactMap { c in cal.date(byAdding: .day, value: r * 7 + c, to: start) }
        }
    }
}

struct DayCell: View {
    let date: Date
    let monthStart: Date
    let cal: Calendar

    var body: some View {
        let inMonth = cal.isDate(date, equalTo: monthStart, toGranularity: .month)
        let isToday = cal.isDateInToday(date)
        let weekday = cal.component(.weekday, from: date)
        let isWeekend = weekday == 7 || weekday == 1 // Saturday or Sunday

        Text("\(cal.component(.day, from: date))")
            .font(.system(size: 11, weight: isToday ? .bold : .regular))
            .foregroundStyle(color(inMonth: inMonth, isToday: isToday, isWeekend: isWeekend))
            .frame(maxWidth: .infinity)
            .frame(height: 21)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(isToday ? Color.accentColor : .clear, lineWidth: 1.3)
            )
    }

    private func color(inMonth: Bool, isToday: Bool, isWeekend: Bool) -> Color {
        if isToday { return .accentColor }
        if !inMonth { return Color.secondary.opacity(0.4) }
        if isWeekend { return .secondary }
        return .primary
    }
}
