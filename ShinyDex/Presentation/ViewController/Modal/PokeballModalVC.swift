import UIKit

enum PokeballPickerResult {
    case loggedCatch
    case loggedFailed
    case removedLatestCatch
    case nothingToRemove
}

class PokeballModalVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let number: Int
    fileprivate let pokemonName: String
    fileprivate let onFinish: (PokeballPickerResult) -> Void
    fileprivate lazy var ballGrid = BallGrid(container: container)
    fileprivate var hasCatches = false
    fileprivate var caughtBall: String?
    fileprivate var caughtDate = Date()

    fileprivate let summaryView = UIView()
    fileprivate let datePicker = UIDatePicker()
    fileprivate let dateButton = UIButton(type: .system)
    fileprivate let gridView = IconGridView(columns: 4)
    fileprivate let outcomeControl = UISegmentedControl(items: ["Caught", "Got away"])
    fileprivate let failedView = UIView()
    fileprivate let dateCaptionLabel = UILabel(fontSize: 15, color: Color.Grey400)

    init(container: AppContainer, number: Int, pokemonName: String, onFinish: @escaping (PokeballPickerResult) -> Void) {
        self.container = container
        self.number = number
        self.pokemonName = pokemonName
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let details = container.getPokemonDetails.handle(GetPokemonDetailsQuery(number: number))
        hasCatches = (details?.catchCount ?? 0) > 0
        caughtBall = details?.caughtBall
        view.backgroundColor = Color.Grey900
        title = "Log a catch"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        setUpSummaryView()
        setUpGridView()
        setUpOutcomeControl()
        setUpFailedView()

        view.addAutoLayoutSubviews(summaryView, outcomeControl, gridView, failedView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            summaryView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12),
            summaryView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            summaryView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            outcomeControl.topAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: 12),
            outcomeControl.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor),
            outcomeControl.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor),
            outcomeControl.heightAnchor.constraint(equalToConstant: 34),
            failedView.topAnchor.constraint(equalTo: outcomeControl.bottomAnchor, constant: 16),
            failedView.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor),
            failedView.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor),
            gridView.topAnchor.constraint(equalTo: outcomeControl.bottomAnchor, constant: 4),
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Summary

    fileprivate func setUpSummaryView() {
        summaryView.backgroundColor = Color.Grey800
        summaryView.layer.cornerRadius = CornerRadius.standard

        let spriteView = UIImageView(image: UIImage(named: pokemonName.lowercased()))
        spriteView.contentMode = .scaleAspectFit
        spriteView.layer.magnificationFilter = .nearest
        spriteView.isAccessibilityElement = false
        let nameLabel = UILabel(fontSize: 20, weight: .semibold)
        nameLabel.text = pokemonName
        dateCaptionLabel.text = "Date caught"

        let labels = UIStackView(arrangedSubviews: [nameLabel, dateCaptionLabel])
        labels.axis = .vertical
        labels.spacing = 2

        let dateControl: UIView
        if #available(iOS 14.0, *) {
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .compact
            datePicker.maximumDate = Date()
            datePicker.date = caughtDate
            datePicker.tintColor = Color.Orange500
            datePicker.accessibilityLabel = "Date caught"
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            dateControl = datePicker
        }
        else {
            dateButton.tintColor = Color.Orange500
            dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            dateButton.addTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
            updateDateButton()
            dateControl = dateButton
        }
        dateControl.setContentHuggingPriority(.required, for: .horizontal)
        dateControl.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [spriteView, labels, dateControl])
        row.alignment = .center
        row.spacing = 12
        summaryView.addAutoLayoutSubviews(row)
        row.pinEdges(to: summaryView, insets: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 12))
        NSLayoutConstraint.activate([
            spriteView.widthAnchor.constraint(equalToConstant: 64),
            spriteView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    @objc fileprivate func dateChanged() {
        caughtDate = datePicker.date
    }

    fileprivate func updateDateButton() {
        let title = Calendar.current.isDateInToday(caughtDate) ? "Today" : DateFormatter.localizedString(from: caughtDate, dateStyle: .medium, timeStyle: .none)
        dateButton.setTitle(title, for: .normal)
    }

    @objc fileprivate func dateButtonPressed() {
        present(CatchDatePickerVC.makeNavigationController(initialDate: caughtDate) { [weak self] date in
            self?.caughtDate = date
            self?.updateDateButton()
        }, animated: true)
    }

    // MARK: Grid

    fileprivate func setUpGridView() {
        gridView.caption = "WHICH BALL?"
        gridView.items = ballGrid.items
        gridView.currentIndex = hasCatches ? ballGrid.findIndex(of: caughtBall) : nil
        if (hasCatches) {
            gridView.actions = [IconGridAction(title: "Remove latest catch", symbol: "arrow.uturn.left", isDestructive: true)]
        }
        gridView.onSelect = { [weak self] index in
            guard let self = self else { return }
            self.container.logCatch.handle(LogCatchCommand(number: self.number, outcome: .caught(ball: self.ballGrid.ballNames[index]), date: self.caughtDate))
            Haptics.playSuccess()
            self.finish(.loggedCatch)
        }
        gridView.onAction = { [weak self] _ in
            guard let self = self else { return }
            self.finish(self.container.removeLatestCatch.handle(RemoveLatestCatchCommand(number: self.number)) ? .removedLatestCatch : .nothingToRemove)
        }
    }

    // MARK: Got away

    fileprivate func setUpOutcomeControl() {
        outcomeControl.selectedSegmentIndex = 0
        outcomeControl.selectedSegmentTintColor = Color.Orange500
        outcomeControl.backgroundColor = Color.Grey800
        outcomeControl.setTitleTextAttributes([.foregroundColor: Color.Grey900, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
        outcomeControl.setTitleTextAttributes([.foregroundColor: Color.Grey300, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], for: .normal)
        outcomeControl.addTarget(self, action: #selector(outcomeChanged), for: .valueChanged)
    }

    fileprivate func setUpFailedView() {
        failedView.isHidden = true
        let icon = UIImageView(image: UIImage.makeSymbol("wind", pointSize: 34, weight: .medium))
        icon.tintColor = Color.Grey400
        icon.contentMode = .center
        let explanation = UILabel(fontSize: 15, color: Color.Grey300, lines: 0)
        explanation.textAlignment = .center
        explanation.text = "For a shiny that fled or fainted before you could catch it. It counts towards your stats, but not your collection or Pokédex."
        let logButton = UIButton(type: .system)
        logButton.setTitle("Log as got away", for: .normal)
        logButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        logButton.setTitleColor(Color.Grey900, for: .normal)
        logButton.backgroundColor = Color.Orange500
        logButton.layer.cornerRadius = CornerRadius.standard
        logButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logButton.addTarget(self, action: #selector(logFailedPressed), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [icon, explanation, logButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(24, after: explanation)
        failedView.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: failedView)
    }

    @objc fileprivate func outcomeChanged() {
        let isFailed = outcomeControl.selectedSegmentIndex == 1
        gridView.isHidden = isFailed
        failedView.isHidden = !isFailed
        dateCaptionLabel.text = isFailed ? "Date found" : "Date caught"
        Haptics.tap()
    }

    @objc fileprivate func logFailedPressed() {
        container.logCatch.handle(LogCatchCommand(number: number, outcome: .gotAway, date: caughtDate))
        Haptics.tap()
        finish(.loggedFailed)
    }

    fileprivate func finish(_ result: PokeballPickerResult) {
        dismissSheet { [onFinish] in
            onFinish(result)
        }
    }

    @objc fileprivate func cancelPressed() {
        dismissSheet()
    }
}
