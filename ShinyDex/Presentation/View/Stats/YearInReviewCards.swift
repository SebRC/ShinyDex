import UIKit

struct YearInReviewCards {
    let review: YearInReview
    let currentYear: Int

    fileprivate var isCurrentYear: Bool {
        return review.year == currentYear
    }

    func makeContents() -> [YearInReviewCardView.Content] {
        return [
            makeIntro(),
            makeEncounters(),
            makeGoal(),
            review.firstShiny.map { makeShiny($0, title: "First shiny of \(review.year)") },
            review.latestShiny.map { makeShiny($0, title: isCurrentYear ? "Latest shiny" : "Last shiny of \(review.year)") },
            review.luckiestHunt.map(makeLuckiestHunt),
            review.unluckiestHunt.map(makeUnluckiestHunt),
            makeFullOddsLuck(),
            makeBestMonth(),
            makeTopBalls(),
            makeFavourites()
        ].compactMap { $0 }
    }

    fileprivate func makeIntro() -> YearInReviewCardView.Content {
        var details = ["\(review.caughtSpeciesCount.grouped) species caught"]
        if review.failedCount > 0 {
            details.append("\(review.failedCount.grouped) got away")
        }
        return YearInReviewCardView.Content(eyebrow: "Your \(review.year)",
                                            image: UIImage.makeSymbol("sparkles", pointSize: 72, weight: .semibold),
                                            isPixelArt: false,
                                            headline: review.foundCount.grouped,
                                            title: review.foundCount == 1 ? "shiny found" : "shinies found",
                                            message: review.foundCount == 0 ? "No shinies yet this year. The next one could be one encounter away." : details.joined(separator: " · "))
    }

    fileprivate func makeEncounters() -> YearInReviewCardView.Content? {
        guard let encounters = review.trackedEncounters, encounters > 0 else { return nil }
        var lines = [String]()
        if let month = review.busiestMonth {
            lines.append("Busiest month: \(YearInReviewCards.formatMonth(month.month)) with \(month.count.grouped).")
        }
        if let day = review.busiestDay {
            lines.append("Busiest day: \(YearInReviewCards.format(day.date, template: "EEE d MMM")) with \(day.encounters.grouped).")
        }
        if let trackedSince = review.encountersTrackedSince {
            lines.append("Counted since \(YearInReviewCards.format(trackedSince, template: "d MMMM")).")
        }
        return YearInReviewCardView.Content(eyebrow: "Encounters",
                                            image: UIImage.makeSymbol("hare.fill", pointSize: 64, weight: .semibold),
                                            isPixelArt: false,
                                            headline: encounters.grouped,
                                            title: "encounters across all hunts",
                                            message: lines.joined(separator: "\n"))
    }

    fileprivate func makeGoal() -> YearInReviewCardView.Content? {
        guard let goal = review.goal else { return nil }
        let remaining = goal.target - goal.foundCount
        let message: String
        if goal.isReached {
            message = goal.foundCount > goal.target
                ? "You set out to find \(goal.target.grouped) and beat it by \((goal.foundCount - goal.target).grouped)."
                : "You set out to find \(goal.target.grouped) and hit it exactly."
        } else {
            message = isCurrentYear
                ? "\(remaining.grouped) to go before the year is over."
                : "\(remaining.grouped) short of the goal of \(goal.target.grouped)."
        }
        return YearInReviewCardView.Content(eyebrow: "Yearly goal",
                                            image: UIImage.makeSymbol(goal.isReached ? "trophy.fill" : "flag.fill", pointSize: 64, weight: .semibold),
                                            isPixelArt: false,
                                            headline: "\(goal.foundCount.grouped)/\(goal.target.grouped)",
                                            title: goal.isReached ? "Goal reached!" : "Goal progress",
                                            message: message)
    }

    fileprivate func makeShiny(_ caught: CatchSummary, title: String) -> YearInReviewCardView.Content {
        var details = [String]()
        if let date = caught.caughtDate {
            details.append("Found \(YearInReviewCards.format(date, template: "d MMMM"))")
        }
        if caught.encounters > 0 {
            details.append("after \(caught.encounters.grouped) \(caught.encounters == 1 ? "encounter" : "encounters")")
        }
        details.append("in \(caught.game.displayName)")
        return YearInReviewCardView.Content(eyebrow: title,
                                            image: caught.spriteImage,
                                            headline: caught.speciesTitle,
                                            title: caught.isFailed ? "Got away" : "\(BallGrid.getDisplayName(of: caught.caughtBall)) Ball",
                                            message: details.joined(separator: " "))
    }

    fileprivate func makeLuckiestHunt(_ hunt: YearInReview.Hunt) -> YearInReviewCardView.Content {
        return YearInReviewCardView.Content(eyebrow: "Luckiest hunt",
                                            image: hunt.caught.spriteImage,
                                            headline: hunt.caught.encounters.grouped,
                                            title: "encounters for \(hunt.caught.speciesTitle)",
                                            message: "Only \(YearInReviewCards.formatPercent(hunt.percentChanceOfFindingSooner)) of hunts at those odds end this quickly.")
    }

    fileprivate func makeUnluckiestHunt(_ hunt: YearInReview.Hunt) -> YearInReviewCardView.Content {
        return YearInReviewCardView.Content(eyebrow: "Toughest hunt",
                                            image: hunt.caught.spriteImage,
                                            headline: hunt.caught.encounters.grouped,
                                            title: "encounters for \(hunt.caught.speciesTitle)",
                                            message: "\(YearInReviewCards.formatPercent(hunt.percentChanceOfFindingSooner)) of hunts at those odds end sooner. You kept going anyway.")
    }

    fileprivate func makeFullOddsLuck() -> YearInReviewCardView.Content? {
        guard let luck = review.fullOddsLuck, luck.expectedShinies > 0 else { return nil }
        let expected = String(format: "%.1f", luck.expectedShinies)
        let verdict = Double(luck.foundCount) >= luck.expectedShinies ? "Luck was on your side." : "The odds owe you one."
        return YearInReviewCardView.Content(eyebrow: "Full odds luck",
                                            image: UIImage.makeSymbol("dice.fill", pointSize: 64, weight: .semibold),
                                            isPixelArt: false,
                                            headline: "\(luck.foundCount.grouped) vs \(expected)",
                                            title: "found vs expected at full odds",
                                            message: verdict)
    }

    fileprivate func makeBestMonth() -> YearInReviewCardView.Content? {
        guard let month = review.bestMonthForShinies, month.count > 1 else { return nil }
        return YearInReviewCardView.Content(eyebrow: "Best month for shinies",
                                            image: UIImage.makeSymbol("calendar", pointSize: 64, weight: .semibold),
                                            isPixelArt: false,
                                            headline: YearInReviewCards.formatMonth(month.month),
                                            title: "\(month.count.grouped) shinies found",
                                            message: nil)
    }

    fileprivate func makeFavourites() -> YearInReviewCardView.Content? {
        var rows = [YearInReviewCardView.Row]()
        if let game = review.favouriteGame {
            rows.append(YearInReviewCardView.Row(title: "Game", value: "\(game.key.displayName) · \(game.count.grouped)"))
        }
        if let method = review.favouriteMethod {
            rows.append(YearInReviewCardView.Row(title: "Method", value: "\(method.key.rawValue) · \(method.count.grouped)"))
        }
        guard !rows.isEmpty else { return nil }
        return YearInReviewCardView.Content(eyebrow: "Favourites",
                                            image: review.favouriteGame.flatMap { GamesList.games[$0.key] }.flatMap { PixelArt.makeCenteredImage(named: $0.coverPokemon) },
                                            headline: "\(review.year)",
                                            title: "Your go-to picks",
                                            message: nil,
                                            rows: rows)
    }

    fileprivate func makeTopBalls() -> YearInReviewCardView.Content? {
        guard let topBall = review.topBalls.first else { return nil }
        let rows = review.topBalls.enumerated().map { index, ball in
            YearInReviewCardView.Row(image: UIImage(named: ball.key),
                                     title: "\(index + 1). \(BallGrid.getDisplayName(of: ball.key)) Ball",
                                     value: ball.count == 1 ? "1 catch" : "\(ball.count.grouped) catches")
        }
        return YearInReviewCardView.Content(eyebrow: review.topBalls.count == 1 ? "Top Poké Ball" : "Top \(review.topBalls.count) Poké Balls",
                                            podiumImages: review.topBalls.compactMap { UIImage(named: $0.key) },
                                            headline: "\(BallGrid.getDisplayName(of: topBall.key)) Ball",
                                            title: "your most used ball",
                                            message: nil,
                                            rows: rows)
    }

    fileprivate static func formatPercent(_ percent: Double) -> String {
        return percent < 1 || percent > 99 ? String(format: "%.1f%%", percent) : "\(Int(percent.rounded()))%"
    }

    fileprivate static func formatMonth(_ month: Int) -> String {
        return DateFormatter().standaloneMonthSymbols[month - 1]
    }

    fileprivate static func format(_ date: Date, template: String) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }
}
