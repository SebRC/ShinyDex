import XCTest
@testable import ShinyDex

final class AutomaticBackupTests: XCTestCase {
    private var folder: InMemoryBackupFolder!
    private var keyValueStore: InMemoryKeyValueStore!
    private var now: Date!
    private let folderURL = URL(fileURLWithPath: "/Backups/ShinyDex Backups", isDirectory: true)

    override func setUp() {
        folder = InMemoryBackupFolder()
        keyValueStore = InMemoryKeyValueStore()
        now = makeDate(day: 21)
    }

    private func makeDate(day: Int, hour: Int = 12) -> Date {
        return DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "UTC"), year: 2026, month: 11, day: day, hour: hour).date!
    }

    private func runBackup(isForced: Bool = false) -> AutomaticBackupOutcome {
        let export = ExportBackupHandler(pokemonRepository: InMemoryPokemonRepository(names: ["Bulbasaur"]), catchRepository: InMemoryCatchRepository(),
                                         huntRepository: InMemoryHuntRepository(), journeyRepository: InMemoryJourneyRepository(),
                                         bingoBoardRepository: InMemoryBingoBoardRepository(), moveRepository: InMemoryMoveRepository(),
                                         ledgerRepository: InMemoryEncounterLedgerRepository(), yearlyGoalRepository: InMemoryYearlyGoalRepository(),
                                         dailyEncountersRepository: InMemoryDailyEncountersRepository(), teamRepository: InMemoryTeamRepository(), makeCurrentDate: { self.now })
        return RunAutomaticBackupHandler(exportBackup: export, backupFolder: folder, keyValueStore: keyValueStore, makeCurrentDate: { self.now })
            .handle(RunAutomaticBackupCommand(isForced: isForced))
    }

    private func chooseFolder() throws {
        try ChooseBackupFolderHandler(backupFolder: folder, keyValueStore: keyValueStore).handle(ChooseBackupFolderCommand(folderURL: folderURL))
    }

    private func getStatus() -> AutomaticBackupStatus {
        return GetAutomaticBackupStatusHandler(backupFolder: folder, keyValueStore: keyValueStore).handle(GetAutomaticBackupStatusQuery())
    }

    func test_withoutAFolder_nothingIsBackedUp() {
        XCTAssertEqual(runBackup(), .notSetUp)
        XCTAssertFalse(getStatus().isOn)
    }

    func test_choosingAFolder_backsUpOnTheNextRun_andRecordsWhen() throws {
        try chooseFolder()

        XCTAssertEqual(runBackup(), .backedUp)
        XCTAssertEqual(Array(folder.files.keys), ["ShinyDex Backup 2026-11-21.json"])
        XCTAssertEqual(getStatus(), AutomaticBackupStatus(folderName: "ShinyDex Backups", lastBackupDate: now, lastBackupFailed: false))
    }

    func test_backups_runOnlyOnceAWeek_unlessForced() throws {
        try chooseFolder()
        XCTAssertEqual(runBackup(), .backedUp)

        now = makeDate(day: 28, hour: 11)
        XCTAssertEqual(runBackup(), .notDue)
        XCTAssertEqual(runBackup(isForced: true), .backedUp)

        now = makeDate(day: 28, hour: 11).addingTimeInterval(RunAutomaticBackupHandler.interval)
        XCTAssertEqual(runBackup(), .backedUp)
    }

    func test_onlyTheNewestFiveBackups_areKept_andOtherFilesAreLeftAlone() throws {
        try chooseFolder()
        for day in 1...6 {
            folder.addFile(named: String(format: "ShinyDex Backup 2026-10-%02d.json", day))
        }
        folder.addFile(named: "Notes.txt")

        XCTAssertEqual(runBackup(), .backedUp)

        XCTAssertEqual(folder.files.keys.sorted(), [
            "Notes.txt",
            "ShinyDex Backup 2026-10-03.json",
            "ShinyDex Backup 2026-10-04.json",
            "ShinyDex Backup 2026-10-05.json",
            "ShinyDex Backup 2026-10-06.json",
            "ShinyDex Backup 2026-11-21.json"
        ])
    }

    func test_aFailedBackup_isReported_andRetriedOnTheNextRun() throws {
        try chooseFolder()
        folder.failsToWrite = true

        XCTAssertEqual(runBackup(), .failed)
        XCTAssertTrue(getStatus().lastBackupFailed)
        XCTAssertNil(getStatus().lastBackupDate)

        folder.failsToWrite = false
        XCTAssertEqual(runBackup(), .backedUp)
        XCTAssertFalse(getStatus().lastBackupFailed)
    }

    func test_choosingAnotherFolder_clearsAFailure_andBacksUpAgainRightAway() throws {
        try chooseFolder()
        XCTAssertEqual(runBackup(), .backedUp)
        keyValueStore.set(true, forKey: AutomaticBackupKeys.lastBackupFailed)

        try chooseFolder()

        XCTAssertFalse(getStatus().lastBackupFailed)
        XCTAssertEqual(runBackup(), .backedUp)
    }

    func test_turningOff_forgetsTheFolderAndHistory() throws {
        try chooseFolder()
        XCTAssertEqual(runBackup(), .backedUp)

        TurnOffAutomaticBackupsHandler(backupFolder: folder, keyValueStore: keyValueStore).handle(TurnOffAutomaticBackupsCommand())

        XCTAssertEqual(getStatus(), AutomaticBackupStatus(folderName: nil, lastBackupDate: nil, lastBackupFailed: false))
        XCTAssertEqual(runBackup(), .notSetUp)
    }

    func test_bookmarkedFolder_writesListsAndDeletesFiles_inARealFolder() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let suiteName = "AutomaticBackupTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let bookmarkedFolder = BookmarkedBackupFolder(userDefaults: userDefaults)

        XCTAssertNil(bookmarkedFolder.name)
        XCTAssertThrowsError(try bookmarkedFolder.write(BackupFile(fileName: "a.json", data: Data())))

        try bookmarkedFolder.choose(directory)
        try bookmarkedFolder.write(BackupFile(fileName: "ShinyDex Backup 2026-11-21.json", data: Data("{}".utf8)))

        XCTAssertEqual(bookmarkedFolder.name, directory.lastPathComponent)
        XCTAssertEqual(try bookmarkedFolder.listFileNames(), ["ShinyDex Backup 2026-11-21.json"])
        XCTAssertEqual(try Data(contentsOf: directory.appendingPathComponent("ShinyDex Backup 2026-11-21.json")), Data("{}".utf8))

        try bookmarkedFolder.deleteFile(named: "ShinyDex Backup 2026-11-21.json")
        XCTAssertEqual(try bookmarkedFolder.listFileNames(), [])

        bookmarkedFolder.forget()
        XCTAssertNil(bookmarkedFolder.name)
    }
}
