// Every user-facing string on the site lives here.

#let site-name = "Awesome Typst Editors"
#let hero(n) = str(n) + " Typst editors and counting"
#let lede = "Built by people who love Typst. Leave a heart for the ones you like."

#let nav-az = "A to Z"
#let nav-timeline = "Timeline"
#let nav-kind = "By kind"
#let nav-label = "Views"

#let add-editor = "Add an editor"
#let fix-editor = "Fix or remove an editor"
#let source-link = "Source on GitHub"
#let footer-line = "Made by Prajwal (prajwal-svm). Every editor gets the same card, and nothing is sorted by hearts."

#let open-source = "Open source"
#let by(builder) = "by " + builder
#let hearts-label(n) = str(n) + if n == 1 { " heart" } else { " hearts" }
#let comments-label(n) = str(n) + if n == 1 { " comment" } else { " comments" }
#let arrived(label) = "Arrived " + label

#let az-title = "Awesome Typst Editors: every Typst editor, A to Z"
#let az-description(n) = str(n) + " Typst editors and apps for desktop, web, mobile and the terminal. Browse them all and leave a heart for the ones you like."
#let timeline-title = "Typst editor timeline | Awesome Typst Editors"
#let timeline-description(n) = "When each of " + str(n) + " Typst editors arrived, newest first."
#let kind-title = "Typst editors by kind: desktop, web, mobile, terminal | Awesome Typst Editors"
#let kind-description(n) = str(n) + " Typst editors grouped by kind: desktop, web, mobile and terminal."

#let link-code = "Code"
#let link-website = "Website"
#let link-forum = "Typst forum post"
#let link-reddit = "Reddit post"
#let discussion-heading = "Hearts and comments"
#let discussion-offline = "Hearts and comments show up on the live site."
#let discussion-open = "Open the discussion on GitHub"

#let editor-title(e) = if e.description == none {
  e.name + ": a Typst editor | Awesome Typst Editors"
} else {
  e.name + ": " + e.description.trim(".", at: end) + " | Awesome Typst Editors"
}
#let editor-description(e) = if e.description == none { e.name + " is a Typst editor." } else { e.description }

#let not-found-title = "Page not found | Awesome Typst Editors"
#let not-found-description = "This page doesn't exist. Every Typst editor is one click away."
#let not-found-heading = "This page doesn't exist"
#let not-found-link = "See all Typst editors"

#let readme-heading = "# Awesome Typst Editors [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)"
#let readme-tagline = "> A friendly list of Typst editors and apps, and the people who build them."
#let readme-browse(site-url) = "Browse every editor, and leave a heart for the ones you like, at [prajwal-svm.github.io/awesome-typst-editors](" + site-url + ")."
#let readme-rules = "This list includes editors that have been public for at least a month and have at least 50 stars on their code host. The site shows every editor that's been public for at least a month."
#let readme-contents = "Contents"
#let readme-contributing-heading = "Contributing"
#let readme-contributing(repo-url) = "Know an editor that's missing? Use the [add an editor form](" + repo-url + "/issues/new?template=add-editor.yml) or open a pull request that edits `data/editors.yaml`. This README is generated from that file, so please don't edit it by hand."
#let readme-license-heading = "License"
#let readme-license = "[CC0 1.0](LICENSE)"
#let readme-fallback-description(kind) = "A Typst " + kind + " editor"

#let screenshot-alt(name) = "Screenshot of " + name
#let screenshot-from = "Screenshot from "
#let screenshot-readme = "the project's README"
