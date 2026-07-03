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
        RoundedRectangle(cornerRadius: size * 0.36, style: .continuous)
            .fill(DesktopCalendarTheme.color(for: contribution.intensity, scheme: scheme))
            .frame(width: size, height: size)
    }
}

struct ContributionGrid: View {
    let contributions: [ContributionDay]
    let family: WidgetFamily
    let scheme: ColorScheme

    private let weeksToShow = 26

    private var spacing: CGFloat { family == .systemMedium ? 7.5 : 4.5 }

    var body: some View {
        GeometryReader { geometry in
            let frameInsetX: CGFloat = family == .systemMedium ? 18 : 12
            let frameInsetTop: CGFloat = family == .systemMedium ? 16 : 10
            let frameInsetBottom: CGFloat = family == .systemMedium ? 20 : 12
            let gridInsetLeading: CGFloat = family == .systemMedium ? 16 : 10
            let gridInsetTrailing: CGFloat = family == .systemMedium ? 16 : 10
            let gridInsetTop: CGFloat = family == .systemMedium ? 10 : 8
            let gridInsetBottom: CGFloat = family == .systemMedium ? 14 : 10

            let frameWidth = geometry.size.width - frameInsetX * 2
            let frameHeight = geometry.size.height - frameInsetTop - frameInsetBottom
            let frameX = frameInsetX
            let frameY = frameInsetTop
            let availableWidth = frameWidth - gridInsetLeading - gridInsetTrailing
            let verticalSpacingTotal = spacing * 6
            let horizontalSpacingTotal = spacing * CGFloat(max(weeksToShow - 1, 0))
            let availableHeight = frameHeight - gridInsetTop - gridInsetBottom

            let cellSizeFromWidth =
                (availableWidth - horizontalSpacingTotal) / CGFloat(max(weeksToShow, 1))
            let cellSizeFromHeight =
                (availableHeight - verticalSpacingTotal) / 7
            let cellSize = max(2, min(cellSizeFromWidth, cellSizeFromHeight))

            let weeksArray = weeks(from: contributions, weeksToShow: weeksToShow)

            let actualGridWidth =
                CGFloat(weeksArray.count) * cellSize + CGFloat(
                    weeksArray.count - 1
                ) * spacing
            let actualGridHeight = (cellSize * 7) + verticalSpacingTotal

            let gridLeading = frameX + gridInsetLeading + max(0, (availableWidth - actualGridWidth) / 2)
            let gridTop = frameY + gridInsetTop
            let frameShape = RoundedRectangle(cornerRadius: family == .systemMedium ? 28 : 20, style: .continuous)

            ZStack(alignment: .topLeading) {
                frameShape
                    .stroke(
                        DesktopCalendarTheme.color(for: .high, scheme: scheme).opacity(0.16),
                        lineWidth: 1.3
                    )
                    .frame(width: frameWidth, height: frameHeight)
                    .position(x: frameX + frameWidth / 2, y: frameY + frameHeight / 2)

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
