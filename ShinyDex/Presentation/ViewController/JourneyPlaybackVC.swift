import UIKit

final class JourneyPlaybackVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let journeyId: JourneyID
    fileprivate var playback: JourneyPlayback
    fileprivate var game: Games
    fileprivate var scene: JourneyPlaybackView?
    fileprivate var hasAppeared = false
    fileprivate lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(sharePressed))
        button.accessibilityLabel = "Share image"
        return button
    }()
    fileprivate lazy var optionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: makeOptionsMenu())
        button.accessibilityLabel = "Playback options"
        return button
    }()

    init?(container: AppContainer, journeyId: JourneyID) {
        guard let playback = container.getJourneyPlayback.handle(GetJourneyPlaybackQuery(journeyId: journeyId)), let game = playback.games.first else { return nil }
        self.container = container
        self.journeyId = journeyId
        self.playback = playback
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.background
        title = "Playback"
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closePressed))
        closeButton.accessibilityLabel = "Close"
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItems = [optionsButton, shareButton]
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scenePressed)))
        buildScene()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared else { return }
        hasAppeared = true
        startScene()
    }

    fileprivate func buildScene() {
        scene?.removeFromSuperview()
        shareButton.isEnabled = false
        guard let playerSheet = OverworldSprites.makePlayerSheet(game: game, isFemale: playback.isPlayerFemale) else { return }
        let companions = playback.companions.compactMap { caught -> JourneyPlaybackView.Companion? in
            guard let sheet = OverworldSprites.makeCompanionSheet(number: caught.number, formId: caught.formId, gender: caught.gender) else { return nil }
            return JourneyPlaybackView.Companion(sheet: sheet, caption: [caught.speciesTitle, caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · "))
        }
        let shinyCount = companions.count == 1 ? "1 shiny" : "\(companions.count) shinies"
        let scene = JourneyPlaybackView(title: playback.journeyName, subtitle: "\(shinyCount) · \(game.displayName)", player: playerSheet, companions: companions)
        scene.onFinished = { [weak self] in
            self?.shareButton.isEnabled = true
        }
        view.addAutoLayoutSubviews(scene)
        NSLayoutConstraint.activate([
            scene.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scene.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scene.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scene.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        self.scene = scene
    }

    fileprivate func startScene() {
        if UIAccessibility.isReduceMotionEnabled {
            scene?.skipToEnd()
        } else {
            scene?.play()
        }
    }

    fileprivate func replay() {
        buildScene()
        startScene()
    }

    fileprivate func makeOptionsMenu() -> UIMenu {
        let replayAction = UIAction(title: "Replay", image: UIImage(systemName: "arrow.counterclockwise")) { [weak self] _ in self?.replay() }
        let playerMenu = UIMenu(title: "Player", options: .displayInline, children: [false, true].map { isFemale in
            UIAction(title: isFemale ? "Girl" : "Boy", state: playback.isPlayerFemale == isFemale ? .on : .off) { [weak self] _ in self?.choosePlayer(isFemale: isFemale) }
        })
        let gameMenu = UIMenu(title: "Game", options: .displayInline, children: playback.games.map { choice in
            UIAction(title: choice.displayName, state: choice == game ? .on : .off) { [weak self] _ in self?.chooseGame(choice) }
        })
        return UIMenu(children: [replayAction, playerMenu] + (playback.games.count > 1 ? [gameMenu] : []))
    }

    fileprivate func choosePlayer(isFemale: Bool) {
        container.choosePlaybackPlayer.handle(ChoosePlaybackPlayerCommand(isFemale: isFemale))
        if let updated = container.getJourneyPlayback.handle(GetJourneyPlaybackQuery(journeyId: journeyId)) {
            playback = updated
        }
        optionsButton.menu = makeOptionsMenu()
        replay()
    }

    fileprivate func chooseGame(_ choice: Games) {
        game = choice
        optionsButton.menu = makeOptionsMenu()
        replay()
    }

    @objc fileprivate func scenePressed() {
        scene?.skipToEnd()
    }

    @objc fileprivate func closePressed() {
        dismiss(animated: true)
    }

    @objc fileprivate func sharePressed() {
        guard let scene = scene else { return }
        let shareSheet = UIActivityViewController(activityItems: [scene.renderImage()], applicationActivities: nil)
        shareSheet.popoverPresentationController?.barButtonItem = shareButton
        present(shareSheet, animated: true)
    }
}
