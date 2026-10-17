// Editor data: build inputs, validation, merging with fetched data,
// who's included where, and the orderings the views use.

#let site-url = "https://prajwal-svm.github.io/awesome-typst-editors/"
#let repo-url = "https://github.com/prajwal-svm/awesome-typst-editors"
#let base = sys.inputs.at("base", default: "/awesome-typst-editors/")

#let kind-order = ("desktop", "web", "mobile", "terminal")
#let kind-labels = (desktop: "Desktop", web: "Web", mobile: "Mobile", terminal: "Terminal")
#let kind-label(k) = kind-labels.at(k)

#let iso(d) = d.display("[year]-[month]-[day]")
#let day-label(d) = d.display("[day padding:none] [month repr:short] [year]")
#let month-label(d) = d.display("[month repr:long] [year]")

#let days-in-month(y, m) = {
  if m == 2 {
    let leap = calc.rem(y, 4) == 0 and (calc.rem(y, 100) != 0 or calc.rem(y, 400) == 0)
    if leap { 29 } else { 28 }
  } else if m in (4, 6, 9, 11) { 30 } else { 31 }
}

// YAML dates arrive as strings, so parse them by hand.
#let parse-date(s, slug) = {
  let bad = "bad date \"" + str(s) + "\" for \"" + slug + "\""
  assert(type(s) == str and s.match(regex("^\d{4}-\d{2}-\d{2}$")) != none, message: bad)
  let (y, m, d) = s.split("-").map(int)
  assert(m >= 1 and m <= 12 and d >= 1 and d <= days-in-month(y, m), message: bad)
  datetime(year: y, month: m, day: d)
}

#let today = {
  let t = sys.inputs.at("today", default: none)
  if t == none { datetime.today() } else { parse-date(t, "today") }
}

#let generated = {
  let path = sys.inputs.at("generated", default: none)
  if path == none { (:) } else { json(path) }
}
#let repo-id = generated.at("repo_id", default: none)
#let category-id = generated.at("category_id", default: none)

// Screenshot sources: slug -> (file, source, from), maintained by hand in data/screenshots.yaml.
#let screenshots = yaml(sys.inputs.at("screenshots", default: "/data/screenshots.yaml"))

#let slug-pattern = regex("^[a-z0-9]+(-[a-z0-9]+)*$")
#let fields = ("name", "slug", "arrived", "kinds", "platforms", "description", "builder", "source", "homepage", "forum", "reddit", "stars", "license")
#let text-fields = ("description", "builder", "source", "homepage", "forum", "reddit", "license")

#let as-list(v) = if v == none { () } else if type(v) == array { v } else { (v,) }

#let validate(list) = {
  assert(type(list) == array, message: "editors.yaml must be a list of editors")
  let seen = ()
  for e in list {
    let who = str(e.at("slug", default: e.at("name", default: "?")))
    for field in ("name", "slug", "arrived", "kinds") {
      assert(e.at(field, default: none) != none, message: "\"" + who + "\" is missing " + field)
    }
    assert(type(e.slug) == str and e.slug.match(slug-pattern) != none, message: "bad slug \"" + who + "\"")
    assert(e.slug not in seen, message: "duplicate slug \"" + e.slug + "\"")
    seen.push(e.slug)
    assert(type(e.kinds) == array and e.kinds.len() > 0, message: "\"" + e.slug + "\" is missing kinds")
    for k in e.kinds {
      assert(k in kind-order, message: "unknown kind \"" + str(k) + "\" for \"" + e.slug + "\"")
    }
    // A typo like "homepge" would otherwise drop the link without a word.
    for key in e.keys() {
      assert(key in fields, message: "unknown field \"" + key + "\" for \"" + e.slug + "\"")
    }
    for field in text-fields {
      let value = e.at(field, default: none)
      assert(value == none or type(value) == str, message: "\"" + e.slug + "\" has a " + field + " that isn't text")
    }
    let platforms = as-list(e.at("platforms", default: none))
    assert(platforms.all(p => type(p) == str), message: "\"" + e.slug + "\" has platforms that aren't text")
    let stars = e.at("stars", default: none)
    assert(stars == none or type(stars) == int, message: "\"" + e.slug + "\" has stars that aren't a whole number")
  }
  list
}

// Blank text counts as missing, so the fallbacks apply.
#let present(value) = if type(value) == str and value.trim() == "" { none } else { value }

// Hand-written YAML values win over fetched ones.
#let merge(e) = {
  let fetched = generated.at("editors", default: (:)).at(e.slug, default: (:))
  let discussion = generated.at("discussions", default: (:)).at(e.slug, default: (:))
  let own(key) = present(e.at(key, default: none))
  let pick(key, fetched-key: none) = {
    let value = own(key)
    if value != none { value } else { present(fetched.at(if fetched-key == none { key } else { fetched-key }, default: none)) }
  }
  let license = pick("license")
  (
    name: str(e.name),
    slug: e.slug,
    arrived: parse-date(e.arrived, e.slug),
    kinds: e.kinds,
    platforms: as-list(e.at("platforms", default: none)),
    description: pick("description"),
    builder: pick("builder", fetched-key: "owner"),
    source: own("source"),
    homepage: own("homepage"),
    forum: own("forum"),
    reddit: own("reddit"),
    stars: pick("stars"),
    license: license,
    open-source: type(license) == str and license not in ("NOASSERTION", "none"),
    hearts: discussion.at("hearts", default: 0),
    comments: discussion.at("comments", default: 0),
    discussion-url: discussion.at("url", default: none),
    screenshot: if screenshots == none { none } else { screenshots.at(e.slug, default: none) },
  )
}

#let editors = validate(yaml(sys.inputs.at("data", default: "/data/editors.yaml"))).map(merge)

// Every screenshot must belong to a listed editor.
#if screenshots != none {
  let slugs = editors.map(e => e.slug)
  for slug in screenshots.keys() {
    assert(slug in slugs, message: "screenshot for unknown editor \"" + slug + "\"")
  }
}

// On the site once an editor has been public for 30 days; in the README with 50+ stars too.
#let cutoff = today - duration(days: 30)
#let site-editors = editors.filter(e => e.arrived <= cutoff)
#let readme-editors = site-editors.filter(e => type(e.stars) == int and e.stars >= 50)

#let by-name(list) = list.sorted(key: e => lower(e.name))
// Newest first, ties by name: sort by name descending, stable-sort by date, reverse.
#let by-arrival(list) = by-name(list).rev().sorted(key: e => iso(e.arrived)).rev()
// Parenthesised: at the top level a line break would end the expression early.
#let by-kind(list) = (
  kind-order
    .map(k => (kind: k, editors: by-name(list.filter(e => k in e.kinds))))
    .filter(group => group.editors.len() > 0)
)
