// Social preview images, rendered as PNG pages of 600pt x 315pt (1200 x 630 px).
#import "data.typ": kind-label
#import "copy.typ"

#let ink = rgb("#1f2328")
#let muted = rgb("#59636e")
#let tints = (
  desktop: rgb("#d9e6fb"),
  web: rgb("#d8f0df"),
  mobile: rgb("#fbe9c7"),
  terminal: rgb("#e4e6ea"),
)

#let og-image(e) = {
  let kind = e.kinds.first()
  set page(width: 600pt, height: 315pt, margin: 36pt, fill: tints.at(kind))
  set text(fill: ink)
  place(top + left, text(size: 13pt, weight: "bold", fill: muted, tracking: 1pt, upper(kind-label(kind))))
  place(horizon + left, block(width: 100%, text(size: 40pt, weight: "bold", e.name)))
  place(bottom + left, text(size: 13pt, fill: muted, copy.site-name))
}

#let site-og-image(count) = {
  set page(width: 600pt, height: 315pt, margin: 36pt, fill: rgb("#f7f6f2"))
  set text(fill: ink)
  place(horizon + left, block(width: 100%, {
    text(size: 38pt, weight: "bold", copy.site-name)
    linebreak()
    text(size: 18pt, fill: muted, copy.hero(count))
  }))
}
