import Foundation

struct Evolutions {
    let evolvesFrom: [Int]

    init(evolvesFrom: [Int]) {
        self.evolvesFrom = evolvesFrom
    }

    func getParent(of number: Int) -> Int? {
        guard evolvesFrom.indices.contains(number), evolvesFrom[number] >= 0 else { return nil }
        return evolvesFrom[number]
    }

    func getRoot(of number: Int) -> Int {
        var current = number
        var seen = Set<Int>()
        while let parent = getParent(of: current), !seen.contains(parent) {
            seen.insert(current)
            current = parent
        }
        return current
    }

    func getStage(of number: Int) -> Int {
        var stage = 0
        var current = number
        while let parent = getParent(of: current), stage < 10 {
            stage += 1
            current = parent
        }
        return stage
    }

    func getLine(of number: Int) -> [Int] {
        let root = self.getRoot(of: number)
        let members = evolvesFrom.indices.filter { $0 == root || self.getRoot(of: $0) == root }
        return members.sorted { getStage(of: $0) != getStage(of: $1) ? getStage(of: $0) < getStage(of: $1) : $0 < $1 }
    }

    func getEvolutionTargets(of number: Int) -> [Int] {
        return getLine(of: number).filter { $0 != number }
    }
}
