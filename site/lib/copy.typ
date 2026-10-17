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
// Placeholder until Prajwal confirms the wording.
#let footer-line = "Made by Prajwal (prajwal-svm), who also builds Oleafly. Every editor gets the same card, and nothing is sorted by hearts."

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
