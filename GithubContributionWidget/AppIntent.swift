//
//  AppIntent.swift
//  GithubContributionWidget
//
//  Created by Sekul on 27.09.2025.
//

import AppIntents
import Foundation
import WidgetKit

enum ContributionRangeOption: String, AppEnum {
    case halfYear
    case fullYear

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Time Range"

    static var caseDisplayRepresentations: [ContributionRangeOption: DisplayRepresentation] = [
        .halfYear: "Past 6 Months",
        .fullYear: "Past 12 Months",
    ]

    var weeks: Int {
        switch self {
        case .halfYear:
            return 26
        case .fullYear:
            return 52
        }
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Configure your GitHub widget")

    @Parameter(title: "GitHub Username", default: "")
    var username: String

    @Parameter(title: "Personal Access Token", default: "")
    var token: String

    @Parameter(title: "Time Range", default: .fullYear)
    var range: ContributionRangeOption
}
