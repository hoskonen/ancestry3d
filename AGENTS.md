<!-- BEGIN:godot-mcp -->
## Godot (managed by godot-mcp; edit outside these markers)

- This is a Godot 4.7 project. Your training data may be older: use Godot 4 APIs and GDScript 2.0 syntax, never Godot 3.
- Use the `godot_*` MCP tools. Start with `godot_status`, then `godot_project_info` for the main scene, autoloads and input actions.
- Change scenes with the scene/node tools, not by hand-editing `.tscn` text. If the editor is open, edits there are undoable; save with `godot_scene_save`.
- Don't edit `.godot/` (generated cache). Keep `*.uid` and `*.import` files next to their resources when moving files.
- Check your work: `godot_run_start` (mode "process"), then `godot_run_output` with level "error".
<!-- END:godot-mcp -->


## Engineering principles

- Plan substantial work before implementation. Prefer maintainable solutions, clear responsibilities and explicit state ownership. Minimize coupling, favor composition and use Godot's native capabilities where they fit. Keep gameplay rules separate from presentation where practical.
- Design for concrete extension needs. Avoid speculative frameworks, premature abstraction, hidden global state and undocumented assumptions.
- Follow the official GDScript style guide. Prefer readable, typed GDScript, descriptive names and focused functions. Reuse logic where its contract fits and name meaningful constants.
- Handle invalid states and failures explicitly. Preserve errors during validation. Document temporary workarounds and their limitations. Keep unrelated refactors out of feature work.

## Development and approval

For substantial changes, investigate requirements and existing behavior, propose a design, identify architectural implications and extension points, and define acceptance criteria and verification. Obtain approval for significant architectural decisions before implementing in small, reviewable increments. Run appropriate checks, review for regressions and maintainability, and update relevant documentation. Localized changes can use a lighter workflow.

Request approval before introducing foundational abstractions, adding third-party dependencies, changing persistence formats or shared data contracts, broadly refactoring, or removing existing functionality or configuration. Record significant architecture decisions using the ADR process.

## Testing and review

- Automate new gameplay rules where practical and add regression tests for bug fixes where feasible. Cover important boundaries, invalid inputs and state transitions. Prefer deterministic tests and separate unit, integration and runtime verification.
- Report executed checks and their actual outcomes. Identify skipped checks and document verification limitations.
- Review every development task. Recommend a broader audit after roughly four to six completed feature tasks and review architecture at major milestones. Track significant technical debt and prioritize evidence-based findings by risk.

## Development references

- [Architecture rules](docs/development/architecture-rules.md)
- [Coding standards](docs/development/coding-standards.md)
- [Testing strategy](docs/development/testing-strategy.md)
- [Development workflow and setup](docs/development/development-workflow.md)
- [Audit policy](docs/development/audit-policy.md)
- [Architecture decision records](docs/decisions/README.md)
