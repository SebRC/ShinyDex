# ShinyDex

## Workflow

- Always start new work from an up-to-date `master` (`git checkout master && git pull`) and branch from there, unless told otherwise.
- Name branches after the Trello task as `<task id>-<task name>`, with spaces in the name replaced by underscores. For example, task 123 "Create agent definitions" becomes `123-Create_agent_definitions`.
- Never commit, push, or open a PR without asking first.
- Keep commit messages short: one or two sentences, phrased as an action, e.g. "Add view for pokeball selection" or "Update pods".

## Code style

- Follow Apple's Swift API Design Guidelines and Xcode's default formatting (4-space indentation, `lowerCamelCase` for members, `UpperCamelCase` for types).
- Prefer descriptive method and variable names over comments.
- Don't add superfluous comments. Remove any that restate a method name or describe what the code plainly does. Keep a comment only when it explains *why* something non-obvious is done.

## UI

- Build all UI programmatically. Storyboards and xibs are legacy; don't add new ones or extend existing ones, and prefer replacing them when touching that code.
