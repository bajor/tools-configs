# Adapted native debugging workflow

Derived from Dimillian's iOS Debugger Agent; source pin, license and original
file digest are recorded in the adjacent skill's provenance inventory.

1. Discover the approved booted simulator or create a run-isolated destination
   using installed official CLI capabilities within the authorized verification scope.
   Boot a created destination and wait for readiness before install/launch.
   Record whether it was created; delete only run-created simulators at cleanup.
   Record its identifier and runtime;
   do not inherit an arbitrary session's destination or silently choose latest OS.
2. Resolve workspace/project, scheme, configuration and bundle ID from the target
   manifest and built artifact. Confirm the selected project through the actual
   official MCP schema when using an interactive IDE connection.
3. Build before launching. Read exact compiler/build failures before retrying;
   never begin UI interaction after a failed build. For an already-built app,
   verify its source/build identity before using the native launch operation.
4. Verify the correct app is running using an observable screen/state assertion.
   Inspect current UI state before interactions; prefer accessibility identifiers
   in XCUITest and use actual advertised official MCP actions for exploration.
   Reinspect after layout changes. Missing interaction capability remains a gap.
5. Start scoped native logging before reproducing; capture process console output
   through supported native launch/debug facilities when the scenario needs it.
   Record time range, process identity, reproduction action and relevant errors.
6. Inspect a crash/hang with matched symbols and supported native debugger tools.
   Diagnose wrong-app launches through scheme/bundle identity; diagnose missing UI
   targets through current layout and accessibility state. Reproduce a repair
   before claiming success, then end run-owned capture/debug sessions.
