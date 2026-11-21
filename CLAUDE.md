# ShinyDex

## Workflow

- Always start new work from an up-to-date `master` (`git checkout master && git pull`) and branch from there, unless told otherwise.
- Name branches after the Trello task as `<task id>-<task name>`, with spaces in the name replaced by underscores. For example, task 123 "Create agent definitions" becomes `123-Create_agent_definitions`.
- Never commit, push, or open a PR without asking first.
- Keep commit messages short: one or two sentences, phrased as an action, e.g. "Add view for pokeball selection" or "Update pods".
- New Trello cards go in the New list on the Shinydex board, numbered after the highest existing card, using the board's "Item Goals / Outcome" template.
- Verify UI changes in the simulator with screenshots before calling them done.

## Project structure

The app follows DDD layers. Dependencies point inward: Presentation → Application → Domain, with Persistence and Infrastructure implementing protocols defined by the inner layers.

```
ShinyDex/
  App/             AppDelegate, SceneDelegate and AppContainer, the composition root that builds every handler
  Domain/          Entities, value objects, domain services and repository protocols, grouped by feature. Foundation only
  Application/     Commands and queries, one slice per file (e.g. Hunts/CreateHunt.swift holds the command and its handler), plus DTOs per feature
    Ports/         Protocols for outside needs (ResourceLoader, KeyValueStore, LocationLinkProvider)
  Persistence/     CoreDataStack, Core Data repositories and the versioned ShinyDex.xcdatamodeld. The only layer that imports CoreData
  Infrastructure/  Implementations of the Application ports (bundle resources, UserDefaults, Serebii links)
  Presentation/    UIKit screens, cells and views. Screens receive the AppContainer through their initialiser
  Resources/, TextFile/  Bundled JSON and text data
ShinyDexTests/     Domain, handler (in-memory repositories), persistence round-trip and store migration tests
```

- Screens only send commands and run queries. They never use repositories or domain entities; queries return DTOs and commands take typed IDs.
- A new feature gets a folder in Domain and Application, a Core Data repository if it stores data, and its handlers exposed on AppContainer.
- Never edit an existing Core Data model version. Add a new one and set it as current, and keep stored formats (entity and attribute names, JSON keys) unchanged.
- The Xcode project doesn't sync folders, so new files must be added to `ShinyDex.xcodeproj` as well as to disk.

## Code style

- Follow Apple's Swift API Design Guidelines and Xcode's default formatting (4-space indentation, `lowerCamelCase` for members, `UpperCamelCase` for types).
- Name methods as actions with a leading verb (`calculateYearLuck`, `formatOneDecimal`), so they don't read like properties (`yearLuck`, `oneDecimal`). Exceptions: framework callbacks, Swift's non-mutating forms (`clamped`, `selecting(_:)`), and event handlers named after the event (`addPressed`, `dateChanged`).
- Code must document itself. Express intent through type, method, property and variable names, small well-named helpers, and tests, not comments.
- Don't write comments by default. That includes comments explaining what code does, why a business rule exists, a data format or layout, or a workaround that a better name could convey. If you feel a comment is needed, first rename or extract code until it isn't.
- A comment is allowed only in rare, obscure cases where the code genuinely cannot convey the reason, e.g. a framework bug workaround or a non-obvious external constraint. Keep it to one line.
- `// MARK:` lines are fine.
- Before finishing any change, check the diff for added `//` or `/* */` lines and remove each one that doesn't meet the bar above.

## UI

- Build all UI programmatically. Storyboards and xibs are legacy; don't add new ones or extend existing ones, and prefer replacing them when touching that code.
- Support iOS 18 and later. Don't add `#available` checks or fallbacks for older versions.
- Use the design tokens, never raw values:
  - Fonts: `UILabel(style:weight:color:)` or `UIFont.make(_:weight:monospacedDigits:)` with a `TypeStyle`. No `systemFont(ofSize:)`. Fonts scale with Dynamic Type, so avoid fixed heights around text.
  - Colours: the semantic `Color` tokens (`background`, `surface`, `surfaceRaised`, `separator`, `textPrimary`…`textQuaternary`, `accent`, `accentSubtle`, `onAccent`, `danger`, `success`). Raw `Grey`/`Orange` shades only for chart gradients.
  - Corners: `CornerRadius.tiny/small/standard/large` or `capsule(height:)`.
  - Spacing: `Spacing.screenMargin` (20) for screen edges, the `Spacing` scale elsewhere.
- Reuse the shared components instead of building one-offs:
  - Section titles: `SectionHeaderLabel` in stacks, `SectionHeaderView.make(for:title:)` in tables.
  - Stat tiles: `StatTile`.
  - Buttons: `UIButton.make(_:)` with `.primary`, `.secondary`, `.tinted`, `.destructive` or `.pill`. Round buttons use `makeRoundButton`, counter buttons use `makeCounterButton`, where the most used action is `.primary`.
- Navigation: screens opened from the menu use large titles, screens opened from inside a feature use inline titles. Bar buttons are outlined SF Symbols with an accessibility label. Text buttons only for words like Reset or Cancel.
