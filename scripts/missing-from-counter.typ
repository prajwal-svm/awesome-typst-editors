// Lists editors on the community counter that editors.yaml doesn't have yet, minus the
// ones checked and left out in counter-skip.yaml.
// Inputs: counter (CSV path inside the root), data (default /data/editors.yaml),
// skip (default /data/counter-skip.yaml).
#let counter = csv(sys.inputs.at("counter"), row-type: dictionary)
#let editors = yaml(sys.inputs.at("data", default: "/data/editors.yaml"))
// A skip file with no entries left parses as none.
#let skipped = {
  let list = yaml(sys.inputs.at("skip", default: "/data/counter-skip.yaml"))
  if list == none { () } else { list }
}

#let norm-url(url) = {
  if url == none or url.trim() == "" { return none }
  let s = lower(url.trim()).trim("/", at: end)
  if s.ends-with(".git") { s = s.slice(0, s.len() - 4) }
  s.trim("/", at: end)
}
#let norm-name(name) = lower(str(name)).replace(regex("\([^)]*\)"), "").replace(regex("[^a-z0-9]"), "")

#let known-sources = editors.map(e => norm-url(e.at("source", default: none))).filter(s => s != none)
#let known-names = (editors + skipped).map(e => norm-name(e.name))

// Parenthesised: at the top level a line break would end the expression early.
#let missing = (
  counter
    .filter(row => {
      let source = norm-url(row.at("source_code_url", default: none))
      not ((source != none and source in known-sources) or norm-name(row.name) in known-names)
    })
    .map(row => row.name)
    .sorted()
)

#metadata(missing) <missing>
