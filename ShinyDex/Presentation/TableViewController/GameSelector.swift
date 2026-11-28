import UIKit

enum GameSelector {
	static func make(choices: [GameChoice] = Games.allCases.map { GameChoice(game: $0, availability: .catchable, isApproximate: false) }, selectedGame: Games?,
					 pokemonName: String? = nil, caption: String = "Hunting in", onSelect: @escaping (Games) -> Void) -> GridPickerVC {
		let items = choices.map(makeItem)
		let currentIndex = selectedGame.flatMap { selected in choices.firstIndex { $0.game == selected } }
		let legend = pokemonName.map {
			AvailabilityLegendView(pokemonName: $0, showsShinyLock: choices.contains { $0.availability == .shinyLocked }, showsApproximation: choices.contains { $0.isApproximate })
		}
		return GridPickerVC(title: "Game", caption: caption, items: items, columns: 3, currentIndex: currentIndex, legend: legend) { index in
			onSelect(choices[index].game)
		}
	}

	fileprivate static func makeItem(for choice: GameChoice) -> IconGridItem {
		let game = GamesList.games[choice.game]
		let title = game?.displayTitle ?? choice.game.displayName
		let availabilityText: String?
		switch choice.availability {
		case .catchable: availabilityText = choice.isApproximate ? "Catchable" : nil
		case .shinyLocked: availabilityText = "Shiny locked"
		case .tradeOnly: availabilityText = "Trade only"
		case .unavailable: availabilityText = "Not in game"
		}
		let detail = availabilityText.map { choice.isApproximate ? "≈ \($0)" : $0 }
		return IconGridItem(title: title, image: game.flatMap { PixelArt.makeCenteredImage(named: $0.coverPokemon) },
							accessibilityLabel: [title, availabilityText ?? "Catchable", choice.isApproximate ? "approximate" : nil].compactMap { $0 }.joined(separator: ", "),
							isDimmed: choice.availability != .catchable, detail: detail)
	}
}

final class AvailabilityLegendView: UIView {
	init(pokemonName: String, showsShinyLock: Bool, showsApproximation: Bool) {
		super.init(frame: .zero)
		backgroundColor = Color.surface
		layer.cornerRadius = CornerRadius.standard
		let rows = UIStackView(arrangedSubviews: [
			AvailabilityLegendView.makeRow(symbolName: "checkmark.circle.fill", tint: Color.accent, title: "Catchable",
										   detail: "Get \(pokemonName) in this game without trading"),
			AvailabilityLegendView.makeRow(symbolName: "arrow.left.arrow.right.circle.fill", tint: Color.textQuaternary, title: "Trade only",
										   detail: "Dimmed. Trade it in, or evolve it by trading"),
			AvailabilityLegendView.makeRow(symbolName: "eye.slash.fill", tint: Color.textQuaternary, title: "Not shown",
										   detail: "Games where \(pokemonName) can't exist")
		])
		if showsShinyLock {
			rows.insertArrangedSubview(AvailabilityLegendView.makeRow(symbolName: "lock.fill", tint: Color.danger, title: "Shiny locked",
																	  detail: "Dimmed. The only ways to get \(pokemonName) here can't be shiny"), at: 2)
		}
		if showsApproximation {
			rows.addArrangedSubview(AvailabilityLegendView.makeRow(symbolName: "questionmark.circle.fill", tint: Color.textQuaternary, title: "≈ Approximate",
																   detail: "The game data is incomplete, so double-check before hunting"))
		}
		rows.axis = .vertical
		rows.spacing = Spacing.small
		addAutoLayoutSubviews(rows)
		rows.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.medium, left: 14, bottom: Spacing.medium, right: 14))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate static func makeRow(symbolName: String, tint: UIColor, title: String, detail: String) -> UIView {
		let icon = UIImageView(image: UIImage.makeSymbol(symbolName, pointSize: 15, weight: .semibold))
		icon.tintColor = tint
		icon.contentMode = .center
		icon.widthAnchor.constraint(equalToConstant: 22).isActive = true
		let titleLabel = UILabel(style: .footnote, weight: .semibold)
		titleLabel.text = title
		titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
		let detailLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
		detailLabel.text = detail
		let row = UIStackView(arrangedSubviews: [icon, titleLabel, detailLabel])
		row.spacing = Spacing.small
		row.alignment = .firstBaseline
		row.isAccessibilityElement = true
		row.accessibilityLabel = "\(title): \(detail)"
		return row
	}
}
