// Bundle entry: every page and file the site publishes.
#import "lib/data.typ": site-editors
#import "lib/layout.typ": page
#import "lib/views.typ": az-view, timeline-view, kind-view
#import "lib/copy.typ"

#let n = site-editors.len()

#document("index.html", page(
  title: copy.az-title,
  description: copy.az-description(n),
  path: "",
  az-view(site-editors),
))

#document("timeline/index.html", page(
  title: copy.timeline-title,
  description: copy.timeline-description(n),
  path: "timeline/",
  timeline-view(site-editors),
))

#document("kind/index.html", page(
  title: copy.kind-title,
  description: copy.kind-description(n),
  path: "kind/",
  kind-view(site-editors),
))

#asset("style.css", read("/assets/style.css"))
#asset("favicon.svg", read("/assets/favicon.svg"))
