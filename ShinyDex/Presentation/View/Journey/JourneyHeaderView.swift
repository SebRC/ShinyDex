import UIKit

final class JourneyHeaderView: UIView {
    var onModeChange: ((Int) -> Void)?
    var modeTitles = [String]() {
        didSet {
            modeControl.removeAllSegments()
            for (index, title) in modeTitles.enumerated() {
                modeControl.insertSegment(withTitle: title, at: index, animated: false)
            }
            modeControl.selectedSegmentIndex = 0
        }
    }

    fileprivate let countLabel = UILabel(style: .largeTitle, weight: .bold, color: Color.textPrimary)
    fileprivate let detailLabel = UILabel(style: .footnote, color: Color.textTertiary)
    fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
    fileprivate let modeControl = UISegmentedControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        let caption = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
        caption.text = "CAUGHT"
        countLabel.font = UIFont.make(.largeTitle, weight: .bold, monospacedDigits: true)
        progressBar.progressTintColor = Color.accent
        progressBar.trackTintColor = Color.surfaceRaised
        progressBar.layer.cornerRadius = CornerRadius.tiny
        progressBar.clipsToBounds = true
        let cardStack = UIStackView(arrangedSubviews: [caption, countLabel, detailLabel, progressBar])
        cardStack.axis = .vertical
        cardStack.spacing = 2
        cardStack.setCustomSpacing(12, after: detailLabel)
        card.addAutoLayoutSubviews(cardStack)
        cardStack.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 16, bottom: 16, right: 16))
        card.isAccessibilityElement = true

        modeControl.selectedSegmentTintColor = Color.accent
        modeControl.backgroundColor = Color.surface
        modeControl.setTitleTextAttributes([.foregroundColor: Color.background, .font: UIFont.make(.subheadline, weight: .semibold)], for: .selected)
        modeControl.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.subheadline, weight: .medium)], for: .normal)
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [card, modeControl])
        stack.axis = .vertical
        stack.spacing = 16
        preservesSuperviewLayoutMargins = true
        addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 6),
            modeControl.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(caught: Int, total: Int, phases: Int, firstCatch: Date?) {
        countLabel.text = "\(caught) / \(total)"
        let phasesText = phases == 0 ? nil : (phases == 1 ? "1 phase" : "\(phases.grouped) phases")
        if (total > 0 && caught == total) {
            detailLabel.text = ["Journey complete", phasesText].compactMap { $0 }.joined(separator: " · ")
            detailLabel.textColor = Color.accent
        }
        else {
            let remaining = total - caught
            let remainingText = remaining == 1 ? "1 to go" : "\(remaining) to go"
            let firstCatchText = firstCatch.map { "first catch \(DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none))" }
            detailLabel.text = [remainingText, phasesText, firstCatchText].compactMap { $0 }.joined(separator: " · ")
            detailLabel.textColor = Color.textTertiary
        }
        progressBar.progress = total == 0 ? 0 : Float(caught) / Float(total)
        countLabel.superview?.superview?.accessibilityLabel = "\(caught) of \(total) caught, \(detailLabel.text ?? "")"
    }

    func selectMode(_ index: Int) {
        modeControl.selectedSegmentIndex = index
    }

    @objc fileprivate func modeChanged() {
        onModeChange?(modeControl.selectedSegmentIndex)
    }
}
