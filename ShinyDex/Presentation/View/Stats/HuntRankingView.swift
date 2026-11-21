import UIKit

final class HuntRankingView: UIView {
    enum Ranking: Int, CaseIterable {
        case longest, shortest

        var title: String {
            switch self {
            case .longest: return "Longest"
            case .shortest: return "Shortest"
            }
        }
    }

    static let collapsedCount = 5

    var onSelect: ((CatchSummary) -> Void)?

    fileprivate let rankingControl = UISegmentedControl(items: Ranking.allCases.map { $0.title })
    fileprivate let rows = UIStackView()
    fileprivate let lengthButton = UIButton(type: .system)
    fileprivate var longestHunts = [CatchSummary]()
    fileprivate var shortestHunts = [CatchSummary]()
    fileprivate var showsAllRanked = false

    fileprivate var selectedRanking: Ranking {
        return Ranking(rawValue: rankingControl.selectedSegmentIndex) ?? .longest
    }

    fileprivate var selectedHunts: [CatchSummary] {
        return selectedRanking == .longest ? longestHunts : shortestHunts
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        clipsToBounds = true

        rankingControl.selectedSegmentIndex = Ranking.longest.rawValue
        rankingControl.selectedSegmentTintColor = Color.accent
        rankingControl.backgroundColor = Color.surfaceRaised
        rankingControl.setTitleTextAttributes([.foregroundColor: Color.background, .font: UIFont.make(.subheadline, weight: .semibold)], for: .selected)
        rankingControl.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.subheadline, weight: .medium)], for: .normal)
        rankingControl.addTarget(self, action: #selector(rankingChanged), for: .valueChanged)

        rows.axis = .vertical
        lengthButton.titleLabel?.font = UIFont.make(.subheadline, weight: .semibold)
        lengthButton.tintColor = Color.accent
        lengthButton.addTarget(self, action: #selector(lengthPressed), for: .touchUpInside)

        let rankingControlWrapper = UIView()
        rankingControlWrapper.addAutoLayoutSubviews(rankingControl)
        rankingControl.pinEdges(to: rankingControlWrapper, insets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14))

        let layout = UIStackView(arrangedSubviews: [rankingControlWrapper, rows, lengthButton])
        layout.axis = .vertical
        layout.spacing = 6
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 0, bottom: 6, right: 0))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(longestHunts: [CatchSummary], shortestHunts: [CatchSummary]) {
        self.longestHunts = longestHunts
        self.shortestHunts = shortestHunts
        rebuildRows()
    }

    fileprivate func rebuildRows() {
        for row in rows.arrangedSubviews {
            row.removeFromSuperview()
        }
        let hunts = selectedHunts
        let visibleHunts = showsAllRanked ? hunts : Array(hunts.prefix(HuntRankingView.collapsedCount))
        for (index, hunt) in visibleHunts.enumerated() {
            let row = HuntRankRow(rank: index + 1, hunt: hunt)
            row.onTap = { [weak self] in
                self?.onSelect?(hunt)
            }
            rows.addArrangedSubview(row)
        }
        lengthButton.isHidden = hunts.count <= HuntRankingView.collapsedCount
        lengthButton.setTitle(showsAllRanked ? "Show top \(HuntRankingView.collapsedCount)" : "Show top \(hunts.count)", for: .normal)
    }

    @objc fileprivate func rankingChanged() {
        rebuildRows()
    }

    @objc fileprivate func lengthPressed() {
        showsAllRanked.toggle()
        rebuildRows()
    }
}
