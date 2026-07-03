//
//  Models.swift
//  GithubContributionWidgetMacOS
//
//  Created by Sekul on 27.09.2025.
//

import Foundation
import SwiftUI
import WidgetKit

enum DesktopCalendarTheme {
    static func surfaceFill(for scheme: ColorScheme, renderingMode: WidgetRenderingMode) -> Color {
        if renderingMode == .vibrant {
            return Color.black.opacity(scheme == .dark ? 0.34 : 0.28)
        }
        if scheme == .dark {
            return Color.white.opacity(0.06)
        }
        return Color.black.opacity(0.055)
    }

    static func frameStroke(for scheme: ColorScheme, renderingMode: WidgetRenderingMode) -> Color {
        if renderingMode == .vibrant {
            return Color.white.opacity(0.10)
        }
        if scheme == .dark {
            return Color.white.opacity(0.08)
        }
        return Color.black.opacity(0.07)
    }

    static func frameGlow(for scheme: ColorScheme, renderingMode: WidgetRenderingMode) -> Color {
        if renderingMode == .vibrant {
            return Color.black.opacity(0.16)
        }
        if scheme == .dark {
            return Color.white.opacity(0.04)
        }
        return Color.black.opacity(0.05)
    }

    static func color(
        for intensity: ContributionIntensity,
        scheme: ColorScheme,
        renderingMode: WidgetRenderingMode
    ) -> Color {
        let base =
            renderingMode == .vibrant
            ? Color.white
            : (scheme == .dark ? Color.white : Color.black)

        if renderingMode == .vibrant {
            switch intensity {
            case .transparent:
                return base.opacity(0.03)
            case .none:
                return base.opacity(0.10)
            case .low:
                return base.opacity(0.28)
            case .medium:
                return base.opacity(0.46)
            case .high:
                return base.opacity(0.68)
            case .veryHigh:
                return base.opacity(0.88)
            }
        }

        switch intensity {
        case .transparent:
            return base.opacity(0.018)
        case .none:
            return base.opacity(0.045)
        case .low:
            return base.opacity(0.10)
        case .medium:
            return base.opacity(0.18)
        case .high:
            return base.opacity(0.28)
        case .veryHigh:
            return base.opacity(0.42)
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
