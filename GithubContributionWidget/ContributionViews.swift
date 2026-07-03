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
        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
            .fill(DesktopCalendarTheme.color(for: contribution.intensity, scheme: scheme))
            .frame(width: size, height: size)
    }
}

struct ContributionGrid: View {
    let contributions: [ContributionDay]
    let family: WidgetFamily
    let scheme: ColorScheme

    private var spacing: CGFloat { family == .systemMedium ? 2.7 : 2.5 }

    var body: some View {
        GeometryReader { geometry in
            let frameInsetX: CGFloat = family == .systemMedium ? 7 : 8
            let frameInsetTop: CGFloat = family == .systemMedium ? 7 : 8
            let frameInsetBottom: CGFloat = family == .systemMedium ? 9 : 9
            let gridInsetLeading: CGFloat = family == .systemMedium ? 12 : 10
            let gridInsetTrailing: CGFloat = family == .systemMedium ? 12 : 10
            let gridInsetTop: CGFloat = family == .systemMedium ? 5 : 6
            let gridInsetBottom: CGFloat = family == .systemMedium ? 5 : 6

            let frameWidth = geometry.size.width - frameInsetX * 2
            let frameHeight = geometry.size.height - frameInsetTop - frameInsetBottom
            let frameX = frameInsetX
            let frameY = frameInsetTop
            let availableWidth = frameWidth - gridInsetLeading - gridInsetTrailing
            let verticalSpacingTotal = spacing * 6
            let availableHeight = frameHeight - gridInsetTop - gridInsetBottom

            let cellSizeFromHeight =
                (availableHeight - verticalSpacingTotal) / 7
            let adaptiveColumns = max(
                1,
                Int((availableWidth + spacing) / (cellSizeFromHeight + spacing))
            )
            let targetColumns = family == .systemMedium ? 16 : adaptiveColumns
            let horizontalSpacingTotal = spacing * CGFloat(max(targetColumns - 1, 0))
            let cellSizeFromWidth =
                (availableWidth - horizontalSpacingTotal) / CGFloat(max(targetColumns, 1))
            let cellSize = max(2, min(cellSizeFromWidth, cellSizeFromHeight) * 0.98)

            let weeksArray = weeks(from: contributions, columnsToShow: targetColumns)

            let actualGridWidth =
                CGFloat(weeksArray.count) * cellSize + CGFloat(
                    weeksArray.count - 1
                ) * spacing
            let actualGridHeight = (cellSize * 7) + verticalSpacingTotal

            let gridLeading = frameX + gridInsetLeading + max(0, (availableWidth - actualGridWidth) / 2)
            let gridTop = frameY + gridInsetTop + max(0, availableHeight - actualGridHeight) * 0.18
            let frameShape = RoundedRectangle(cornerRadius: family == .systemMedium ? 26 : 19, style: .continuous)

            ZStack(alignment: .topLeading) {
                frameShape
                    .fill(DesktopCalendarTheme.surfaceFill(for: scheme))
                    .frame(width: frameWidth, height: frameHeight)
                    .position(x: frameX + frameWidth / 2, y: frameY + frameHeight / 2)

                frameShape
                    .stroke(
                        DesktopCalendarTheme.frameStroke(for: scheme),
                        lineWidth: 1.2
                    )
                    .frame(width: frameWidth, height: frameHeight)
                    .position(x: frameX + frameWidth / 2, y: frameY + frameHeight / 2)
                    .shadow(
                        color: DesktopCalendarTheme.frameGlow(for: scheme),
                        radius: 8,
                        x: 0,
                        y: 2
                    )

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

    private func weeks(from contributions: [ContributionDay], columnsToShow: Int)
        -> [[ContributionDay]]
    {
        let requiredDays = max(columnsToShow * 7, 7)
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
