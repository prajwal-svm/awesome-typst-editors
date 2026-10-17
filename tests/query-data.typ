// Exposes the data rules as <result> metadata, read by tests/test_data.sh.
#import "/site/lib/data.typ": *

#let slugs(list) = list.map(e => e.slug)
#let per-editor(f) = {
  let out = (:)
  for e in editors { out.insert(e.slug, f(e)) }
  out
}

#metadata((
  site: slugs(site-editors),
  readme: slugs(readme-editors),
  az: slugs(by-name(site-editors)),
  timeline: slugs(by-arrival(site-editors)),
  kinds: by-kind(site-editors).map(g => (kind: g.kind, editors: slugs(g.editors))),
  open: slugs(site-editors.filter(e => e.open-source)),
  hearts: per-editor(e => e.hearts),
  desc: per-editor(e => e.description),
  builder: per-editor(e => e.builder),
  stars: per-editor(e => e.stars),
)) <result>
