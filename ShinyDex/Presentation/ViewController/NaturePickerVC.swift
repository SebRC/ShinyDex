import UIKit

class NaturePickerVC: UIViewController {
    fileprivate static let headerWidth: CGFloat = 40
    fileprivate static let cellHeight: CGFloat = 52
    fileprivate static let spacing: CGFloat = 4

    fileprivate let selected: Nature?
    fileprivate let onPick: (Nature?) -> Void

    init(selected: Nature?, onPick: @escaping (Nature?) -> Void) {
        self.selected = selected
        self.onPick = onPick
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nature"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.background
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearPressed))
        clearButton.isEnabled = selected != nil
        navigationItem.rightBarButtonItem = clearButton

        let grid = UIStackView(arrangedSubviews: [makeColumnHeaders()] + Nature.grid.enumerated().map { makeRow(raising: Nature.gridStats[$0.offset], natures: $0.element) })
        grid.axis = .vertical
        grid.spacing = NaturePickerVC.spacing
        let footnote = UILabel(style: .caption1, color: Color.textQuaternary, lines: 0)
        footnote.text = "Each row raises a stat by 10% and each column lowers one. Natures on the diagonal are neutral."
        let stack = UIStackView(arrangedSubviews: [grid, footnote])
        stack.axis = .vertical
        stack.spacing = 16

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.screenMargin),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.screenMargin)
        ])
    }

    // MARK: Layout

    fileprivate func makeColumnHeaders() -> UIView {
        let corner = UIView()
        corner.widthAnchor.constraint(equalToConstant: NaturePickerVC.headerWidth).isActive = true
        let labels = Nature.gridStats.map { makeHeaderLabel(text: "−\($0.shortName)", color: Color.textTertiary) }
        return makeGridRow(header: corner, cells: labels)
    }

    fileprivate func makeRow(raising stat: Stat, natures: [Nature]) -> UIView {
        let header = makeHeaderLabel(text: "+\(stat.shortName)", color: Color.accent)
        header.widthAnchor.constraint(equalToConstant: NaturePickerVC.headerWidth).isActive = true
        let buttons = natures.map(makeButton)
        return makeGridRow(header: header, cells: buttons)
    }

    fileprivate func makeGridRow(header: UIView, cells: [UIView]) -> UIView {
        let cellStack = UIStackView(arrangedSubviews: cells)
        cellStack.distribution = .fillEqually
        cellStack.spacing = NaturePickerVC.spacing
        let row = UIStackView(arrangedSubviews: [header, cellStack])
        row.spacing = NaturePickerVC.spacing
        row.alignment = .center
        return row
    }

    fileprivate func makeHeaderLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel(style: .caption1, weight: .bold, color: color)
        label.text = text
        label.textAlignment = .center
        label.isAccessibilityElement = false
        return label
    }

    fileprivate func makeButton(for nature: Nature) -> UIButton {
        let isSelected = nature == selected
        let button = UIButton(type: .custom)
        button.setTitle(nature.name, for: .normal)
        button.titleLabel?.font = UIFont.make(.footnote, weight: .semibold)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        button.setTitleColor(isSelected ? Color.background : (nature.isNeutral ? Color.textTertiary : Color.textPrimary), for: .normal)
        button.backgroundColor = isSelected ? Color.accent : (nature.isNeutral ? Color.background : Color.surface)
        button.layer.cornerRadius = CornerRadius.standard
        if (nature.isNeutral && !isSelected) {
            button.layer.borderWidth = 1
            button.layer.borderColor = Color.surfaceRaised.cgColor
        }
        button.heightAnchor.constraint(equalToConstant: NaturePickerVC.cellHeight).isActive = true
        button.accessibilityLabel = makeAccessibilityDescription(of: nature)
        button.accessibilityTraits = isSelected ? [.button, .selected] : .button
        button.tag = Nature.allCases.firstIndex(of: nature)!
        button.addTarget(self, action: #selector(naturePressed(_:)), for: .touchUpInside)
        return button
    }

    fileprivate func makeAccessibilityDescription(of nature: Nature) -> String {
        guard let raised = nature.raisedStat, let lowered = nature.loweredStat else { return "\(nature.name), neutral" }
        return "\(nature.name), raises \(raised.name), lowers \(lowered.name)"
    }

    // MARK: Picking

    fileprivate func pick(_ nature: Nature?) {
        Haptics.tap()
        onPick(nature)
        navigationController?.popViewController(animated: true)
    }

    @objc fileprivate func naturePressed(_ sender: UIButton) {
        pick(Nature.allCases[sender.tag])
    }

    @objc fileprivate func clearPressed() {
        pick(nil)
    }
}
