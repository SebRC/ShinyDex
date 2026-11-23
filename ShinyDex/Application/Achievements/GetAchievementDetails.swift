import Foundation

struct GetAchievementDetailsQuery {
    let kind: AchievementKind
}

struct AchievementDetails: Equatable {
    let achievement: Achievement
    let catches: [CatchSummary]
}

final class GetAchievementDetailsHandler {
    private let getAchievements: GetAchievementsHandler
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let forms: PokemonForms
    private let genders: PokemonGenders

    init(getAchievements: GetAchievementsHandler, catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(),
         genders: PokemonGenders = PokemonGenders()) {
        self.getAchievements = getAchievements
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.forms = forms
        self.genders = genders
    }

    func handle(_ query: GetAchievementDetailsQuery) -> AchievementDetails? {
        guard let achievement = getAchievements.handle(GetAchievementsQuery()).achievements.first(where: { $0.kind == query.kind }) else { return nil }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms, genders: genders)
        let catches = achievement.catchIds.compactMap(catchRepository.get(id:)).compactMap(mapper.makeSummary)
        return AchievementDetails(achievement: achievement, catches: catches)
    }
}
