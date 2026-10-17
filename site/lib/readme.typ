// The awesome-style README, generated from the same data as the site.
#import "data.typ": kind-order, kind-label, by-name, site-url, repo-url
#import "copy.typ"

// Backslash-escapes Markdown punctuation, so names and descriptions show exactly as written.
// The backslash goes first, so the escapes added after it stay single.
#let escape-markdown(s) = {
  let out = s
  for c in ("\\", "`", "*", "_", "~", "[", "]", "<", ">", "&") { out = out.replace(c, "\\" + c) }
  out
}

// An initial capital and a final period, as awesome lists expect.
#let readme-description(e) = {
  let text = if e.description == none {
    copy.readme-fallback-description(lower(kind-label(e.kinds.first())))
  } else {
    e.description.trim()
  }
  let first = text.clusters().first()
  text = upper(first) + text.slice(first.len())
  if not text.ends-with(".") { text += "." }
  escape-markdown(text)
}

#let readme-link(e) = if e.source != none { e.source } else if e.homepage != none { e.homepage } else {
  site-url + "editors/" + e.slug + "/"
}

#let readme-item(e) = "- [" + escape-markdown(e.name) + "](" + readme-link(e) + ") - " + readme-description(e)

// Each editor appears once, under the first kind it lists.
#let readme-markdown(list) = {
  let sections = kind-order
    .map(k => (kind: k, editors: by-name(list.filter(e => e.kinds.first() == k))))
    .filter(section => section.editors.len() > 0)
  let lines = (
    copy.readme-heading,
    "",
    copy.readme-tagline,
    "",
    copy.readme-browse(site-url),
    "",
    copy.readme-rules,
    "",
    "## " + copy.readme-contents,
    "",
  )
  for section in sections {
    lines.push("- [" + kind-label(section.kind) + "](#" + section.kind + ")")
  }
  for section in sections {
    lines += ("", "## " + kind-label(section.kind), "")
    lines += section.editors.map(readme-item)
  }
  lines += (
    "",
    "## " + copy.readme-contributing-heading,
    "",
    copy.readme-contributing(repo-url),
    "",
    "## " + copy.readme-license-heading,
    "",
    copy.readme-license,
  )
  lines.join("\n") + "\n"
}
