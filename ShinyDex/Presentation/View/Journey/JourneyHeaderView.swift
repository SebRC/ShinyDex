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

    fileprivate let countLabel = UILabel(fontSize: 34, weight: .bold, color: Color.Grey100)
    fileprivate let detailLabel = UILabel(fontSize: 13, color: Color.Grey400)
    fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
    fileprivate let modeControl = UISegmentedControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let card = UIView()
        card.backgroundColor = Color.Grey800
        card.layer.cornerRadius = 14
        let caption = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey400)
        caption.text = "CAUGHT"
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 34, weight: .bold)
        progressBar.progressTintColor = Color.Orange500
        progressBar.trackTintColor = Color.Grey700
        progressBar.layer.cornerRadius = 3
        progressBar.clipsToBounds = true
        let cardStack = UIStackView(arrangedSubviews: [caption, countLabel, detailLabel, progressBar])
        cardStack.axis = .vertical
        cardStack.spacing = 2
        cardStack.setCustomSpacing(12, after: detailLabel)
        card.addAutoLayoutSubviews(cardStack)
        cardStack.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 16, bottom: 16, right: 16))
        card.isAccessibilityElement = true

        modeControl.selectedSegmentTintColor = Color.Orange500
        modeControl.backgroundColor = Color.Grey800
        modeControl.setTitleTextAttributes([.foregroundColor: Color.Grey900, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
        modeControl.setTitleTextAttributes([.foregroundColor: Color.Grey300, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], for: .normal)
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
            detailLabel.textColor = Color.Orange500
        }
        else {
            let remaining = total - caught
            let remainingText = remaining == 1 ? "1 to go" : "\(remaining) to go"
            let firstCatchText = firstCatch.map { "first catch \(DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none))" }
            detailLabel.text = [remainingText, phasesText, firstCatchText].compactMap { $0 }.joined(separator: " · ")
            detailLabel.textColor = Color.Grey400
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
