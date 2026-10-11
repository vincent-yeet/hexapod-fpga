# Architecture notes

## Goals and boundaries

Build a modular, scalable sensor-processing foundation with incremental verification. The first hardware stages are configurable point filtering and voxel-grid downsampling. Future stages and additional sensors should reuse the same streaming conventions.

The planned input path is Livox Ethernet data received by the Zynq PS, decoded or normalized as needed, then transferred to the PL through AXI DMA. Processed output returns to software for eventual delivery to the Jetson. Raw data must remain independently available to FAST-LIO; preprocessing must not replace or gate that raw input.

## Contracts to define before implementation

- Internal point record: coordinates, units, numeric representation, timestamp meaning and precision, sensor ID, validity, and supported sensor metadata.
- AXI4-Stream mapping: data width, byte validity, frame or batch boundaries, metadata placement, ordering, reset behavior, and backpressure handling.
- Filtering configuration: supported predicates, configuration update timing, and discarded-point accounting.
- Voxel behavior: voxel size and origin, representative-point or aggregation policy, batch/window boundaries, capacity, collisions, and overflow handling. Specify timestamp and metadata semantics for any aggregated output.
- PS–PL transfer: DMA directions, buffers, ownership, cache coherency, batching, error recovery, and control/status access.
- Multi-sensor extension: identity, timestamp synchronization, arbitration, and per-sensor configuration.
- Raw-data delivery: network topology and availability independent of processed-stream stalls or failures.

## Open setup choices

Confirm Zybo Z7-10 versus Z7-20, Vivado/toolchain versions, PS execution environment, simulator, reference language, and Jetson integration interface. No choices here constitute a committed hardware specification.
