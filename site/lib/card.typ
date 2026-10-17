// One editor card. Every editor gets exactly this card, at exactly the same size.
#import "data.typ": base, kind-label, day-label
#import "copy.typ"
#import "icons.typ"

#let screenshot-url(e) = base + "screenshots/" + e.slug + "." + e.screenshot.file.split(".").last()

#let card(e) = {
  let first = e.kinds.first()
  html.elem("a", attrs: (class: "card", href: base + "editors/" + e.slug + "/"), {
    html.div(class: "card-media", {
      if e.screenshot != none {
        html.elem("img", attrs: (
          class: "card-shot",
          src: screenshot-url(e),
          alt: copy.screenshot-alt(e.name),
          loading: "lazy",
          width: "1280",
          height: "720",
        ))
      } else {
        html.div(class: "card-banner kind-" + first, {
          html.span(class: "banner-name", e.name)
          html.span(class: "banner-kind", kind-label(first))
        })
      }
    })
    html.div(class: "card-body", {
      html.div(class: "card-head", {
        html.elem("span", attrs: (class: "card-icon", "aria-hidden": "true"), upper(e.name.clusters().first()))
        html.div(class: "card-title", {
          html.h3(class: "card-name", e.name)
          if e.builder != none { html.p(class: "card-by", copy.by(e.builder)) }
        })
        html.elem("span", attrs: (class: "card-hearts", "aria-label": copy.hearts-label(e.hearts)), {
          icons.heart
          str(e.hearts)
        })
      })
      if e.description != none { html.p(class: "card-desc", e.description) }
      html.ul(class: "chips", {
        for k in e.kinds { html.li(kind-label(k)) }
        if e.open-source { html.li(copy.open-source) }
        for p in e.platforms { html.li(p) }
      })
      html.div(class: "card-foot", {
        html.span(class: "card-arrived", copy.arrived(day-label(e.arrived)))
        html.elem("span", attrs: (class: "card-comments", "aria-label": copy.comments-label(e.comments)), {
          icons.comment
          str(e.comments)
        })
      })
    })
  })
}
