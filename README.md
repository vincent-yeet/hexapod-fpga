# hexapod-fpga

Modular FPGA sensor preprocessing for a hexapod robot, using a Digilent Zybo Z7 (Zynq-7000), Livox Mid-360 LiDAR, and NVIDIA Jetson Orin Nano.

The project emphasizes FPGA learning, hardware/software co-design, reusable processing stages, and future multi-sensor integration. Outperforming the Jetson's existing preprocessing is not a current prerequisite for success.

## Intended architecture

```text
Livox Mid-360 -- Ethernet --> Zynq PS -- AXI DMA --> PL processing pipeline
                                                  | point filtering
                                                  | voxel downsampling
                                                  v
                                  Zynq PS -- processed data --> Jetson

Raw LiDAR data -- independent delivery path --> Jetson / FAST-LIO
```

PL stages will use AXI4-Stream and a shared internal point format that preserves timestamps and sensor metadata. The raw delivery topology, point encoding, voxel policy, control interface, and transport to the Jetson are design work for later milestones.

## Repository layout

| Directory | Intended contents |
| --- | --- |
| `src/rtl/common/` | Shared SystemVerilog packages, stream utilities, and reusable blocks |
| `src/rtl/point_filter/` | Configurable point-filter RTL |
| `src/rtl/voxel_grid/` | Voxel-grid downsampling RTL |
| `src/rtl/pipeline/` | PL stage composition and top-level RTL |
| `src/ps/` | Zynq PS software: Ethernet reception, DMA, configuration, and output transport |
| `src/jetson/` | Jetson reception and downstream integration software |
| `src/reference/` | Software golden reference for filtering and voxel processing |
| `verification/unit/` | Module-level testbenches and checks |
| `verification/integration/` | Pipeline and PS–PL integration verification |
| `verification/fixtures/` | Small, deterministic test inputs and expected outputs |
| `fpga/vivado/` | Source-controlled project descriptions and block-design recreation files |
| `fpga/constraints/` | Board-specific pin and timing constraints |
| `fpga/scripts/` | Future FPGA project generation and build scripts |
| `benchmarks/configs/` | Reproducible benchmark configurations |
| `benchmarks/results/` | Curated, small benchmark summaries |
| `data/synthetic/` | Curated synthetic datasets and descriptions |
| `data/captures/` | Local sensor recordings; recording files are ignored by Git |
| `scripts/` | Future repository tooling and experiment helpers |
| `docs/` | Architecture, development milestones, and design decisions |

Only directory placeholders and housekeeping documentation exist so far. No RTL, software, testbenches, build scripts, or generated FPGA projects have been added.

## Getting started

Read [the architecture notes](docs/architecture.md), [development milestones](docs/roadmap.md), and [repository conventions](CONTRIBUTING.md). Confirm the exact Zybo Z7 variant and toolchain before creating board-specific projects.

Generated build outputs belong in ignored `build/` directories. Keep large recordings outside Git; commit small fixtures and curated benchmark summaries when they are useful for reproducibility.
