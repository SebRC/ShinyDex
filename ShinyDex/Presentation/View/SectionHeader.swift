import UIKit

class SectionHeaderLabel: UILabel {
    fileprivate let insets: UIEdgeInsets

    init(text: String? = nil, horizontalInset: CGFloat = 14) {
        insets = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        super.init(frame: .zero)
        font = UIFont.make(.footnote, weight: .semibold)
        adjustsFontForContentSizeCategory = true
        textColor = Color.textTertiary
        accessibilityTraits = .header
        self.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var text: String? {
        get { return super.text }
        set { super.text = newValue?.uppercased() }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height)
    }
}

final class SectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "sectionHeader"
    fileprivate let label = SectionHeaderLabel(horizontalInset: 0)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addAutoLayoutSubviews(label)
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.large),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String?) {
        label.text = title
    }

    static func make(for tableView: UITableView, title: String?) -> UIView? {
        guard let title = title else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: reuseIdentifier)
        header.configure(title: title)
        return header
    }
}
