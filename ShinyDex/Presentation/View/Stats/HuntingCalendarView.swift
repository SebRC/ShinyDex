import UIKit

final class HuntingCalendarView: UIView {
    fileprivate enum ShinyMark {
        case caught, caughtSeveral, gotAway

        init?(_ day: EncounterHistory.CalendarDay) {
            if day.caughtCount > 1 {
                self = .caughtSeveral
            } else if day.caughtCount == 1 {
                self = .caught
            } else if day.gotAwayCount > 0 {
                self = .gotAway
            } else {
                return nil
            }
        }
    }

    fileprivate static let levelColors = [Color.surfaceRaised, Color.Orange800, Color.Orange700, Color.Orange600, Color.accent]
    fileprivate static let cellSpacing: CGFloat = 3
    fileprivate static let markColor = Color.textPrimary
    fileprivate static let singleDotShareOfCell: CGFloat = 0.4
    fileprivate static let ringShareOfCell: CGFloat = 0.5
    fileprivate static let pairedDotShareOfCell: CGFloat = 0.28
    fileprivate static let pairedDotSpacing: CGFloat = 1
    fileprivate static let legendSwatchSize: CGFloat = 10

    fileprivate let onDaySelected: (Date) -> Void
    fileprivate var selectableDays = [(cell: UIView, date: Date)]()

    init(weeks: [[EncounterHistory.CalendarDay?]], onDaySelected: @escaping (Date) -> Void) {
        self.onDaySelected = onDaySelected
        super.init(frame: .zero)
        let maxCount = weeks.joined().compactMap { $0?.count }.max() ?? 0
        let columns = weeks.map { week in makeColumn(week, maxCount: maxCount) }
        let grid = UIStackView(arrangedSubviews: columns)
        grid.distribution = .fillEqually
        grid.spacing = HuntingCalendarView.cellSpacing
        grid.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gridTapped)))

        let monthLabels = UIView()
        let legend = HuntingCalendarView.makeLegend()
        addAutoLayoutSubviews(monthLabels, grid, legend)
        NSLayoutConstraint.activate([
            monthLabels.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            monthLabels.leadingAnchor.constraint(equalTo: grid.leadingAnchor),
            monthLabels.trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            monthLabels.heightAnchor.constraint(equalToConstant: 14),
            grid.topAnchor.constraint(equalTo: monthLabels.bottomAnchor, constant: 4),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            legend.topAnchor.constraint(equalTo: grid.bottomAnchor, constant: 8),
            legend.leadingAnchor.constraint(equalTo: grid.leadingAnchor),
            legend.trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            legend.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        HuntingCalendarView.addMonthLabels(to: monthLabels, weeks: weeks, columns: columns)

        let days = weeks.joined().compactMap { $0 }
        let huntedDayCount = days.filter { $0.count > 0 }.count
        let shinyDayCount = days.filter { $0.caughtCount > 0 }.count
        let gotAwayDayCount = days.filter { $0.caughtCount == 0 && $0.gotAwayCount > 0 }.count
        isAccessibilityElement = true
        accessibilityLabel = "Hunting calendar"
        accessibilityValue = [
            HuntingCalendarView.formatDays(huntedDayCount, "hunted"),
            HuntingCalendarView.formatDays(shinyDayCount, "with a shiny caught"),
            gotAwayDayCount > 0 ? HuntingCalendarView.formatDays(gotAwayDayCount, "with a shiny that got away") : nil
        ].compactMap { $0 }.joined(separator: ", ") + " in the last \(weeks.count) weeks"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func gridTapped(_ recognizer: UITapGestureRecognizer) {
        let touchSlop = -HuntingCalendarView.cellSpacing / 2
        guard let day = selectableDays.first(where: { day in
            day.cell.bounds.insetBy(dx: touchSlop, dy: touchSlop).contains(recognizer.location(in: day.cell))
        }) else { return }
        Haptics.tap()
        onDaySelected(day.date)
    }

    fileprivate func makeColumn(_ week: [EncounterHistory.CalendarDay?], maxCount: Int) -> UIView {
        let cells = week.map { day -> UIView in
            let cell = UIView()
            cell.layer.cornerRadius = CornerRadius.tiny
            cell.heightAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
            guard let day = day else { return cell }
            cell.backgroundColor = HuntingCalendarView.levelColors[HuntingCalendarView.findLevel(of: day.count, maxCount: maxCount)]
            if Calendar.current.isDateInToday(day.start) {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = Color.textPrimary.cgColor
            }
            if let mark = ShinyMark(day) {
                HuntingCalendarView.addMark(mark, to: cell)
            }
            if day.count > 0 || ShinyMark(day) != nil {
                selectableDays.append((cell, day.start))
            }
            return cell
        }
        let column = UIStackView(arrangedSubviews: cells)
        column.axis = .vertical
        column.spacing = HuntingCalendarView.cellSpacing
        return column
    }

    fileprivate static func addMark(_ mark: ShinyMark, to cell: UIView) {
        let dots: [UIView]
        let shareOfCell: CGFloat
        switch mark {
        case .caught:
            dots = [makeDot()]
            shareOfCell = singleDotShareOfCell
        case .gotAway:
            dots = [makeDot(isHollow: true)]
            shareOfCell = ringShareOfCell
        case .caughtSeveral:
            dots = [makeDot(), makeDot()]
            shareOfCell = pairedDotShareOfCell
        }
        let marker = UIStackView(arrangedSubviews: dots)
        marker.spacing = pairedDotSpacing
        cell.addAutoLayoutSubviews(marker)
        NSLayoutConstraint.activate([
            marker.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            marker.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ] + dots.flatMap { dot in [
            dot.widthAnchor.constraint(equalTo: cell.widthAnchor, multiplier: shareOfCell),
            dot.heightAnchor.constraint(equalTo: dot.widthAnchor)
        ] })
    }

    fileprivate static func makeDot(isHollow: Bool = false) -> UIView {
        let dot = CircleView()
        if isHollow {
            dot.layer.borderWidth = 1
            dot.layer.borderColor = markColor.cgColor
        } else {
            dot.backgroundColor = markColor
        }
        return dot
    }

    fileprivate static func findLevel(of count: Int, maxCount: Int) -> Int {
        guard count > 0, maxCount > 0 else { return 0 }
        let highestLevel = levelColors.count - 1
        return min(max(Int((Double(count) / Double(maxCount) * Double(highestLevel)).rounded(.up)), 1), highestLevel)
    }

    fileprivate static func formatDays(_ count: Int, _ description: String) -> String {
        return "\(count) \(count == 1 ? "day" : "days") \(description)"
    }

    fileprivate static func addMonthLabels(to container: UIView, weeks: [[EncounterHistory.CalendarDay?]], columns: [UIView]) {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        var previousMonth: Int?
        for (index, week) in weeks.enumerated() {
            guard let firstDay = week.compactMap({ $0 }).first?.start else { continue }
            let month = Calendar.current.component(.month, from: firstDay)
            defer { previousMonth = month }
            guard previousMonth != nil, month != previousMonth else { continue }
            let label = UILabel(style: .caption2, weight: .semibold, color: Color.textQuaternary)
            label.text = formatter.string(from: firstDay)
            container.addAutoLayoutSubviews(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: columns[index].leadingAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        }
    }

    // MARK: Legend

    fileprivate static func makeLegend() -> UIView {
        let markKey = UIStackView(arrangedSubviews: [makeMarkKeyItem(.caught, title: "Caught"), makeMarkKeyItem(.gotAway, title: "Got away")])
        markKey.spacing = Spacing.small
        let legend = UIStackView(arrangedSubviews: [markKey, UIView(), makeLevelKey()])
        legend.alignment = .center
        return legend
    }

    fileprivate static func makeMarkKeyItem(_ mark: ShinyMark, title: String) -> UIView {
        let swatch = makeSwatch(color: levelColors[0])
        addMark(mark, to: swatch)
        let item = UIStackView(arrangedSubviews: [swatch, makeLegendLabel(title)])
        item.spacing = 5
        item.alignment = .center
        return item
    }

    fileprivate static func makeLevelKey() -> UIView {
        let swatches = levelColors.map(makeSwatch)
        let key = UIStackView(arrangedSubviews: [makeLegendLabel("Less")] + swatches + [makeLegendLabel("More")])
        key.spacing = 3
        key.alignment = .center
        key.setCustomSpacing(5, after: key.arrangedSubviews[0])
        key.setCustomSpacing(5, after: swatches.last!)
        return key
    }

    fileprivate static func makeSwatch(color: UIColor) -> UIView {
        let swatch = UIView()
        swatch.backgroundColor = color
        swatch.layer.cornerRadius = CornerRadius.tiny
        NSLayoutConstraint.activate([
            swatch.widthAnchor.constraint(equalToConstant: legendSwatchSize),
            swatch.heightAnchor.constraint(equalToConstant: legendSwatchSize)
        ])
        return swatch
    }

    fileprivate static func makeLegendLabel(_ text: String) -> UILabel {
        let label = UILabel(style: .caption2, weight: .semibold, color: Color.textQuaternary)
        label.text = text
        return label
    }
}

final class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
