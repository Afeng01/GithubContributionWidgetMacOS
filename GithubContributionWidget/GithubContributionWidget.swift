//
//  GithubContributionWidget.swift
//  GithubContributionWidget
//
//  Created by Sekul on 27.09.2025.
//

import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            contributions: []
        )
    }

    func snapshot(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: configuration,
            contributions: []
        )
    }

    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()

        let username = configuration.username
        let token = configuration.token.isEmpty ? nil : configuration.token

        var minutes = 5

        do {
            let contributions = try await GitHubAPI.fetchContributions(
                username: username,
                token: token
            )
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                contributions: contributions
            )
            entries.append(entry)
            minutes = 30
        } catch {
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                contributions: []
            )
            entries.append(entry)
        }

        let refreshDate = Calendar.current.date(
            byAdding: .minute,
            value: minutes,
            to: currentDate
        )!

        return Timeline(entries: entries, policy: .after(refreshDate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let contributions: [ContributionDay]
}

struct GithubContributionWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    private let previewWeeks = 26

    var body: some View {
        ContributionGrid(
            contributions: previewContributionsIfNeeded,
            family: family,
            scheme: colorScheme
        )
        .containerBackground(.clear, for: .widget)
        .widgetURL(
            URL(string: "https://github.com/\(entry.configuration.username)")!
        )
    }

    private var previewContributionsIfNeeded: [ContributionDay] {
        guard entry.contributions.isEmpty else { return entry.contributions }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let totalDays = max(7, previewWeeks * 7)

        return (0..<totalDays).map { offset in
            let date = calendar.date(byAdding: .day, value: -(totalDays - 1) + offset, to: today) ?? today
            let pattern = [0, 0, 1, 0, 2, 3, 4]
            let count = pattern[offset % pattern.count]
            return ContributionDay(date: date, contributionCount: count)
        }
    }
}

struct GithubContributionWidget: Widget {
    let kind: String = "GithubContributionWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            GithubContributionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Desktop Calendar")
        .description("A desktop-style GitHub activity card.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
