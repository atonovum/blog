---
date: '2026-08-16T01:00:00+09:00'
title: 'Images in Posts'
categories: ["Technology"]
tags: ["Hugo", "Markdown"]
ShowToC: true
---

An image in a post is laid out from its own dimensions, and any image can be opened at full size in a viewer. This post exists to show both behaviours against real files.

<!--more-->

## An image wider than the article

The file below is 1800 × 1000 pixels — far wider than the reading measure. It is scaled down to fit the column, so nothing overflows and the page never scrolls sideways:

![A grid labelled 1800 by 1000 pixels](/images/viewer-wide.png)

Click it. The viewer opens fitted to the window, and the zoom controls take it up to the file's own pixels and past them. The readout in the toolbar shows both the natural size and the current zoom.

## An image narrower than the article

This file is 320 × 200. It is under the measure, so it is left at its natural size rather than stretched, and centred in the column:

![A grid labelled 320 by 200 pixels](/images/viewer-small.png)

Small images are never scaled up. Enlarging a 320-pixel-wide file to fill a 720-pixel column would only make it blurry.

## Using the viewer

| Input | Action |
| --- | --- |
| Click, `Enter`, or `Space` on an image | Open the viewer |
| Scroll | Zoom toward the pointer |
| Drag | Pan, once the image is larger than the window |
| `+` / `-` | Zoom in and out |
| `0` | Fit to the window |
| `Esc`, the close button, or a click outside | Close |

The toolbar's third button toggles between the fitted view and actual size; it is disabled when the image already fits at 100 percent.

> [!NOTE]
> A linked image keeps its link — clicking it follows the destination instead of opening the viewer.

## Writing the Markdown

Nothing special is required. Standard Markdown image syntax is enough:

```markdown
![A grid labelled 1800 by 1000 pixels](/images/viewer-wide.png)
```

Files under `static/` are referenced from the site root, so `static/images/viewer-wide.png` is written as `/images/viewer-wide.png`. Always write alt text: it is the image's name in the viewer and the only description a screen reader gets.
