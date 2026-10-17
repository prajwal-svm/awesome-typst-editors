// Bundle entry: every page and file the site publishes.
#import "lib/data.typ": site-editors, readme-editors, by-name, by-arrival, base
#import "lib/layout.typ": page, link-to
#import "lib/views.typ": az-view, timeline-view, kind-view
#import "lib/editor-page.typ": editor-page
#import "lib/og.typ": og-image, site-og-image
#import "lib/seo.typ": item-list-ld, software-ld, sitemap
#import "lib/readme.typ": readme-markdown
#import "lib/copy.typ"

#let n = site-editors.len()

#document("index.html", page(
  title: copy.az-title,
  description: copy.az-description(n),
  path: "",
  json-ld: item-list-ld(by-name(site-editors), ""),
  az-view(site-editors),
))

#document("timeline/index.html", page(
  title: copy.timeline-title,
  description: copy.timeline-description(n),
  path: "timeline/",
  json-ld: item-list-ld(by-arrival(site-editors), "timeline/"),
  timeline-view(site-editors),
))

#document("kind/index.html", page(
  title: copy.kind-title,
  description: copy.kind-description(n),
  path: "kind/",
  json-ld: item-list-ld(by-name(site-editors), "kind/"),
  kind-view(site-editors),
))

#for e in site-editors {
  let path = "editors/" + e.slug + "/"
  document(path + "index.html", page(
    title: copy.editor-title(e),
    description: copy.editor-description(e),
    path: path,
    og-image: path + "og.png",
    json-ld: software-ld(e),
    editor-page(e),
  ))
  document(path + "og.png", og-image(e))
}

#document("og.png", site-og-image(n))

#document("404.html", page(
  title: copy.not-found-title,
  description: copy.not-found-description,
  path: "404.html",
  {
    html.h1(copy.not-found-heading)
    html.p(link-to(base, copy.not-found-link))
  },
))

#asset("sitemap.xml", sitemap(site-editors))
#asset("README.md", readme-markdown(readme-editors))
#asset("style.css", read("/assets/style.css"))
#asset("favicon.svg", read("/assets/favicon.svg"))
