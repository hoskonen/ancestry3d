# Testing strategy

## Tool comparison

| Option | Role and trade-offs |
| --- | --- |
| GUT | GDScript test addon with an editor runner and a CLI that reports failures through the exit code. Release 9.7.0 includes Godot 4.7 compatibility changes. A small suite can start with assertions and fixtures, then add integration coverage as needed. Verify the selected release on 4.7.2 before adopting it. [Release notes](https://github.com/bitwes/Gut/releases/tag/v9.7.0) · [CLI reference](https://gut.readthedocs.io/en/latest/Command-Line.html) |
| GdUnit4 | Godot addon with GDScript and C# support, editor tooling and a CLI for running selected suites. Consider it if richer test tooling or C# support becomes a concrete need. Check the release compatibility table and verify the exact engine build before adopting it. [Compatibility](https://github.com/godot-gdunit-labs/gdUnit4#compatibility-overview) · [CLI reference](https://godot-gdunit-labs.github.io/gdUnit4/latest/advanced_testing/cmd/) |
| Godot headless | Built-in import, script parse checks and display-free smoke runs. Provides engine-level feedback with no additional dependency. Assertions, test discovery and reporting require a test runner or a purpose-built script. [Godot command-line reference](https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html) |
| Godot MCP | Connected project checks and process smoke runs with captured logs. The live runtime can also inspect the tree and exercise input. A smoke run covers the selected scenario and frames. Rule-level assertions and repeatable suites belong in automated tests. [MCP addon documentation](../../addons/godot_mcp/README.md) |

## Initial approach

Use Godot validation and MCP now. Propose GUT for approval when the first meaningful gameplay rules are ready for automated coverage. It fits the existing GDScript project and provides a headless runner without a custom harness. After approval, pin a release and verify on Godot 4.7.2 that a passing test exits successfully, an intentional failure exits nonzero, and the expected tests are discovered. Remove the intentional failure from the deliverable. Keep the chosen runner command and version in this guide once adopted.

## Coverage and organization

- **Unit** — Put tests under `tests/unit/<feature>/`. Cover rule outcomes, boundaries, invalid inputs and state transitions. Supply deterministic inputs and use controlled time or seeded randomness where relevant.
- **Integration** — Put tests under `tests/integration/<feature>/`. Exercise real collaborators or minimal scenes for cross-system contracts, initialization, signal delivery and cleanup. Use bounded waits for engine frames and free nodes and reset shared state in teardown.
- **Regression** — Add the smallest test that reproduces a bug at the appropriate level when feasible. Verify that it fails for the original behavior and passes with the fix. Document the reproduction or manual verification when automation is impractical.
- **Runtime** — Run representative scenes through MCP to verify startup, wiring, input and errors. Keep reusable fixtures under `tests/fixtures/` and use manual checks for rendering, interaction feel and hardware-specific behavior.

Name suites `test_<subject>.gd` and cases `test_<behavior>_when_<condition>`, for example `test_rejects_request_when_input_is_invalid`. Keep tests independent of order, user data and external services.

## Execution and reporting

1. Run focused checks while iterating, then the affected integration tests and the full automated suite once a runner is adopted. For standalone engine validation, use the Godot console executable from the project root with `--headless --path . --import`. For a targeted script parse check after import, use `--headless --path . --check-only --script res://path/to/script.gd`.
2. For MCP runtime verification, start in process mode with a bounded frame count for a smoke run. Read `godot_run_output` at level `error` for the returned run ID. Check relevant warnings, scenario outcomes and exit status separately. If no runnable scene or executable is available, report the missing prerequisite.
3. Report the commands or tool calls, scope, pass/fail/skip counts where applicable, and unresolved errors. Confirm the expected tests ran even if the runner exits successfully. Label unexecuted checks and explain any gaps. Headless execution leaves visual quality, real devices and performance to targeted runtime checks.
