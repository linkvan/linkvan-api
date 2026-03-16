# AGENTS.md - Linkvan API

## Git Policy

**CRITICAL: Agents must never modify git history.**

- Prohibited: `git add`, `git commit`, `git rebase`, `git push`, etc.
- If git operations are needed, ask the user to perform them.

## Conventions

- Active development branch: `develop`
- Admin interface: `/admin/dashboard`
- ViewComponent tests: `type: :component`
- System specs: Capybara + Puma
