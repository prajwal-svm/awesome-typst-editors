// One editor's page: details, links, and its hearts and comments.
#import "data.typ": base, repo-id, category-id, kind-label, day-label
#import "copy.typ"

#let giscus(e) = html.elem("script", attrs: (
  src: "https://giscus.app/client.js",
  "data-repo": "prajwal-svm/awesome-typst-editors",
  "data-repo-id": repo-id,
  "data-category": "Editors",
  "data-category-id": category-id,
  "data-mapping": "specific",
  "data-term": e.slug,
  "data-strict": "1",
  "data-reactions-enabled": "1",
  "data-emit-metadata": "0",
  "data-input-position": "top",
  "data-theme": "preferred_color_scheme",
  "data-lang": "en",
  "data-loading": "lazy",
  crossorigin: "anonymous",
  async: "",
))

#let editor-page(e) = html.elem("article", attrs: (class: "editor"), {
  html.elem("img", attrs: (
    class: "editor-image",
    src: base + "editors/" + e.slug + "/og.png",
    alt: e.name,
    width: "1200",
    height: "630",
  ))
  html.h1(e.name)
  if e.description != none { html.p(class: "editor-desc", e.description) }
  if e.builder != none { html.p(class: "editor-by", copy.by(e.builder)) }
  html.ul(class: "chips", {
    for k in e.kinds { html.li(kind-label(k)) }
    for p in e.platforms { html.li(p) }
    if e.open-source { html.li(copy.open-source) }
  })
  let links = (
    (copy.link-code, e.source),
    (copy.link-website, e.homepage),
    (copy.link-forum, e.forum),
    (copy.link-reddit, e.reddit),
  ).filter(((label, url)) => url != none)
  if links.len() > 0 {
    html.ul(class: "editor-links", for (label, url) in links {
      html.li(html.elem("a", attrs: (href: url), label))
    })
  }
  html.p(class: "arrived", copy.arrived(day-label(e.arrived)))
  html.section(class: "discussion", {
    html.h2(copy.discussion-heading)
    if repo-id != none and category-id != none {
      giscus(e)
    } else {
      html.p(copy.discussion-offline)
    }
    if e.discussion-url != none {
      html.p(html.elem("a", attrs: (href: e.discussion-url), copy.discussion-open))
    }
  })
})
