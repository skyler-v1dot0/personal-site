# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Jekyll-based personal site (security research / infra engineering blog) built on `github-pages` gem, deployed via GitHub Pages to a custom domain (`skyverse.cloud`, see `CNAME`).

## Commands

```bash
bundle install                          # install gems (first run / after Gemfile changes)
bundle exec jekyll serve                # local dev server with live reload, http://localhost:4000
bundle exec jekyll build                # production build -> _site/ (CI sets JEKYLL_ENV=production)

# HTML validation (mirrors CI "html-proof" job — run after `jekyll build`)
htmlproofer _site/ --disable-external --checks "Links,Images,Scripts" --ignore-urls "/feed.xml"

# Dependency audit (mirrors CI "dependency-audit" job)
bundle-audit update && bundle-audit check --verbose
```

There is no JS/CSS build step — `assets/css/main.css` is hand-written and served as-is.

## CI/CD

Two workflows run on every push to any branch and on PRs to `main` (`.github/workflows/`):

- **CI** (`ci.yml`): `jekyll build` → upload `_site/` artifact → HTMLProofer against the built output → YAML lint on `_config.yml` and `_data/`. HTMLProofer only checks Links/Images/Scripts and skips external URLs.
- **Security** (`security.yml`): Gitleaks secrets scan (full git history via `fetch-depth: 0`) and `bundle-audit` against `Gemfile.lock`. Also runs weekly on a cron schedule.

When changing `_config.yml` or files under `_data/`, keep them YAML-lint clean (120-char line length, `true`/`false` truthy values).

## Architecture

Standard Jekyll layout/include structure:

- `_layouts/default.html` — base HTML shell (`head` + `header` + `<main>` + `footer` includes). All pages render through this, directly or via `page`/`post`. `<main>` gets class `full-bleed` instead of `container` when the page's frontmatter sets `full_bleed: true` (used by `index.html` so the hero image can run edge-to-edge).
- `_layouts/page.html` — wraps `default`; used for static pages (`about`, `blog`, `news`, `projects`) with a title/description header.
- `_layouts/post.html` — wraps `default`; used for every entry in `_posts/`, including CTF writeups (see below). Always links back to `/blog/`.
- `_includes/head.html`, `header.html`, `footer.html` — shared chrome. Nav links in `header.html` are hardcoded to `/news/`, `/projects/`, `/blog/`, `/about/`.
- `_includes/tag.html` — renders one `<span class="tag ...">`; applies a color class (`tag-ctf`, `tag-security`, `tag-cloud`) for known tag names, generic styling otherwise. Used by `_layouts/post.html` and `blog.html` — reuse it anywhere a post tag is rendered so color-coding stays consistent.

**Content model:**
- `_posts/` — all blog content lives here (`site.posts`), including CTF/vuln-research writeups, which are just posts tagged `ctf` (there is no separate CTF collection). `blog.html` (permalink `/blog/`) lists every post with a client-side tag filter (vanilla JS, no plugin) built from `site.tags`.
- `index.html` — homepage; just the hero image (`assets/images/website-image.png`) with a name/tagline overlay. It does not list posts.

**News aggregation (`/news/`):**
- `_data/news_sources.yml` — list of `{name, url}` feed sources (currently just The Hacker News). Add more sources here.
- `scripts/fetch_news.rb` — stdlib-only Ruby script (no Gemfile dependency) that fetches each source's RSS/Atom feed, merges + sorts items by date, and writes `_data/news.yml` (`updated_at` + `items: [{title, url, source, published}]`).
- `.github/workflows/news.yml` — runs the script every 3 hours (and on `workflow_dispatch`), commits `_data/news.yml` directly to `main` if it changed, using `chore: sync news feed [skip ci]` so it doesn't retrigger CI/security workflows. Requires the repo's default `GITHUB_TOKEN` workflow permission to be write (declared via `permissions: contents: write` in the workflow, which overrides the repo's read-only default).
- `news.html` reads `site.data.news.items` — titles/URLs are external, untrusted feed content, so they're rendered with Liquid's `escape` filter (defense against a compromised/malicious feed injecting markup).
- This is a static site with a native (non-Actions) GitHub Pages build (`legacy` build type — no custom Jekyll plugins run at build time), which is why news data is fetched out-of-band and committed as a data file rather than fetched at build time.

**Data-driven content:**
- `_data/projects.yml` — array of project entries (`name`, `description`, `github`, `url`, `tags`) rendered by `projects.md` into cards. This is the file to edit to add/update a project; no template changes needed for a new entry.

**Frontmatter conventions** for posts: `layout: post`, `title`, `date`, `description`, `tags` (array). CTF writeups just add a `ctf` tag alongside their other tags (e.g. `pwn`, `heap`) — tag membership drives both the `/blog/` filter and the tag color coding, there's no separate collection or flag.

## Site config

`_config.yml` has `title`, `description`, `url`, `baseurl`, and `author.{name,email,github,twitter}` left blank/empty — these are template placeholders. `header.html`/`footer.html` fall back to a placeholder site title and hide social links when these are empty strings. Fill these in `_config.yml` rather than hardcoding in templates.
