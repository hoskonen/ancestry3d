# Development workflow

## Small changes

For a localized change with an established design and no approval triggers, inspect the affected code, identify the intended result, make a focused change and run targeted verification. Review the diff and update documentation where behavior or instructions change.

## Substantial features

1. Investigate the requirements, current behavior, relevant Godot settings and affected callers.
2. Propose a design with scope, alternatives, ownership, dependencies, extension points and failure behavior. Identify implications for existing scenes, data and callers.
3. Agree on acceptance criteria and the verification approach. Request approval for significant architectural decisions and any change covered by the [approval rules](../../AGENTS.md). Record significant decisions through the [ADR process](../decisions/README.md).
4. Implement in small, reviewable increments. Recheck the proposal if the work exposes a new decision that requires approval.
5. Run the relevant [validation and tests](testing-strategy.md), then review the implementation for regressions and maintainability using the [audit policy](audit-policy.md).
6. Update relevant documentation. Report the outcome, changed files, decisions, executed checks and remaining risks or follow-up.

## Task template

~~~markdown
# Task title

## Objective
Describe the user or engineering outcome.

## Scope
List the changes and any boundaries.

## Constraints
List dependencies, compatibility requirements and approval triggers.

## Acceptance criteria
List observable conditions for completion.

## Verification
Map checks to criteria. Identify manual checks and required prerequisites.
~~~

## Reconstructing the project

- Keep `project.godot`, source scenes and assets, UID and import sidecars, the existing `addons/godot_mcp/` addon, and shared Git/editor settings under version control. Keep generated cache files, local overrides, credentials and machine-specific paths out of commits. Review staged files for these before committing. [Godot version-control guidance](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html)
- Open `project.godot` in Godot 4.7.2 and confirm the Godot MCP plugin is enabled. Godot regenerates its cache on import. Use the existing renderer settings when verifying this Windows project.
- Install Node.js 22 or later with npm/`npx` available for the existing MCP server. In the checkout, recreate the ignored `.codex/config.toml` from the example below with that checkout's absolute path. Restart the Codex session with the Godot editor open and confirm `godot_status` reports the expected project and connected editor. For process runs, make `godot` available on the server's PATH or set `GODOT_PATH` to the full executable path in the local MCP server environment.

~~~toml
[mcp_servers.godot]
command = "npx"
args = ["-y", "@shin2344234/godot-mcp@0.1.2", "--project", "/absolute/path/to/checkout"]
~~~

Use forward slashes or TOML-escaped backslashes on Windows. The bridge's session token lives under the ignored `.godot/` directory. See the [addon documentation](../../addons/godot_mcp/README.md) for setup details.
