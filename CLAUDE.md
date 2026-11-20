# ShinyDex

## Workflow

- Always start new work from an up-to-date `master` (`git checkout master && git pull`) and branch from there, unless told otherwise.
- Name branches after the Trello task as `<task id>-<task name>`, with spaces in the name replaced by underscores. For example, task 123 "Create agent definitions" becomes `123-Create_agent_definitions`.
- Never commit, push, or open a PR without asking first.
- Keep commit messages short: one or two sentences, phrased as an action, e.g. "Add view for pokeball selection" or "Update pods".

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
