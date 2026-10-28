# Voxel downsampling baseline

Initial architecture decision: prioritize simple control and verification. This is a design specification, not implemented or measured hardware.

## Selected behavior

- Keep the first valid point encountered in each occupied voxel within a batch. Forward the full original 192-bit record unchanged; do not compute centroids.
- Use one directly addressed occupancy bit per voxel in a bounded grid. No hash table, collisions, or representative-point storage is needed in the grid memory.
- Start with one sensor in its sensor coordinate frame. Multi-sensor merging is outside this baseline.
- Use a fixed power-of-two voxel side length in integer millimeters, selected at build time. Grid origin and dimensions are also build-time parameters initially.
- Process one point at a time. Complete each occupancy read and any update before checking the next point, avoiding consecutive-access hazards for repeated voxels.
- Preserve the input order of retained points. Accept backpressure; do not overwrite a retained point while waiting for output space.
- Clear the entire occupancy bitmap before the first batch, after reset, and between batches. Pause input during clearing. Reset aborts the current batch as specified in the point/stream contract.

## Grid indexing and bounds

For voxel side length `S = 2^k` millimeters, origin `(ox, oy, oz)`, and dimensions `(Nx, Ny, Nz)`:

```text
ox <= x < ox + Nx*S
oy <= y < oy + Ny*S
oz <= z < oz + Nz*S

ix = (x - ox) >> k
iy = (y - oy) >> k
iz = (z - oz) >> k
address = ix + Nx * (iy + Ny * iz)
```

Check bounds before indexing. Use sufficiently wide signed intermediate arithmetic for subtraction and bounds calculations. The offsets are nonnegative after the check, so shifting implements floor division consistently even for negative input coordinates.

Discard invalid and out-of-grid points without accessing the bitmap. Grid bounds are lower-inclusive and upper-exclusive; the upstream XYZ filter's inclusive bounds do not override these checks.

If the addressed bit is zero, set it and retain the point. If it is one, discard the point. Every in-grid voxel has its own bit, so there is no dynamic table-full condition; a configuration exceeding the allocated memory must be rejected before operation.

## Batches and output

Occupancy belongs to exactly one input batch. The same voxel may produce another point in the next batch. First-point selection is intentionally input-order dependent.

Follow [the point/stream contract](point-format.md) for output `TLAST` placement and pending-point storage. A separate completion/status mechanism is still required to propagate empty batches through the pipeline; its interface has not yet been designed. Do not assume that a downstream stage can discover an empty batch from the point stream alone.

## Parameters to finalize before RTL

Choose the grid origin, dimensions, voxel side length, maximum input batch size, and completion/status interface. These remain open rather than adopting illustrative dimensions as requirements.

The bitmap requires `Nx * Ny * Nz` bits, rounded up to the physical memory allocation. Budget the grid alongside buffering, DMA infrastructure, and other PL logic. Halving voxel side length over the same physical extent multiplies the voxel count by eight. No device-fit or timing claim is made until synthesis.

## Verification and later optimization

Compare against a software reference using repeated voxels, neighboring voxels, negative coordinates, grid edges, invalid points, batch clearing, reset, output stalls, and empty batches. Retained records must match the input bit for bit.

Only introduce overlapping point processing, faster occupancy clearing, runtime configuration, or sparse storage when measurements or requirements justify them. Preserve the external point/stream interface where practical; changes to representative selection or batch semantics require an explicit contract revision.
