// Icons from Lucide 1.59.0 (lucide.dev), ISC License: see assets/LUCIDE-LICENSE.txt.
// The GitHub mark comes from Simple Icons 16.33.0 (CC0); the mark itself belongs to GitHub.
#let svg(name, body, stroked: true) = html.elem("svg", attrs: (
  class: "icon icon-" + name,
  xmlns: "http://www.w3.org/2000/svg",
  width: "16",
  height: "16",
  viewBox: "0 0 24 24",
  ..if stroked {
    (fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round")
  } else {
    (fill: "currentColor",)
  },
  "aria-hidden": "true",
), body)
#let path(d) = html.elem("path", attrs: (d: d))
#let lucide(name, ..ds) = svg(name, for d in ds.pos() { path(d) })

#let heart = lucide("heart", "M2 9.5a5.5 5.5 0 0 1 9.591-3.676.56.56 0 0 0 .818 0A5.49 5.49 0 0 1 22 9.5c0 2.29-1.5 4-3 5.5l-5.492 5.313a2 2 0 0 1-3 .019L5 15c-1.5-1.5-3-3.2-3-5.5")
#let comment = lucide("comment", "M2.992 16.342a2 2 0 0 1 .094 1.167l-1.065 3.29a1 1 0 0 0 1.236 1.168l3.413-.998a2 2 0 0 1 1.099.092 10 10 0 1 0-4.777-4.719")
#let code = lucide("code", "m18 16 4-4-4-4", "m6 8-4 4 4 4", "m14.5 4-5 16")
#let arrow-out = lucide("arrow-up-right", "M7 7h10v10", "M7 17 17 7")
#let megaphone = lucide("megaphone", "M11 6a13 13 0 0 0 8.4-2.8A1 1 0 0 1 21 4v12a1 1 0 0 1-1.6.8A13 13 0 0 0 11 14H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2z", "M6 14a12 12 0 0 0 2.4 7.2 2 2 0 0 0 3.2-2.4A8 8 0 0 1 10 14", "M8 6v8")
#let globe = svg("globe", {
  html.elem("circle", attrs: (cx: "12", cy: "12", r: "10"))
  path("M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20")
  path("M2 12h20")
})
#let github = svg("github", stroked: false, path("M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"))
