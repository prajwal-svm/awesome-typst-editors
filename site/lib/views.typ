// The three ways to browse the same cards.
#import "data.typ": by-name, by-arrival, by-kind, kind-label, month-label
#import "layout.typ": view-nav
#import "card.typ": card
#import "copy.typ"

#let intro(n, current) = {
  html.h1(copy.hero(n))
  html.p(class: "lede", copy.lede)
  view-nav(current)
}

#let grid(list) = html.div(class: "grid", for e in list { card(e) })

#let az-view(list) = {
  intro(list.len(), "az")
  grid(by-name(list))
}

#let timeline-view(list) = {
  intro(list.len(), "timeline")
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
  intro(list.len(), "kind")
  for group in by-kind(list) {
    html.section(class: "kind-group", {
      html.h2(id: group.kind, kind-label(group.kind))
      grid(group.editors)
    })
  }
}
