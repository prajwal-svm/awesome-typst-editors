// One editor card. Every editor gets exactly this card.
#import "data.typ": base, kind-label
#import "copy.typ"

#let card(e) = {
  let first = e.kinds.first()
  html.elem("a", attrs: (class: "card", href: base + "editors/" + e.slug + "/"), {
    html.div(class: "card-banner kind-" + first, {
      html.span(class: "banner-name", e.name)
      html.span(class: "banner-kind", kind-label(first))
    })
    html.h3(class: "card-name", e.name)
    if e.description != none { html.p(class: "card-desc", e.description) }
    html.ul(class: "chips", {
      for k in e.kinds { html.li(kind-label(k)) }
      for p in e.platforms { html.li(p) }
      if e.open-source { html.li(copy.open-source) }
    })
    html.div(class: "card-foot", {
      if e.builder != none { html.span(class: "card-by", copy.by(e.builder)) }
      html.span(class: "card-counts", {
        html.elem("span", attrs: (class: "card-hearts", "aria-label": copy.hearts-label(e.hearts)), "♥ " + str(e.hearts))
        html.elem("span", attrs: (class: "card-comments", "aria-label": copy.comments-label(e.comments)), "💬 " + str(e.comments))
      })
    })
  })
}
