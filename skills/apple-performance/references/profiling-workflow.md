# Adapted SwiftUI profiling workflow and report

Derived from Dimillian's SwiftUI Performance Audit, its profiling intake and
report template. Use the source-pinned provenance inventory for original files.

1. Classify the observed symptom: CPU/battery activity, dropped frames/hitches,
   memory growth, slow navigation/startup, hangs or broad view invalidation.
   Specify one exact interaction and the feature/data flow involved.
2. Record hardware/OS, source/model/fixture hashes, configuration and whether the
   observation came from a simulator or physical device. Build Release/profile
   when comparing user-facing performance; Debug can distort timing/allocations.
3. Review the affected view's state/observation dependencies, stable list identity,
   work in `body`, image decode/resize, layout and animation scope. Treat these as
   hypotheses until measurements identify the relevant cost.
4. Record the isolated interaction using installed Instruments templates. For
   SwiftUI issues select supported SwiftUI/Time Profiler and hang/hitch tracks;
   add memory/Allocations evidence for growth. Inspect relevant call trees and
   update timelines together. Preserve traces, not only screenshots of tables.
5. Correlate expensive intervals with the exact scenario action. Separate
   invalidation/identity churn, layout work, main-thread computation, image cost
   and rendering. If supported exports omit needed analysis, retain the trace
   for human Instruments inspection and report that interpretation limitation.
6. Repeat comparable captures before/after repairs. Prefer focused changes to
   confirmed costs: narrow observation scope, stabilize identity, move domain
   computation to explicit owners/executors or reduce image/layout work. Do not
   add arbitrary state caches, blanket equality or a new global service layer.

Report each finding with symptom, affected source, measurement evidence, cause
or hypothesis, proposed repair and identical-scenario validation command.
Include the following fields for every measured comparison:

| Field | Required content |
| --- | --- |
| Measurement | Metric, unit, template/instrument and scenario interval |
| Before/after | Raw samples, summary statistic and variability |
| Reproducibility | Source/build/model/fixture digests and command arguments |
| Environment | Physical hardware, OS, Xcode, power/thermal state and workload |
| Decision | Approved budget/method, delta, uncertainty and pass/fail/inconclusive |
| Evidence | Original trace, exported tables, symbols and native test results |

If evidence is missing, state which measurement is required instead of filling
the table with estimates. Simulator observations cannot establish hardware
rendering, memory-pressure, inference throughput, battery or thermal guarantees.
