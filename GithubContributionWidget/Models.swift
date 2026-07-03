//
//  Models.swift
//  GithubContributionWidgetMacOS
//
//  Created by Sekul on 27.09.2025.
//

import Foundation
import SwiftUI

enum DesktopCalendarTheme {
    static func color(for intensity: ContributionIntensity, scheme: ColorScheme) -> Color {
        let base = scheme == .dark ? Color.white : Color.black

        switch intensity {
        case .transparent:
            return base.opacity(0.06)
        case .none:
            return base.opacity(0.12)
        case .low:
            return base.opacity(0.22)
        case .medium:
            return base.opacity(0.36)
        case .high:
            return base.opacity(0.54)
        case .veryHigh:
            return base.opacity(0.78)
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
