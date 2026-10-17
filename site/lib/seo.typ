// Structured data and the sitemap.
#import "data.typ": site-url, iso, today

#let editor-url(e) = site-url + "editors/" + e.slug + "/"

#let item-list-ld(list, path) = (
  "@context": "https://schema.org",
  "@type": "ItemList",
  "url": site-url + path,
  "itemListElement": list.enumerate().map(((i, e)) => (
    "@type": "ListItem",
    "position": i + 1,
    "name": e.name,
    "url": editor-url(e),
  )),
)

// No ratings here: hearts are thanks, not ratings.
#let software-ld(e) = {
  let data = (
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": e.name,
    "url": editor-url(e),
    "applicationCategory": "DeveloperApplication",
  )
  if e.description != none { data.insert("description", e.description) }
  if e.platforms.len() > 0 { data.insert("operatingSystem", e.platforms.join(", ")) }
  let same-as = (e.source, e.homepage).filter(url => url != none)
  if same-as.len() > 0 { data.insert("sameAs", same-as) }
  data
}

#let sitemap(list) = {
  let paths = ("", "timeline/", "kind/") + list.map(e => "editors/" + e.slug + "/")
  let entries = paths.map(p => "  <url><loc>" + site-url + p + "</loc><lastmod>" + iso(today) + "</lastmod></url>\n")
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n" + entries.join() + "</urlset>\n"
}
