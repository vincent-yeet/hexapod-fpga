# Architecture notes

## Goals and boundaries

Build a modular, scalable sensor-processing foundation with incremental verification. The first hardware stages are configurable point filtering and voxel-grid downsampling. Future stages and additional sensors should reuse the same streaming conventions.

The planned input path is Livox Ethernet data received by the Zynq PS, decoded or normalized as needed, then transferred to the PL through AXI DMA. Processed output returns to software for eventual delivery to the Jetson. Raw data must remain independently available to FAST-LIO; preprocessing must not replace or gate that raw input.

## Contracts to define before implementation

The initial [point/stream contract](point-format.md) and [voxel baseline](voxel-grid.md) document decisions made so far. Remaining implementation details include the following:

- Internal point record: coordinates, units, numeric representation, timestamp meaning and precision, sensor ID, validity, and supported sensor metadata.
- AXI4-Stream mapping: data width, byte validity, frame or batch boundaries, metadata placement, ordering, reset behavior, and backpressure handling.
- Filtering configuration: supported predicates, configuration update timing, and discarded-point accounting.
- Voxel parameters: finalize grid dimensions, origin, and voxel size within the memory budget. The selected baseline uses first-point selection, a direct bitmap, sequential point processing, and clearing between batches.
- PS–PL transfer: DMA directions, buffers, ownership, cache coherency, batching, error recovery, and control/status access.
- Multi-sensor extension: identity, timestamp synchronization, arbitration, and per-sensor configuration.
- Raw-data delivery: network topology and availability independent of processed-stream stalls or failures.

## Open setup choices

The board is a Zybo Z7-10. Vivado will be installed later on a separate Windows computer; Icarus Verilog is believed to be available locally but has not yet been verified. Confirm toolchain versions, PS execution environment, reference language, and Jetson integration interface. The initial point/stream contract is in [point-format.md](point-format.md).
