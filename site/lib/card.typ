// One editor card. Every editor gets exactly this card, at exactly the same size.
#import "data.typ": base, kind-label, day-label
#import "copy.typ"
#import "icons.typ"

#let screenshot-url(e) = base + "screenshots/" + e.slug + "." + e.screenshot.file.split(".").last()

// The code host's name for a source URL ("GitHub"), or none when it isn't a known host.
#let source-host(url) = copy.host-names.at(lower(url.replace(regex("^https?://(www\.)?"), "").split("/").first()), default: none)
#let source-icon(host) = if host == "GitHub" { icons.github } else { icons.code }

// An article, not a link: the card holds links out to the project, and links can't nest.
// The name's link is stretched over the whole card in CSS, so a click anywhere opens the editor's page.
#let card(e) = {
  let first = e.kinds.first()
  html.elem("article", attrs: (class: "card"), {
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
          html.h3(class: "card-name", html.elem("a", attrs: (class: "card-link", href: base + "editors/" + e.slug + "/"), e.name))
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
        html.div(class: "card-actions", {
          if e.source != none {
            let host = source-host(e.source)
            let label = copy.source-label(e.name, host)
            html.elem("a", attrs: (class: "card-out", href: e.source, "aria-label": label, title: label), source-icon(host))
          }
          if e.homepage != none {
            let label = copy.website-label(e.name)
            html.elem("a", attrs: (class: "card-out", href: e.homepage, "aria-label": label, title: label), icons.globe)
          }
          // No code and no website: the announcement post is the way to the project.
          let post = if e.forum != none { e.forum } else { e.reddit }
          if e.source == none and e.homepage == none and post != none {
            let label = copy.announcement-label(e.name)
            html.elem("a", attrs: (class: "card-out", href: post, "aria-label": label, title: label), icons.megaphone)
          }
          html.elem("span", attrs: (class: "card-comments", "aria-label": copy.comments-label(e.comments)), {
            icons.comment
            str(e.comments)
          })
        })
      })
    })
  })
}
