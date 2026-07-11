# Rendering Test

This document checks the native Markdown preview renderer.

## Table Test

| Area | Expected |
| --- | --- |
| Table | Rendered as a table |
| Link | Styled and clickable |
| Code | Rendered in a code block |

## Link Test

- [External Link](https://example.com)
- [Relative Markdown Link](./architecture.md)
- [Nested Markdown Link](./api/auth.md)
- [Parent Markdown Link](../README.md)
- [Anchor Link](#table-test)
- [Markdown Link With Anchor](./architecture.md#data-flow)

## Code Test

```swift
struct Example {
    let value: String
}
```
