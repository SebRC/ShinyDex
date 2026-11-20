import UIKit

class ShinyNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configure()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func configure() {
        overrideUserInterfaceStyle = .dark

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Color.Grey900
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: Color.Orange500]
        appearance.largeTitleTextAttributes = [.foregroundColor: Color.Orange500]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = Color.Orange500
        navigationBar.prefersLargeTitles = true
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let current = topViewController, current.navigationItem.backBarButtonItem == nil {
            current.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        super.pushViewController(viewController, animated: animated)
    }
}

extension UIViewController {
    func wrapInSheet() -> ShinyNavigationController {
        let navigationController = ShinyNavigationController(rootViewController: self)
        navigationController.navigationBar.prefersLargeTitles = false
        return navigationController
    }

    func dismissSheet(completion: (() -> Void)? = nil) {
        if let presenter = presentingViewController {
            presenter.dismiss(animated: true, completion: completion)
        }
        else {
            dismiss(animated: true, completion: completion)
        }
    }
}

extension UIImage {
    static func makeSymbol(_ name: String, pointSize: CGFloat, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        return UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight))
    }
}

extension UIButton {
    static func makeSymbolButton(_ name: String, pointSize: CGFloat, accessibilityLabel: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage.makeSymbol(name, pointSize: pointSize), for: .normal)
        button.tintColor = Color.Grey200
        button.accessibilityLabel = accessibilityLabel
        return button
    }
}

extension UIView {
    func addAutoLayoutSubviews(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }

    func pinEdges(to other: UIView, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

extension UILabel {
    convenience init(fontSize: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = Color.Grey200, lines: Int = 1) {
        self.init()
        font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        textColor = color
        numberOfLines = lines
    }
}
