import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
}

/// App-wide settings: language + appearance, persisted in UserDefaults.
@MainActor
final class Settings: ObservableObject {
    static let shared = Settings()

    /// "system", "en", or "zh-Hans".
    @Published var languageCode: String {
        didSet {
            UserDefaults.standard.set(languageCode, forKey: "languageCode")
            onChange?()
        }
    }

    @Published var appearance: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "appearance")
            onChange?()
        }
    }

    /// How many months the panel shows at once (1...6).
    @Published var monthCount: Int {
        didSet {
            UserDefaults.standard.set(monthCount, forKey: "monthCount")
        }
    }

    /// Whether the menubar label shows the date (e.g. "Jul 25" / "7月25日").
    @Published var showDate: Bool {
        didSet {
            UserDefaults.standard.set(showDate, forKey: "showDate")
            onChange?()
        }
    }

    /// Whether the menubar label shows the weekday (e.g. "Sat" / "周六").
    @Published var showWeekday: Bool {
        didSet {
            UserDefaults.standard.set(showWeekday, forKey: "showWeekday")
            onChange?()
        }
    }

    /// Whether the calendar shows the week-number gutter on the left.
    @Published var showWeekNumbers: Bool {
        didSet { UserDefaults.standard.set(showWeekNumbers, forKey: "showWeekNumbers") }
    }


    /// Called (on the main actor) whenever a setting changes, so AppKit bits can refresh.
    var onChange: (() -> Void)?

    private init() {
        languageCode = UserDefaults.standard.string(forKey: "languageCode") ?? "system"
        appearance = AppearanceMode(rawValue: UserDefaults.standard.string(forKey: "appearance") ?? "")
            ?? .system
        let stored = UserDefaults.standard.integer(forKey: "monthCount")
        monthCount = stored == 0 ? 2 : min(max(stored, 1), 6)
        showDate = UserDefaults.standard.object(forKey: "showDate") as? Bool ?? true
        showWeekday = UserDefaults.standard.object(forKey: "showWeekday") as? Bool ?? true
        showWeekNumbers = UserDefaults.standard.object(forKey: "showWeekNumbers") as? Bool ?? true
    }

    var locale: Locale {
        languageCode == "system" ? .autoupdatingCurrent : Locale(identifier: languageCode)
    }

    var colorScheme: ColorScheme? {
        switch appearance {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    /// Resolves "system" / any code to one of the two string tables we ship.
    var effectiveLang: String {
        let code: String
        if languageCode == "system" {
            code = Locale.autoupdatingCurrent.language.languageCode?.identifier ?? "en"
        } else {
            code = languageCode
        }
        return code.hasPrefix("zh") ? "zh" : "en"
    }

    var isChinese: Bool { effectiveLang == "zh" }

    /// Localized UI string.
    func t(_ key: String) -> String {
        strings[effectiveLang]?[key] ?? strings["en"]?[key] ?? key
    }

    private let strings: [String: [String: String]] = [
        "en": [
            "today": "Today", "language": "Language", "appearance": "Appearance",
            "system": "System", "light": "Light", "dark": "Dark", "quit": "Quit",
            "months": "Months", "settings": "Settings",
            "showDate": "Date in menu bar", "showWeekday": "Weekday in menu bar",
            "showWeekNums": "Week numbers", "about": "About Mini Calendar",
            "author": "Author: Zhou Yang"
        ],
        "zh": [
            "today": "今天", "language": "语言", "appearance": "外观",
            "system": "跟随系统", "light": "浅色", "dark": "深色", "quit": "退出",
            "months": "显示月数", "settings": "设置",
            "showDate": "菜单栏显示日期", "showWeekday": "菜单栏显示星期",
            "showWeekNums": "显示周数列", "about": "关于 Mini Calendar",
            "author": "作者：Zhou Yang"
        ]
    ]
}
