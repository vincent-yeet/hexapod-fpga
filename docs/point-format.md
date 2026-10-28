# Internal point and stream contract (v1)

Initial contract for simulation and module design. The logical point format is independent of the eventual DMA bus configuration.

## Point record

Each point occupies 192 bits (24 bytes). Coordinates remain in the source sensor's coordinate frame unless a later stage explicitly defines a transformation.

| Field | Record bits | Type and meaning |
| --- | --- | --- |
| X | 31:0 | Signed 32-bit two's-complement integer, millimeters |
| Y | 63:32 | Signed 32-bit two's-complement integer, millimeters |
| Z | 95:64 | Signed 32-bit two's-complement integer, millimeters |
| Timestamp | 159:96 | Unsigned 64-bit acquisition time, nanoseconds |
| Reflectivity | 167:160 | Unsigned 8-bit sensor return intensity; preserve original value |
| Tag | 175:168 | Original 8-bit sensor tag; preserve unchanged |
| Sensor ID | 183:176 | Unsigned 8-bit source ID assigned by PS software |
| Flags | 191:184 | Pipeline metadata defined below |

Software serialization uses little-endian byte order within multibyte fields and the field order above. Pack explicitly; do not rely on native C/C++ structure padding.

The PS derives per-point acquisition time from sensor packet timing, rather than network arrival time. Per-sensor or batch metadata must identify the timestamp clock domain, synchronization state, and coordinate frame. Sensor ID mappings must remain stable within a run. Multiple sensor clocks must not be assumed synchronized merely because timestamps use the same units.

## Flags

- Bit 0: `POINT_VALID`. One means coordinates and required acquisition metadata are usable under the input contract. Zero means the point must not contribute to filtering output or voxel accumulation.
- Bits 7:1: reserved; producers write zero. Any future meaning requires an updated contract.

Sensor-specific tag interpretation belongs in the input adapter or an explicitly configured stage. A valid point may still fail a filter predicate. Filtering removes points; it does not emit placeholder records with cleared validity flags. Pure filtering preserves every field of retained points.

## Initial AXI4-Stream mapping

Use a 64-bit `TDATA` stream with three beats per point:

| Beat | TDATA bits 63:0 |
| --- | --- |
| 0 | Record bits 63:0 (Y, X) |
| 1 | Record bits 127:64 (timestamp low 32 bits, Z) |
| 2 | Record bits 191:128 (Flags, Sensor ID, Tag, Reflectivity, timestamp high 32 bits) |

In the table, the first named component occupies the higher bits. `TKEEP` is `8'hFF` for every point beat. No `TUSER`, `TID`, or `TDEST` fields are required for v1; sensor identity travels inside the record.

- Transfer a beat only on a rising clock edge where `TVALID && TREADY` is true.
- A producer holds `TDATA`, `TKEEP`, `TLAST`, and `TVALID` stable while `TVALID` is high and `TREADY` is low. It must not wait for `TREADY` before asserting `TVALID` for available data.
- Count accepted beats, not clock cycles. Points always contain exactly three accepted beats in order; stalls may occur between them.
- `TLAST` marks the final beat of the final point in a nonempty input batch. It is only legal on beat 2. Batches contain complete points.
- Reset discards partial points and buffered batches and restarts beat counting at beat 0. PS/DMA orchestration must restart with a fresh batch; reset polarity is specified by each module interface.
- Stages preserve point order unless their documented algorithm explicitly changes it.

## Filtering and batch completion

A filter forwards only valid points satisfying its configured predicate. It must place output `TLAST` on the final retained point, even when the final input point is discarded. This requires buffering or another explicitly designed batch-completion mechanism.

An all-discarded batch emits no point beats. Therefore, `TLAST` alone cannot report every completed batch. Before DMA integration, define a separate completion/status contract that reports each batch's completion and output point count, including zero. The three-beat point stream does not encode empty batches.

Configuration stays constant for a batch; updates take effect between batches. The initial voxel selection, storage, ordering, and metadata decisions are defined in [voxel-grid.md](voxel-grid.md). Exact grid parameters and the completion/status interface remain to be finalized before voxel RTL begins.
