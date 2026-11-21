import UIKit
import UniformTypeIdentifiers

class GameSettingsHostVC: UIViewController {
    let scrollView = UIScrollView()
    let gameSettingsContainer = GameSettingsContainer()
    let contentStack = UIStackView()
    let popupHandler = PopupHandler()
    let container: AppContainer
    fileprivate let pokemonNumber: Int?
    fileprivate let chain: Int

    init(container: AppContainer, pokemon: PokemonDetails?) {
        self.container = container
        pokemonNumber = pokemon?.number
        chain = pokemon?.chain ?? 0
        gameSettingsContainer.settings = pokemon?.settings ?? HuntSettings(game: .Red, generation: 1, huntMethod: .Encounters, isShinyCharmActive: false)
        gameSettingsContainer.pokemonName = pokemon?.name
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.background
        navigationItem.largeTitleDisplayMode = .never

        gameSettingsContainer.preview = { [container, chain] settings in
            container.previewHuntSettings.handle(PreviewHuntSettingsQuery(settings: settings, chain: chain))
        }
        gameSettingsContainer.onSettingsChanged = { [weak self] settings in
            self?.save(settings)
        }
        gameSettingsContainer.setShinyOddsLabelText()
        gameSettingsContainer.resolveUIObjectsState()
        gameSettingsContainer.setExplanationLabelText()
        gameSettingsContainer.setGame(coverPokemon: GamesList.games[gameSettingsContainer.settings.game]?.coverPokemon ?? "charizard")
        gameSettingsContainer.onApplyToAll = { [weak self] in self?.confirmApplyToAll() }
        gameSettingsContainer.gameButton.addTarget(self, action: #selector(gameButtonPressed), for: .touchUpInside)

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.addArrangedSubview(gameSettingsContainer)
        view.addAutoLayoutSubviews(scrollView)
        scrollView.addAutoLayoutSubviews(contentStack)
        scrollView.pinEdges(to: view)
        let content = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: 8),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12)
        ])
    }

    fileprivate func save(_ settings: HuntSettings) {
        guard let number = pokemonNumber else { return }
        container.saveHuntSettings.handle(SaveHuntSettingsCommand(number: number, settings: settings))
    }

    @objc fileprivate func gameButtonPressed() {
        let selector = GameSelector.make(selectedGame: gameSettingsContainer.settings.game) { [weak self] game in
            guard let self = self else { return }
            let preview = self.container.previewHuntSettings.handle(PreviewHuntSettingsQuery(settings: self.gameSettingsContainer.settings, chain: self.chain, selectingGame: game))
            self.save(preview.settings)
            self.gameSettingsContainer.updateUI(updatedSettings: preview.settings, coverPokemon: GamesList.games[game]?.coverPokemon ?? "charizard")
        }
        navigationController?.pushViewController(selector, animated: true)
    }

    fileprivate func confirmApplyToAll() {
        let settings = gameSettingsContainer.settings!
        presentDestructiveConfirmation(title: "Apply to all Pokémon?",
                                       message: "Every Pokémon will use \(settings.game.displayName) and these hunt settings. Their current settings will be replaced.",
                                       destructiveTitle: "Apply to All") { [weak self] in
            guard let self = self else { return }
            self.container.applyHuntSettingsToAll.handle(ApplyHuntSettingsToAllCommand(settings: self.gameSettingsContainer.settings))
            self.popupHandler.showPopup(text: "Game Settings have been applied to all Pokémon.")
        }
    }
}

class SettingsVC: GameSettingsHostVC {
    fileprivate let backupSettingsView = BackupSettingsView()
    fileprivate var backupFolderPicker: UIDocumentPickerViewController?

    init(container: AppContainer) {
        super.init(container: container, pokemon: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        contentStack.insertArrangedSubview(SettingsVC.makeGroupTitle("Hunt defaults"), at: 0)
        contentStack.addArrangedSubview(SettingsVC.makeGroupTitle("Backup & data"))
        contentStack.addArrangedSubview(backupSettingsView)
        backupSettingsView.exportRow.addTarget(self, action: #selector(exportPressed), for: .touchUpInside)
        backupSettingsView.restoreRow.addTarget(self, action: #selector(restorePressed), for: .touchUpInside)
        backupSettingsView.automaticRow.addTarget(self, action: #selector(automaticBackupsPressed), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAutomaticBackupStatus()
    }

    fileprivate static func makeGroupTitle(_ title: String) -> UIView {
        let label = UILabel(style: .title3, weight: .bold)
        label.text = title
        label.accessibilityTraits = .header
        let wrapper = UIView()
        wrapper.addAutoLayoutSubviews(label)
        label.pinEdges(to: wrapper, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.small, bottom: 0, right: Spacing.small))
        return wrapper
    }

    // MARK: Automatic backups

    fileprivate func updateAutomaticBackupStatus() {
        let status = container.getAutomaticBackupStatus.handle(GetAutomaticBackupStatusQuery())
        guard let folderName = status.folderName else {
            backupSettingsView.automaticRow.setDescription("Off. Choose a folder, like one in iCloud Drive, for a weekly backup")
            return
        }
        if status.lastBackupFailed {
            backupSettingsView.automaticRow.setDescription("Couldn't save to \u{201C}\(folderName)\u{201D}. Tap to choose the folder again", isWarning: true)
            return
        }
        let lastBackup = status.lastBackupDate.map { " · Last backup \(SettingsVC.formatRelativeDay($0))" } ?? ""
        backupSettingsView.automaticRow.setDescription("Weekly to \u{201C}\(folderName)\u{201D}\(lastBackup)")
    }

    fileprivate static func formatRelativeDay(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "today" }
        if calendar.isDateInYesterday(date) { return "yesterday" }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: Date())).day ?? 0
        return "\(days) days ago"
    }

    @objc fileprivate func automaticBackupsPressed() {
        let status = container.getAutomaticBackupStatus.handle(GetAutomaticBackupStatusQuery())
        guard status.isOn, !status.lastBackupFailed else {
            chooseBackupFolder()
            return
        }
        let sheet = UIAlertController(title: "Automatic backups", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Back Up Now", style: .default) { [weak self] _ in self?.backUpNow() })
        sheet.addAction(UIAlertAction(title: "Change Folder", style: .default) { [weak self] _ in self?.chooseBackupFolder() })
        sheet.addAction(UIAlertAction(title: "Turn Off", style: .destructive) { [weak self] _ in
            self?.container.turnOffAutomaticBackups.handle(TurnOffAutomaticBackupsCommand())
            self?.updateAutomaticBackupStatus()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.view.tintColor = Color.accent
        sheet.popoverPresentationController?.sourceView = backupSettingsView.automaticRow
        sheet.popoverPresentationController?.sourceRect = backupSettingsView.automaticRow.bounds
        present(sheet, animated: true)
    }

    fileprivate func chooseBackupFolder() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        backupFolderPicker = picker
        present(picker, animated: true)
    }

    fileprivate func useBackupFolder(_ folderURL: URL) {
        do {
            try container.chooseBackupFolder.handle(ChooseBackupFolderCommand(folderURL: folderURL))
            backUpNow()
        }
        catch {
            presentBackupError(title: "Couldn't use that folder", message: "ShinyDex wasn't given access to the folder. Please choose another one.")
        }
    }

    fileprivate func backUpNow() {
        let outcome = container.runAutomaticBackup.handle(RunAutomaticBackupCommand(isForced: true))
        updateAutomaticBackupStatus()
        if outcome == .backedUp {
            Haptics.playSuccess()
            popupHandler.showPopup(text: "Backup saved.")
        }
        else {
            presentBackupError(title: "Couldn't save backup", message: "The backup folder couldn't be reached. Try choosing it again.")
        }
    }

    // MARK: Backup

    @objc fileprivate func exportPressed() {
        do {
            let backupFile = try container.exportBackup.handle(ExportBackupQuery())
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(backupFile.fileName)
            try backupFile.data.write(to: fileURL, options: .atomic)
            let shareSheet = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            shareSheet.popoverPresentationController?.sourceView = backupSettingsView.exportRow
            shareSheet.popoverPresentationController?.sourceRect = backupSettingsView.exportRow.bounds
            present(shareSheet, animated: true)
        }
        catch {
            presentBackupError(title: "Couldn't export backup", message: "The backup file could not be created. Please try again.")
        }
    }

    @objc fileprivate func restorePressed() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json], asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    fileprivate func confirmRestore(from fileURL: URL) {
        let data: Data
        let summary: BackupSummary
        do {
            data = try Data(contentsOf: fileURL)
            summary = try container.getBackupSummary.handle(GetBackupSummaryQuery(data: data))
        }
        catch BackupFileError.newerFormat {
            presentBackupError(title: "Backup is too new", message: "This backup was made with a newer version of ShinyDex. Update the app to restore it.")
            return
        }
        catch {
            presentBackupError(title: "Couldn't read backup", message: "The file isn't a ShinyDex backup or is damaged. Nothing was changed.")
            return
        }
        presentDestructiveConfirmation(title: "Restore backup?",
                                       message: SettingsVC.makeRestoreMessage(for: summary),
                                       destructiveTitle: "Replace All Data") { [weak self] in
            self?.restore(from: data)
        }
    }

    fileprivate func restore(from data: Data) {
        do {
            try container.restoreBackup.handle(RestoreBackupCommand(data: data))
            Haptics.playSuccess()
            popupHandler.showPopup(text: "Backup restored.")
        }
        catch {
            presentBackupError(title: "Couldn't restore backup", message: "Your current data has been kept unchanged.")
        }
    }

    fileprivate func presentBackupError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.view.tintColor = Color.accent
        present(alert, animated: true)
    }

    fileprivate static func makeRestoreMessage(for summary: BackupSummary) -> String {
        let createdDate = DateFormatter.localizedString(from: summary.createdDate, dateStyle: .medium, timeStyle: .short)
        let contents = [
            makeCountText(summary.catchCount, singular: "shiny", plural: "shinies"),
            makeCountText(summary.huntCount, singular: "hunt", plural: "hunts"),
            makeCountText(summary.journeyCount, singular: "journey", plural: "journeys"),
            makeCountText(summary.bingoBoardCount, singular: "bingo board", plural: "bingo boards")
        ].joined(separator: ", ")
        return "Backup from \(createdDate) with \(contents).\n\nAll current catches, hunts, journeys, bingo boards and hunt settings will be replaced. This can't be undone."
    }

    fileprivate static func makeCountText(_ count: Int, singular: String, plural: String) -> String {
        return "\(count.grouped) \(count == 1 ? singular : plural)"
    }
}

extension SettingsVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        if controller === backupFolderPicker {
            backupFolderPicker = nil
            useBackupFolder(url)
            return
        }
        confirmRestore(from: url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if controller === backupFolderPicker {
            backupFolderPicker = nil
        }
    }
}
