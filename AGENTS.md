# AGENTS.md — Linkvan API

Rails 8.1 · Ruby 3.4.13 · HTML is admin-only (`/admin/dashboard`); the rest is JSON API.

- **Git**: never rewrite published history or push to `develop`/`master`. Branch, then commit and push
  when the task calls for it; ask before opening a PR or merging. Conventional commits, one change each.
- **Tests**: `bin/rspec` · `bin/rspec spec/system` · `bin/ci` (local full CI) · docker: `bin/docker/test`
  · `bin/rails`.
- **Traps**: some specs need `JWT_KEY` (`bin/ci` and the docker path default it). `db:prepare` seeds a new
  database — use `db:create db:migrate` for test databases.
- **Assets**: CSS entrypoint `app/assets/stylesheets/application.bulma.scss` → `builds/application.css`
  via `yarn build:css` (cssbundling, part of `assets:precompile`). No bundler, no CDN. On a fresh checkout
  build the CSS (`yarn build:css` or `bin/dev`) before loading a page.
- **Conventions**: the repo skills (rails-models, rails-controllers, service-objects, viewcomponent,
  rspec-testing, rails-migrations, rails-code-quality). ViewComponent specs are `type: :component`.
- **Plans**: `docs/plans/<slug>/{plan,tracker}.md`, indexed in `docs/plans/README.md`.
- **Deploy**: Heroku buildpack, auto-deploy from `master`; the `Procfile` release phase runs `db:migrate`.
