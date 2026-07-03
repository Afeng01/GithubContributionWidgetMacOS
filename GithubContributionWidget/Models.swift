//
//  Models.swift
//  GithubContributionWidgetMacOS
//
//  Created by Sekul on 27.09.2025.
//

import Foundation
import SwiftUI

enum DesktopCalendarTheme {
    static func surfaceFill(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return Color.white.opacity(0.06)
        }
        return Color.black.opacity(0.055)
    }

    static func frameStroke(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return Color.white.opacity(0.12)
        }
        return Color.black.opacity(0.10)
    }

    static func frameGlow(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return Color.white.opacity(0.04)
        }
        return Color.black.opacity(0.05)
    }

    static func color(for intensity: ContributionIntensity, scheme: ColorScheme) -> Color {
        let base = scheme == .dark ? Color.white : Color.black

        switch intensity {
        case .transparent:
            return base.opacity(0.028)
        case .none:
            return base.opacity(0.075)
        case .low:
            return base.opacity(0.16)
        case .medium:
            return base.opacity(0.28)
        case .high:
            return base.opacity(0.42)
        case .veryHigh:
            return base.opacity(0.60)
        }
    }
}

struct ContributionDay {
    let date: Date
    let contributionCount: Int?

    var intensity: ContributionIntensity {
        switch contributionCount {
        case nil:
            return .transparent
        case let count?:
            switch count {
            case 0: return .none
            case 1...3: return .low
            case 4...6: return .medium
            case 7...10: return .high
            default: return .veryHigh
            }
        }
    }
}

enum ContributionIntensity: Int, Hashable, CaseIterable {
    case transparent = -1
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case veryHigh = 4

}
