import UIKit

class CatchDatePickerVC: UIViewController {
	fileprivate let datePicker = UIDatePicker()
	fileprivate let initialDate: Date
	fileprivate let onSave: (Date) -> Void

	init(initialDate: Date?, onSave: @escaping (Date) -> Void) {
		self.initialDate = initialDate ?? Date()
		self.onSave = onSave
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static func makeNavigationController(initialDate: Date?, onSave: @escaping (Date) -> Void) -> UINavigationController {
		let navigationController = UINavigationController(rootViewController: CatchDatePickerVC(initialDate: initialDate, onSave: onSave))
		navigationController.overrideUserInterfaceStyle = .dark
		return navigationController
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Caught date"
		view.backgroundColor = Color.Grey900
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
		navigationController?.navigationBar.tintColor = Color.Orange500

		datePicker.datePickerMode = .date
		if #available(iOS 14.0, *) {
			datePicker.preferredDatePickerStyle = .inline
		}
		datePicker.maximumDate = Date()
		datePicker.date = min(initialDate, Date())
		datePicker.tintColor = Color.Orange500
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(datePicker)
		NSLayoutConstraint.activate([
			datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
			datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
		])
	}

	@objc fileprivate func cancelPressed() {
		dismiss(animated: true)
	}

	@objc fileprivate func savePressed() {
		onSave(datePicker.date)
		dismiss(animated: true)
	}
}
