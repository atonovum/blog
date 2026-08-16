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

## Gantt chart

Use a Gantt chart to place work on a calendar and show what overlaps:

```mermaid
gantt
    title Publishing a post
    dateFormat YYYY-MM-DD
    axisFormat %m-%d
    tickInterval 1week
    weekday monday
    todayMarker off

    section Writing
    Draft               :done,    draft, 2026-08-03, 5d
    Revise              :active,  rev,   after draft, 4d

    section Production
    Add diagrams        :         diag,  after draft, 3d
    Proofread           :         proof, after rev, 2d

    section Release
    Build and deploy    :milestone, rel, after proof, 0d
```

`dateFormat` describes the dates written in the definition, and `axisFormat` describes the labels drawn on the axis. `tickInterval` controls how often those labels appear — leave it out on a multi-week chart and the daily ticks collide. Tasks chain with `after <id>`, so shifting one task moves everything downstream of it.

## Pie chart

Use a pie chart for a small number of parts that add up to one whole:

```mermaid
pie showData
    title Where drafting time goes
    "Writing" : 45
    "Editing" : 25
    "Diagrams" : 18
    "Formatting" : 12
```

`showData` prints the raw values next to the legend. Keep the slice count low — beyond five or six parts a table reads better than a circle.

Only pages containing a `mermaid` fence load the Mermaid module, regardless of how many diagrams the page contains.
