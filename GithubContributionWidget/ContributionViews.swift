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
            let framePaddingX: CGFloat = family == .systemMedium ? 18 : 12
            let framePaddingY: CGFloat = family == .systemMedium ? 11 : 8
            let outerMarginX = max(14, geometry.size.width * 0.045)
            let outerMarginY = max(18, geometry.size.height * 0.09)

            let availableWidth = geometry.size.width - (outerMarginX + framePaddingX) * 2
            let verticalSpacingTotal = spacing * 6
            let horizontalSpacingTotal = spacing * CGFloat(max(weeksToShow - 1, 0))

            let cellSizeFromWidth =
                (availableWidth - horizontalSpacingTotal) / CGFloat(max(weeksToShow, 1))
            let cellSize = max(2, cellSizeFromWidth)

            let weeksArray = weeks(from: contributions, weeksToShow: weeksToShow)

            let actualGridWidth =
                CGFloat(weeksArray.count) * cellSize + CGFloat(
                    weeksArray.count - 1
                ) * spacing
            let actualGridHeight = (cellSize * 7) + verticalSpacingTotal

            let frameWidth = actualGridWidth + framePaddingX * 2
            let frameHeight = actualGridHeight + framePaddingY * 2
            let frameX = (geometry.size.width - frameWidth) / 2
            let frameY = max(outerMarginY, (geometry.size.height - frameHeight) / 2)
            let gridLeading = frameX + framePaddingX
            let gridTop = frameY + framePaddingY
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
