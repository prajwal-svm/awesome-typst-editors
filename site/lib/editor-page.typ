// One editor's page: details, links, and its hearts and comments.
#import "data.typ": base, repo-id, category-id, kind-label, day-label
#import "copy.typ"
#import "card.typ": screenshot-url, source-host, source-icon
#import "icons.typ"

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
  if e.screenshot != none {
    let source = e.screenshot.source
    let label = if e.screenshot.at("from", default: "readme") == "website" {
      source.replace(regex("^https?://"), "").trim("/", at: end)
    } else { copy.screenshot-readme }
    html.elem("figure", attrs: (class: "editor-shot"), {
      html.elem("img", attrs: (src: screenshot-url(e), alt: copy.screenshot-alt(e.name), width: "1280", height: "720"))
      html.elem("figcaption", {
        copy.screenshot-from
        html.elem("a", attrs: (href: source), label)
      })
    })
  } else {
    html.elem("img", attrs: (
      class: "editor-image",
      src: base + "editors/" + e.slug + "/og.png",
      alt: e.name,
      width: "1200",
      height: "630",
    ))
  }
  html.h1(e.name)
  if e.description != none { html.p(class: "editor-desc", e.description) }
  if e.builder != none { html.p(class: "editor-by", copy.by(e.builder)) }
  html.ul(class: "chips", {
    for k in e.kinds { html.li(kind-label(k)) }
    for p in e.platforms { html.li(p) }
    if e.open-source { html.li(copy.open-source) }
  })
  // Links out to the project, named after the code host, the first one as the main button.
  let links = ()
  if e.source != none {
    let host = source-host(e.source)
    links.push((if host == none { copy.link-source } else { host }, e.source, source-icon(host)))
  }
  if e.homepage != none { links.push((copy.link-website, e.homepage, icons.globe)) }
  if e.forum != none { links.push((copy.link-forum, e.forum, none)) }
  if e.reddit != none { links.push((copy.link-reddit, e.reddit, none)) }
  if links.len() > 0 {
    html.ul(class: "editor-links", for (i, (label, url, icon)) in links.enumerate() {
      let attrs = if i == 0 { (class: "primary", href: url) } else { (href: url) }
      html.li(html.elem("a", attrs: attrs, {
        icon
        html.span(label)
        icons.arrow-out
      }))
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
