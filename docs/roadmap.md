# Incremental development milestones

1. **Repository setup:** establish directories, housekeeping, and architecture notes. Current stage; implementation has not started.
2. **Point and stream contracts:** choose the internal record and AXI4-Stream conventions; define testable stage behavior and golden-reference semantics.
3. **Point-filter simulation:** implement the reference and RTL, then verify boundaries, configuration, metadata preservation, reset, and backpressure.
4. **Voxel-stage simulation:** define the algorithm and resource bounds; verify hardware against the reference, including capacity and overflow cases.
5. **Pipeline simulation:** compose stages and verify end-to-end correctness under stalls and mixed sensor metadata.
6. **PS–PL integration:** establish a reproducible Vivado project, DMA loopback, configuration, and synthetic-data transfers before using live input.
7. **Live sensor integration:** receive Livox data, validate decoding and timestamps, and establish independent raw-data delivery to FAST-LIO.
8. **Jetson delivery and benchmarking:** validate processed output and measure throughput, latency, resource use, CPU load, and correctness against the software reference and existing workflow.

Proceed to the next stage once the current stage has reproducible evidence. Record tool versions, exact board variant, input data, and configuration with integration and benchmark results.
