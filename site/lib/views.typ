// The three ways to browse the same cards.
#import "data.typ": base, by-name, by-arrival, by-kind, kind-label, month-label
#import "layout.typ": link-to
#import "card.typ": card
#import "copy.typ"

#let intro(list) = html.div(class: "hero", {
  html.p(class: "eyebrow", copy.eyebrow(list.len()))
  html.h1({
    copy.hero-lead(list.len())
    html.span(class: "mark", copy.hero-mark)
  })
  html.p(class: "lede", copy.lede)
  html.ul(class: "pills", {
    html.li(link-to(base, copy.all-editors))
    for group in by-kind(list) { html.li(link-to(base + "kind/#" + group.kind, kind-label(group.kind))) }
  })
})

#let grid(list) = html.div(class: "grid", for e in list { card(e) })

#let az-view(list) = {
  intro(list)
  grid(by-name(list))
}

#let timeline-view(list) = {
  intro(list)
  let groups = ()
  for e in by-arrival(list) {
    let month = month-label(e.arrived)
    if groups.len() == 0 or groups.last().month != month { groups.push((month: month, editors: ())) }
    groups.at(-1).editors.push(e)
  }
  for group in groups {
    html.section(class: "month-group", {
      html.h2(class: "month", group.month)
      grid(group.editors)
    })
  }
}

#let kind-view(list) = {
  intro(list)
  for group in by-kind(list) {
    html.section(class: "kind-group", {
      html.h2(id: group.kind, kind-label(group.kind))
      grid(group.editors)
    })
  }
}
