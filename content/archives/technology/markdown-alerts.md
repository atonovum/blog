---
date: '2026-08-16T00:30:00+09:00'
title: 'Markdown Alerts in Posts'
categories: ["Technology"]
tags: ["Hugo", "Markdown"]
ShowToC: true
---

Alerts are blockquotes that carry a label. They mark a passage as advice, a caveat, or a hazard without pulling the reader out of the article. Hugo renders them from ordinary Markdown, so a post keeps its plain-text source.

<!--more-->

## Syntax

An alert is a blockquote whose first line is a type marker in square brackets:

```markdown
> [!NOTE]
> Highlights information that users should take into account, even when skimming.
```

The marker must be the first line, and every following line stays part of the same blockquote.

## The five types

Each type has its own accent color and icon, so the kind of message is readable before the sentence is.

> [!NOTE]
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.

| Type | Use it for | Accent |
| --- | --- | --- |
| `NOTE` | Context a skimming reader should still catch | Blue |
| `TIP` | Optional advice that improves the outcome | Green |
| `IMPORTANT` | Information required for the task to succeed | Purple |
| `WARNING` | Risk that needs attention before proceeding | Amber |
| `CAUTION` | Consequences of an action that is hard to undo | Red |

## Custom titles

A title written after the marker replaces the default label:

```markdown
> [!TIP] Build the site before deploying
> `hugo --gc --minify` writes a clean `public/` directory.
```

> [!TIP] Build the site before deploying
> `hugo --gc --minify` writes a clean `public/` directory.

## Rich content inside an alert

An alert holds the same content as any blockquote — lists, code, and links all render normally:

> [!IMPORTANT]
> Three things have to be true before a post publishes:
>
> 1. `draft` is absent or `false`.
> 2. The `date` is not in the future.
> 3. The post sits under a section listed in the menu.
>
> ```yaml
> date: '2026-08-16T00:30:00+09:00'
> title: 'Markdown Alerts in Posts'
> ```

## When not to use one

> [!WARNING]
> An alert on every other paragraph stops being a signal. Reserve them for passages a reader cannot afford to skip, and let ordinary prose carry the rest.

A plain blockquote is still the right tool for a quotation:

> The best writing is rewriting.

It keeps PaperMod's quiet default treatment — no icon, no tint, no label.
