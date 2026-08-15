---
date: '2026-08-15T16:36:07+09:00'
title: 'Mermaid Diagrams in Markdown'
categories: ["Technology"]
tags: ["Hugo", "Markdown", "Mermaid"]
ShowToC: true
---

Mermaid diagrams can be written directly in Markdown with a fenced `mermaid` code block. Hugo keeps the diagram definition in the page, and the browser renders it when the page loads.

<!--more-->

## Flowchart

Use a flowchart to show a process or decision:

```mermaid
flowchart TD
    Draft[Write Markdown] --> Build[Build with Hugo]
    Build --> Publish{Publish?}
    Publish -->|Yes| Read[Render in the browser]
    Publish -->|No| Draft
```

## Sequence diagram

Use a sequence diagram to show messages exchanged over time:

```mermaid
sequenceDiagram
    participant Reader
    participant Blog
    Reader->>Blog: Open a post
    Blog-->>Reader: Return HTML and Mermaid definition
    Reader->>Reader: Render the diagram
```

Only pages containing a `mermaid` fence load the Mermaid module, regardless of how many diagrams the page contains.
