import UIKit

final class ClosestToOddsView: UIView {
    static let collapsedCount = 5

    var onSelect: ((CatchSummary) -> Void)?

    fileprivate let rows = UIStackView()
    fileprivate let lengthButton = UIButton(type: .system)
    fileprivate var oddsHunts = [OddsHunt]()
    fileprivate var showsAllRanked = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        clipsToBounds = true
        rows.axis = .vertical
        lengthButton.titleLabel?.font = UIFont.make(.subheadline, weight: .semibold)
        lengthButton.tintColor = Color.accent
        lengthButton.addTarget(self, action: #selector(lengthPressed), for: .touchUpInside)
        let layout = UIStackView(arrangedSubviews: [rows, lengthButton])
        layout.axis = .vertical
        layout.spacing = 6
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(oddsHunts: [OddsHunt]) {
        self.oddsHunts = oddsHunts
        rebuildRows()
    }

    fileprivate func rebuildRows() {
        for row in rows.arrangedSubviews {
            row.removeFromSuperview()
        }
        let visibleHunts = showsAllRanked ? oddsHunts : Array(oddsHunts.prefix(ClosestToOddsView.collapsedCount))
        for (index, oddsHunt) in visibleHunts.enumerated() {
            let gameOrOutcome = oddsHunt.hunt.isFailed ? "Got away" : oddsHunt.hunt.game.displayName
            let row = HuntRankRow(rank: index + 1, hunt: oddsHunt.hunt, detail: "\(gameOrOutcome) · 1/\(oddsHunt.odds.grouped)", valueDetail: ClosestToOddsView.formatDistance(of: oddsHunt),
                                  valueDetailColor: oddsHunt.encountersPastOdds == 0 ? Color.success : Color.textTertiary)
            row.onTap = { [weak self] in
                self?.onSelect?(oddsHunt.hunt)
            }
            rows.addArrangedSubview(row)
        }
        lengthButton.isHidden = oddsHunts.count <= ClosestToOddsView.collapsedCount
        lengthButton.setTitle(showsAllRanked ? "Show top \(ClosestToOddsView.collapsedCount)" : "Show top \(oddsHunts.count)", for: .normal)
    }

    fileprivate static func formatDistance(of oddsHunt: OddsHunt) -> String {
        let difference = oddsHunt.encountersPastOdds
        if (difference == 0) {
            return "At odds"
        }
        return "\(abs(difference).grouped) \(difference > 0 ? "over" : "under")"
    }

    @objc fileprivate func lengthPressed() {
        showsAllRanked.toggle()
        rebuildRows()
    }
}
