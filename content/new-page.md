---
title: "Page Ttile"
url: "/new-page"
type: "page"
layout: "single"
---


Before rendering this page, define a new "menu" in `hugo.yaml`.

```YAML
menu:
  main:
    - identifier: NewPage
      name: NewPage
      url: /new-page # Should be the same as above "url"
```

`content/page/*.md` is mapped to `layouts/page/single.html`.

otherwhise, every page in `content/*.md` should specifiy "type" and "layout" parameters.
