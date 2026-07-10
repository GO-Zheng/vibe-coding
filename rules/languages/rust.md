# Rust 规范

## Clippy

- `cargo clippy` 产生的 warning 必须处理, 不能绕过
- 提交前运行 `cargo clippy --all-targets -- -D warnings` 确保无 warning
