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

    /// Called (on the main actor) whenever a setting changes, so AppKit bits can refresh.
    var onChange: (() -> Void)?

    private init() {
        languageCode = UserDefaults.standard.string(forKey: "languageCode") ?? "system"
        appearance = AppearanceMode(rawValue: UserDefaults.standard.string(forKey: "appearance") ?? "")
            ?? .system
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
            "system": "System", "light": "Light", "dark": "Dark", "quit": "Quit"
        ],
        "zh": [
            "today": "今天", "language": "语言", "appearance": "外观",
            "system": "跟随系统", "light": "浅色", "dark": "深色", "quit": "退出"
        ]
    ]
}
