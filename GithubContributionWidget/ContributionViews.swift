//
//  ContributionViews.swift
//  GithubContributionWidgetMacOS
//
//  Created by Sekul on 27.09.2025.
//

import SwiftUI
import WidgetKit

struct ContributionCell: View {
    let contribution: ContributionDay
    let size: CGFloat
    let scheme: ColorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
            .fill(DesktopCalendarTheme.color(for: contribution.intensity, scheme: scheme))
            .frame(width: size, height: size)
    }
}

struct ContributionGrid: View {
    let contributions: [ContributionDay]
    let family: WidgetFamily
    let range: ContributionRangeOption
    let scheme: ColorScheme

    private var spacing: CGFloat { family == .systemMedium ? 7.5 : 4.5 }

    var body: some View {
        GeometryReader { geometry in
            let weeksToShow = range.weeks
            let outerCornerRadius: CGFloat = family == .systemMedium ? 30 : 22
            let outerPadding = max(7, geometry.size.width * 0.015)
            let borderGap: CGFloat = family == .systemMedium ? 8 : 6
            let contentInset: CGFloat = family == .systemMedium ? 12 : 8
            let contentPadding = outerPadding + borderGap + contentInset

            let availableHeight = geometry.size.height - contentPadding * 2
            let availableWidth = geometry.size.width - contentPadding * 2
            let verticalSpacingTotal = spacing * 6
            let horizontalSpacingTotal = spacing * CGFloat(max(weeksToShow - 1, 0))

            let cellSizeFromHeight = (availableHeight - verticalSpacingTotal) / 7
            let cellSizeFromWidth = (availableWidth - horizontalSpacingTotal) / CGFloat(max(weeksToShow, 1))
            let cellSize = max(2, min(cellSizeFromHeight, cellSizeFromWidth))

            let weeksArray = weeks(from: contributions, weeksToShow: weeksToShow)

            let actualGridWidth =
                CGFloat(weeksArray.count) * cellSize + CGFloat(
                    weeksArray.count - 1
                ) * spacing
            let actualGridHeight = (cellSize * 7) + verticalSpacingTotal

            let gridLeading = contentPadding + max(0, (availableWidth - actualGridWidth) / 2)
            let gridTop = contentPadding + max(0, (availableHeight - actualGridHeight) / 2)
            let frameShape = RoundedRectangle(cornerRadius: outerCornerRadius, style: .continuous)

            ZStack(alignment: .topLeading) {
                frameShape
                    .stroke(
                        DesktopCalendarTheme.color(for: .high, scheme: scheme).opacity(0.48),
                        lineWidth: 1.25
                    )
                    .padding(outerPadding)
                    .shadow(
                        color: DesktopCalendarTheme.color(for: .high, scheme: scheme).opacity(0.16),
                        radius: 6,
                        x: 0,
                        y: 2
                    )

                frameShape
                    .inset(by: borderGap)
                    .stroke(
                        DesktopCalendarTheme.color(for: .high, scheme: scheme).opacity(0.74),
                        lineWidth: 1.3
                    )
                    .padding(outerPadding)

                HStack(spacing: spacing) {
                    ForEach(weeksArray.indices, id: \.self) { weekIndex in
                        VStack(spacing: spacing) {
                            ForEach(0..<7) { dayIndex in
                                ContributionCell(
                                    contribution: weeksArray[weekIndex][dayIndex],
                                    size: cellSize,
                                    scheme: scheme
                                )
                            }
                        }
                    }
                }
                .frame(width: actualGridWidth, height: actualGridHeight, alignment: .topLeading)
                .padding(.leading, gridLeading)
                .padding(.top, gridTop)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .topLeading
            )
        }
    }

    private func weeks(from contributions: [ContributionDay], weeksToShow: Int)
        -> [[ContributionDay]]
    {
        let requiredDays = max(weeksToShow * 7, 7)
        let visibleDays = Array(contributions.suffix(requiredDays))

        var paddedDays: [ContributionDay] = visibleDays
        if paddedDays.count < requiredDays {
            let missing = requiredDays - paddedDays.count
            paddedDays = Array(repeating: ContributionDay(date: Date(), contributionCount: nil), count: missing) + paddedDays
        }

        guard !paddedDays.isEmpty else { return [] }

        var weeks: [[ContributionDay]] = []
        for index in stride(from: 0, to: paddedDays.count, by: 7) {
            let slice = Array(paddedDays[index..<min(index + 7, paddedDays.count)])
            if slice.count == 7 {
                weeks.append(slice)
            }
        }

        return weeks
    }
}
