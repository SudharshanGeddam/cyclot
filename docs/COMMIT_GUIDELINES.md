## Commit Message Guidelines

All future commit messages should follow a structured format using **Conventional Commits** to maintain a clear and organized git history.

### Format

```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

### Types

- **feat**: A new feature (e.g., "feat: add employee notifications")
- **fix**: A bug fix (e.g., "fix: prevent duplicate bike allocation")
- **docs**: Documentation updates (e.g., "docs: update Firebase setup")
- **style**: Code style changes that don't affect functionality (e.g., "style: format dart files")
- **refactor**: Code refactoring without changing functionality (e.g., "refactor: extract constants for Firestore collections")
- **test**: Adding or updating tests (e.g., "test: add smoke test for app initialization")
- **chore**: Build system, dependency, or tooling changes (e.g., "chore: update flutter dependencies")
- **perf**: Performance improvements (e.g., "perf: optimize bike loading query")

### Subject Line

- Start with the type and colon
- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize the first letter after the type
- No period at the end
- Limit to ~50 characters

### Body (Optional)

- Wrap at 72 characters
- Explain **what** and **why**, not how
- Separate from subject with a blank line
- Use bullet points for multiple changes

### Footer (Optional)

- Reference issues: `Fixes #123` or `Closes #456`
- Breaking changes: `BREAKING CHANGE: description`

### Examples

**Good commits:**

```
feat: add bike search and filtering functionality

- Implement search input with debouncing
- Add filter by color and status
- Update query to use Firestore indexes

Closes #42
```

```
fix: prevent duplicate bike allocation

Employees can now only have one active allocation at a time.
Added validation check in _requestBike() method.

Fixes #35
```

```
docs: update Firebase setup instructions

Add explicit Firebase project creation steps and required indexes.
```

```
refactor: replace string literals with constants

Extract Firestore collection and field names into constants.dart
for consistency and maintainability.
```

### Quick Reference

| Scenario | Type | Example |
|----------|------|---------|
| New feature | feat | `feat: add QR code scanning` |
| Bug fix | fix | `fix: resolve bike status sync issue` |
| Documentation | docs | `docs: add Firestore security rules` |
| Code formatting | style | `style: format code with dart format` |
| Refactoring | refactor | `refactor: simplify allocation logic` |
| Test addition | test | `test: add widget tests for screens` |
| Dependencies | chore | `chore: update Firebase packages` |
