# Architecture rules

## Responsibilities and ownership

- Give each system a clear responsibility and a named owner for the state it mutates. Document its inputs, outputs, lifecycle and failure modes. Other systems request changes through the owner's API or consume read-only views and events.
- Keep domain rules independently testable where practical. When simulation exists, its orchestration controls update timing and ordering. Presentation maps input to requests and reflects outcomes through scenes, UI, animation and audio.
- Keep dependencies explicit at construction or scene wiring. Prefer composition using Godot nodes, resources and plain GDScript objects as appropriate. Reserve inheritance for genuine substitutability and autoloads for approved project-wide lifecycles with documented ownership.

## Data and extension

- Use typed Resources for authored data when the editor helps validate or tune it. Separate shared definitions from mutable instance state. Validate content at load or construction boundaries and report the offending resource.
- Extend the smallest interface that supports a concrete use case. Prefer adding a new configuration or component where the behavior fits an existing contract. Introduce a shared abstraction when real callers share a stable contract or an approved design identifies a concrete boundary that needs one.
- Keep dependencies directional and make ordering explicit when correctness depends on it. Avoid circular references, hidden globals, shared mutable Resources, string-based service lookup, and signal chains whose order determines gameplay outcomes.
- Consider ownership, failure recovery, compatibility, testability and migration costs when a proposal crosses a system boundary. Record significant decisions using the [ADR process](../decisions/README.md) and obtain approval before implementing foundational changes.

These rules guide future proposals. Presentation, combat and simulation choices belong in their own scoped tasks.
