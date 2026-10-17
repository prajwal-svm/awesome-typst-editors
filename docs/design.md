# Awesome Typst Editors: design

Status: draft for Prajwal's approval, 2026-10-17.

## What this is and why

Awesome Typst Editors is a one-site celebration of every Typst editor and the people who build them. New Typst editors show up every couple of weeks. Instead of counting them, this site welcomes each one: every editor gets the same card, people can leave a heart and a comment, and nothing is ranked.

It's for Typst users and researchers looking for an editor that fits how they write, and for the builders, who get a friendly place where their work is shown and thanked.

The site is written in Typst, to show what Typst can do, and costs nothing to run.

## Goals

- Show every Typst editor that has been public for at least a month, each with the same card and the same rules.
- Help people find an editor: browse A to Z, by arrival date, or by kind (desktop, web, mobile, terminal).
- Let people leave hearts and comments with their GitHub account.
- Cost $0 to run, with no server of its own.
- Show up in search for "Typst editor" style queries and for each editor's name.
- Double as an awesome-style list in the repo README.

## Non-goals

- No rankings, winners, "most loved" lists, or sorting by hearts.
- No star ratings or reviews beyond plain comments.
- No backend, database, or user accounts of its own.
- No feature comparison table (could come later, not now).
- Not a marketing page for Oleafly.

## Anti-goals (failure even if it technically works)

- It reads as Oleafly marketing in disguise.
- It feels like a contest or leaderboard.
- It mocks or belittles any editor or builder. Closed-source and tiny projects get the same respectful card as everyone else.
- It shows wrong or stale information about someone's project with no way to fix it.
- It starts costing money or needs a server.

## Decided by Prajwal

1. A celebration of Typst editors and their builders, not a counter or a ranking.
2. Audience: Typst users and researchers.
3. Hearts on each editor. No ranking, no winners.
4. Hearts are GitHub reactions, so leaving one needs a GitHub sign-in. Comments go through GitHub Discussions.
5. The page is written in Typst. It must cost nothing to run, with no server.
6. All three views: A to Z, timeline, and by kind.
7. Name: Awesome Typst Editors. Repo: `awesome-typst-editors` on Prajwal's personal GitHub account, not the Oleafly org. The README is an awesome-style list with the Awesome badge.
8. Oleafly is listed exactly like every other editor. A small footer line says Prajwal made the site.
9. The list starts from the existing community counter's data plus each editor's own public information. SEO matters.
10. The project lives at `~/Codespace/awesome-typst-editors`.
11. The repo goes on the `prajwal-svm` account, so the address is `https://prajwal-svm.github.io/awesome-typst-editors/`.
12. No submission to the main Awesome list. The README keeps the badge and stays generated from the data.
13. Every card gets the same designed image. GitHub's automatic repo images aren't used, because they show star and fork counts.
14. Scope: standalone Typst editors and apps, including the official typst.app and editors the counter is missing. Plugins for general-purpose editors (VS Code, Neovim, Emacs, Zed) are out. Search for missing editors before launch, so Oleafly isn't the only entry added by hand.
15. License: CC0 for the list and the site.
16. Who's included is split. The site shows every in-scope editor that has been public for at least a month, closed-source ones included. The README's awesome list only includes editors that also have at least 50 stars on their code host.

## The site

### Views and addresses

Three views of the same cards, switched with plain links styled as a segmented control at the top. The current view gets a background tint.

- A to Z, at `/`: one even grid, sorted by name, ignoring case.
- Timeline, at `/timeline/`: newest arrival first, grouped by month. Each entry reads like a small happy event ("Arrived 17 Oct 2026").
- By kind, at `/kind/`: rows for desktop, web, mobile and terminal. An editor with more than one kind appears in each of its rows.

Each editor also gets its own page at `/editors/<slug>/` (design call, for SEO and for the comments widget).

### The card

Same card everywhere:

- card image, in the same generated style for every editor
- name
- one-line description
- who built it (the repo owner, or the name the project uses)
- small chips: kind, platforms, and "Open source" when the project has an open-source license (design call). A public repo with no license, like TypstEdit's, gets no chip. Licenses GitHub can't identify, and projects off GitHub (Typesetter on Codeberg, Platen on tangled.org), get checked by hand.
- heart count and comment count

The whole card links to the editor's page.

### Editor page

- larger card image, name, description, builder
- links: code, website, Typst forum post, Reddit post (whichever exist)
- arrival date
- the comments widget with hearts and comments (see below)

### Header and footer

- Header: site name, an "Add an editor" link, and a hero line: "N Typst editors and counting" with "Built by people who love Typst. Leave a heart for the ones you like." N comes from the data.
- Footer, as Prajwal confirmed it: "Made by Prajwal (prajwal-svm)."
- Footer also links to "Fix or remove an editor".

## Hearts and comments

- Each editor has one GitHub Discussion in the `awesome-typst-editors` repo, in a category named "Editors". The category uses GitHub's announcement format, so only maintainers can start discussions while anyone can react and comment.
- The editor page embeds giscus (design call), a free widget that shows a GitHub Discussion on a web page and lets visitors sign in with GitHub to react and comment. Settings: specific-term mapping by the editor's slug, strict matching, reactions on, lazy loading, theme following the site's light or dark mode.
- Discussions are created ahead of time by a script, one per editor, so every card has counts and a link from day one. The pre-created discussions must match what giscus looks up (the title, and with strict matching, the hash marker giscus expects in the body).
- Heart count on a card is the number of heart reactions on the discussion's opening post. Comment count is the number of comments on the discussion.
- giscus shows all eight GitHub reactions. Only hearts count on the cards.
- Counts are fetched at build time, so cards can lag up to an hour behind the live discussion.
- Prajwal moderates the discussions with GitHub's normal tools.

## Data

- Source of truth: `data/editors.yaml` in the repo (design call). Typst reads YAML directly.
- Fields per editor: `name`, `slug`, `arrived` (date), `kinds` (list of desktop, web, mobile, terminal), `platforms`, `description`, `builder`, `source`, `homepage`, `forum`, `reddit`, `stars` for code hosts the build can't query (it fetches GitHub and Codeberg stars itself), and `license` where the code host can't detect it. Blank values count as missing. An unknown field, or a value of the wrong type, stops the build with a message naming the editor.
- Seed: the 25 entries in `data.csv` from https://github.com/sermuns/days-since-last-typst-editor (WTFPL, so reuse needs no credit), as of 2026-10-17. Its columns are date, name, source_code_url, reddit_url and typst_forum_url. Add Oleafly the same way: arrived 2026-07-05 (v0.1.0, its first public release), source https://github.com/Oleafly/Oleafly, forum https://forum.typst.app/t/10129.
- `arrived` means the date the editor first went public: its first public release or its first announcement, whichever came first. Check every seed date against the project's own release history (design call). The seed is sometimes off. It lists Typstwriter as September 2026, but its repo dates from April 2024 and v0.1 was on PyPI in June 2024. Keep a seed date only when nothing earlier can be found. Entries that can only be checked on Reddit go on a list for Prajwal to check by hand, since Reddit blocks automated reading.
- Kinds, platforms, descriptions and builders are filled in by hand from each project's own README or announcement, since the seed doesn't have them. Descriptions stay factual and short.
- Build-time data: a script in the workflow fetches, for GitHub-hosted projects, the repo description, owner and license, and for every editor, the discussion's heart and comment counts. It writes `data/generated.json`, which Typst reads next to `editors.yaml`. Hand-written fields in `editors.yaml` win over fetched ones.
- Card images: a screenshot from the project's README or a capture of its website, listed in `data/screenshots.yaml` and credited on the editor page. Editors without one get a plain banner in the site's style, showing the name and kind. A builder can ask for a screenshot to be removed or changed.

### Who's included

- The site: every in-scope editor whose `arrived` date is at least one month before the build. Newer editors stay in the data and appear on their own once they're a month old. As of 2026-10-17 that holds back LeftBlank (public since 1 Oct) until early November.
- The README: the same rule, plus at least 50 stars on the editor's code host. Editors with no public code never appear there. As of 2026-10-17, 10 editors qualify: Collabst, Typesetter, Texpile, Oleafly, Katvan, Typstwriter, Hilbert, Typstify, TypstEdit and InkPond.
- Both lists are recomputed on every build. The hero count ("N Typst editors and counting") is the number of editors on the site.

### Adding, fixing and removing editors

- "Add an editor" opens a GitHub issue form (name, link to code or website, announcement post, kinds, platforms, one-line description). Prajwal reviews it and adds the entry. Pull requests that edit `data/editors.yaml` are welcome too.
- "Fix or remove an editor" opens a second issue form. Requests from an editor's builder are honored.
- A weekly job compares names in the counter's `data.csv` with `editors.yaml` and opens (or updates) one issue listing editors that are missing (design call). Editors that were checked and left out go in `data/counter-skip.yaml` with the reason, and the job skips them. Once nothing is missing, it closes the issue. It never adds anything by itself.

## README (the awesome list)

- Generated from the same data, so the site and the list never drift apart.
- Heading with the Awesome badge, a one-line description, a link to the site, then sections by kind with lines in the form `- [Name](link) - One-line description.`
- Repo topics: `awesome`, `awesome-list`, `typst`.
- Not submitted to the main Awesome list, whose rules want a hand-written, curated README. The badge stays. `awesome-lint` is optional. If it's used, mind its rule against linking the same address twice: an editor with several kinds appears once in the README, under its first kind.

## Build and hosting

- Public repo, GitHub Pages, GitHub Actions, GitHub Discussions and giscus.app. All free. No custom domain: the address is `https://prajwal-svm.github.io/awesome-typst-editors/`. A custom domain can be added later.
- License: CC0 for everything in the repo, in place before the first public push, except the screenshots, which belong to their projects, and the two Lucide icons, which are ISC.
- The page is built the way the counter site is built, which already works: `typst compile main.typ . --format bundle --features bundle,html`, set up with `typst-community/setup-typst` and deployed with `actions/deploy-pages`. Pin the Typst version instead of floating on latest.
- Workflow triggers: push to main, an hourly schedule, and manual runs. Steps: check out, fetch data and counts, compile with Typst, upload the Pages artifact, deploy.
- The README is regenerated on every build and committed only when its text changes, which happens when the data changes or an editor crosses the 50-star line.

## SEO

- Every page has its own title, meta description and canonical address. Editor pages read like "Typesetter: a Typst editor for GNOME and Linux | Awesome Typst Editors".
- Open Graph and Twitter card tags. A site-wide social image, and the editor's card image on editor pages.
- Structured data: an ItemList on view pages and a SoftwareApplication on each editor page. No ratings in the structured data, since hearts aren't ratings.
- `sitemap.xml` and `robots.txt`.
- Static HTML that works without JavaScript. The only script is giscus on editor pages.

## Constraints

- Typst builds the pages. Typst can't make network requests, so fetching data is done by a shell script in the workflow using `gh api` and `jq` (and `yq`, which GitHub's Ubuntu runners include).
- No co-author or tool attribution lines of any kind in commits, pull requests, the README, docs or the site.
- No outlines or focus rings on any element. Keyboard focus is shown with a background tint or a border colour change.
- Page text and README copy get a plain-language editing pass before they ship.
- Stage files by explicit path. Never `git add -A` or `git add .`.
- Accessible basics: alt text on every image, readable contrast in light and dark mode, real links for the view switcher.

## Design calls (made while writing this, open to change)

- giscus for hearts and comments on editor pages, with card counts refreshed by the hourly build.
- Separate addresses for each view and each editor, for search.
- `data/editors.yaml` as the data file, with a generated JSON file for fetched data.
- Pre-created discussions in an announcement-format "Editors" category.
- Issue forms for adding and fixing editors.
- The weekly check against the counter's data.
- Including closed-source editors with the same card, minus the "Open source" chip.
- The "Open source" chip only for projects with an open-source license.
- Checking every arrival date against each project's release history.
- Using the `arrived` date for the one-month rule on both the site and the README.
- Structured data without ratings.

## Left to the builder

- Visual styling within the direction of the mockups in `docs/mockups/`: card grid, segmented view switcher, red heart, light and dark themes. The mockups are HTML fragments from the design session. They rely on a mockup frame's colour variables, so read them for layout rather than opening them in a browser. Their names, counts and comments are placeholders.
- Which Typst version to pin, as long as it supports the bundle and HTML export used above.
- Slug rules, image sizes, and how the generated card images look.
- How `sitemap.xml` and the head tags get produced (in Typst if it can, otherwise a small post-processing step in the workflow).
- Workflow details: schedule minute, permissions, caching.

## Known limits and risks

- Typst's HTML export is experimental. Check first, as a quick throwaway test, that it can emit the head tags (title, meta description, Open Graph, structured data) and the giscus script tag. If it can't, add a post-processing step to the workflow.
- GitHub pauses scheduled workflows in a public repo after 60 days without repo activity. GitHub emails a warning first, and turning it back on takes one click in the Actions tab.
- Someone with several GitHub accounts can leave several hearts. With nothing ranked, there's little reason to.
- The seed data is only as complete as the counter. The weekly check and the issue forms cover new editors.
