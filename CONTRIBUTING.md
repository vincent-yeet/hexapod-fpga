# Repository conventions

- Keep reusable RTL in `src/rtl/`; keep board constraints and Vivado setup in `fpga/`.
- Keep Zynq PS, Jetson, and golden-reference software separate. Select languages, runtime environments, and dependencies when implementation begins.
- Use AXI4-Stream boundaries between processing stages. Document the point format and stage contracts before implementing them.
- Keep timestamps and sensor identity available through the pipeline. Record any intentional loss or aggregation of metadata.
- Add module verification alongside each implemented stage, including stream backpressure and reset behavior.
- Use small deterministic fixtures for correctness checks. Keep live captures and large experiment outputs out of Git.
- Put generated files in `build/` or tool-generated directories. Commit the inputs needed to recreate projects, rather than entire generated tool workspaces.
- Document benchmark input, configuration, tool versions, hardware, correctness checks, and measurement method with results.
- Record consequential design choices in `docs/decisions/` using a dated Markdown file with context, decision, alternatives, and consequences.
- Never commit credentials, private keys, or machine-specific configuration. Licensing has not yet been selected; add a license after the owner chooses one.

Empty directories contain `.gitkeep` files so Git preserves the initial layout. Remove a placeholder when its directory gains tracked content.
