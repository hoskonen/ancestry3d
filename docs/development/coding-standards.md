# Coding standards

Use Godot 4 APIs and follow the [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).

- Use tabs for GDScript indentation, one statement per line, and UTF-8 with LF. Use `snake_case` for files, functions, variables, signals and folders, `PascalCase` for classes and node names, and `CONSTANT_CASE` for constants and enum members. Use descriptive names and give domain constants a named home.
- Type parameters, return values and public state. Use typed collections where practical and infer locals when the initializer makes the type clear. Narrow dynamic values at engine or data boundaries and validate before using them.
- Group scripts, scenes and resources by the feature that owns them. Keep a scene's supporting assets near it when they share a lifecycle. Put genuinely shared assets in a location that reflects their owner. Keep Godot-generated UID and import sidecars with their source files.
- Use direct calls for requests that need an immediate result. Use signals for notifications of facts, named in the past tense, with typed payloads and explicit connections. Document connection ownership and disconnect when a shorter-lived subscriber must stop receiving events before it is freed.
- Validate inputs and resource references at boundaries. Return failures explicitly when callers can recover, and include enough context in diagnostics to locate the operation and offending data. Use assertions for programmer invariants during development, and enforce required validation in release builds too. Preserve errors during verification.
- Document public contracts, units, ownership and lifecycle where callers need them. Use comments for reasoning, engine constraints and invariants. For temporary workarounds, record the limitation and the condition for removal.
- Reuse existing logic when its contract fits. Keep refactors scoped to the task, preserve caller behavior and verify regressions. Use the [development workflow](development-workflow.md) for broader changes.
