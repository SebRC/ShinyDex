import UIKit

extension UIViewController {
	func presentDestructiveConfirmation(title: String,
										message: String,
										destructiveTitle: String,
										onConfirm: @escaping () -> Void) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: destructiveTitle, style: .destructive) { _ in
			Haptics.playWarning()
			onConfirm()
		})
		alert.view.tintColor = Color.Orange500
		present(alert, animated: true)
	}

	func presentTextInput(title: String,
						  message: String? = nil,
						  text: String?,
						  placeholder: String,
						  saveTitle: String = "Save",
						  keyboardType: UIKeyboardType = .default,
						  isValid: @escaping (String) -> Bool = { !$0.isEmpty },
						  onSave: @escaping (String) -> Void) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let saveAction = UIAlertAction(title: saveTitle, style: .default) { [weak alert] _ in
			let value = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
			if (isValid(value)) {
				onSave(value)
			}
		}
		alert.addTextField { textField in
			textField.text = text
			textField.placeholder = placeholder
			textField.keyboardType = keyboardType
			textField.clearButtonMode = .whileEditing
			textField.autocapitalizationType = .words
			textField.returnKeyType = .done
			let validator = TextFieldValidator { [weak saveAction] text in
				saveAction?.isEnabled = isValid(text.trimmingCharacters(in: .whitespacesAndNewlines))
			}
			validator.attach(to: textField)
		}
		saveAction.isEnabled = isValid(text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(saveAction)
		alert.preferredAction = saveAction
		alert.view.tintColor = Color.Orange500
		present(alert, animated: true)
	}
}

fileprivate class TextFieldValidator: NSObject {
	fileprivate static var associationKey = 0
	fileprivate let onChange: (String) -> Void

	init(onChange: @escaping (String) -> Void) {
		self.onChange = onChange
	}

	func attach(to textField: UITextField) {
		textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
		objc_setAssociatedObject(textField, &TextFieldValidator.associationKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}

	@objc fileprivate func textChanged(_ textField: UITextField) {
		onChange(textField.text ?? "")
	}
}

extension UIButton {
	func applyCancelStyle() {
		backgroundColor = Color.Grey700
		setTitleColor(Color.Grey200, for: .normal)
	}
}
