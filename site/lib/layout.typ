// The page shell: head tags, header, footer, and the view switcher.
#import "data.typ": site-url, repo-url, base
#import "copy.typ"

#let meta-property(property, content) = html.elem("meta", attrs: (property: property, content: content))

// JSON-LD sits inside <script>, so "</" must never appear raw.
#let ld-json(data) = json.encode(data, pretty: false).replace("</", "<\\/")

#let link-to(url, label, class: none) = {
  let attrs = (:)
  if class != none { attrs.insert("class", class) }
  attrs.insert("href", url)
  html.elem("a", attrs: attrs, label)
}

#let view-nav(current) = html.elem("nav", attrs: (class: "views", "aria-label": copy.nav-label), {
  for (key, label, path) in (("az", copy.nav-az, ""), ("timeline", copy.nav-timeline, "timeline/"), ("kind", copy.nav-kind, "kind/")) {
    let attrs = (href: base + path)
    if key == current { attrs.insert("aria-current", "page") }
    html.elem("a", attrs: attrs, label)
  }
})

#let page(title: none, description: none, path: "", og-image: "og.png", json-ld: (:), body) = html.html(lang: "en", {
  html.head({
    html.meta(charset: "utf-8")
    html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
    html.title(title)
    html.meta(name: "description", content: description)
    html.link(rel: "canonical", href: site-url + path)
    meta-property("og:title", title)
    meta-property("og:description", description)
    meta-property("og:url", site-url + path)
    meta-property("og:image", site-url + og-image)
    meta-property("og:type", "website")
    html.meta(name: "twitter:card", content: "summary_large_image")
    html.link(rel: "stylesheet", href: base + "style.css")
    html.link(rel: "icon", href: base + "favicon.svg", type: "image/svg+xml")
    if json-ld.len() > 0 { html.script(type: "application/ld+json", ld-json(json-ld)) }
  })
  html.body({
    html.header(class: "site-header", {
      link-to(base, copy.site-name, class: "site-name")
      link-to(repo-url + "/issues/new?template=add-editor.yml", copy.add-editor, class: "add-editor")
    })
    html.main(body)
    html.footer(class: "site-footer", {
      html.p(copy.footer-line)
      html.p({
        link-to(repo-url + "/issues/new?template=fix-or-remove.yml", copy.fix-editor)
        html.span(class: "dot", " · ")
        link-to(repo-url, copy.source-link)
      })
    })
  })
})
