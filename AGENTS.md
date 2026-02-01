# AGENTS.md - Linkvan API Development Guide

This file provides essential information for agentic coding assistants working on the Linkvan API codebase.

## Essential Commands

### Testing
```bash
bin/rspec                                    # Run all tests
bin/rspec spec/models/facility_spec.rb      # Run single test file
bin/rspec spec/models/facility_spec.rb:42   # Run specific test by line
```

### Code Quality
```bash
bin/rubocop          # Lint Ruby code
bin/rubocop -a       # Auto-fix issues
bin/brakeman         # Security scan
```

### Database
```bash
rails db:create db:migrate db:seed db:reset
rails console
```

## Project Structure

- `app/models/` - ActiveRecord models
- `app/controllers/` - Request handlers
- `app/services/` - Business logic services
- `app/components/` - ViewComponents (namespaced)
- `spec/` - RSpec tests (mirrors app structure)
- `db/migrate/` - Database migrations
- `config/` - Application configuration

## Available Skills

This codebase includes specialized skills for detailed development guidance. Load them using the `skill` tool when needed:

- **rspec-testing** - RSpec patterns, test commands, and testing conventions
- **service-objects** - Service class structure, Result pattern, and validation
- **viewcomponent** - Component structure, naming conventions, and patterns
- **rails-models** - ActiveRecord patterns, validations, scopes, and enums
- **rails-controllers** - Controller patterns, service delegation, and HTTP conventions
- **rails-migrations** - Reversible migrations, indexes, and database constraints
- **rails-code-quality** - RuboCop metrics, Brakeman security, and code style

## Available Agents

This codebase includes specialized agents for Rails development workflows. Invoke them using the `@` mention or `Task` tool:

- **@rails-resource-builder** - Generate complete Rails resources (models, controllers, routes, tests)
  - Generates RESTful resources with proper validations, associations, and specs
  - Follows service delegation pattern in controllers
  - Creates FactoryBot factories and RSpec tests
  - Skills: rails-models, rails-controllers, rspec-testing

- **@rails-migration-manager** - Manage Rails migrations (create, run, rollback, troubleshoot)
  - Creates reversible migrations with indexes and constraints
  - Runs, rolls back, and monitors migrations
  - Handles schema changes and resolves conflicts
  - Skills: rails-migrations

- **@rails-test-runner** - Execute tests and report results
  - Runs all tests or specific tests by file/line/description
  - Reports test failures with detailed output
  - Does NOT modify code or fix tests
  - Skills: rspec-testing

- **@rails-code-auditor** - Review code for quality and Rails conventions
  - Runs RuboCop and Brakeman for quality/security
  - Reviews adherence to Rails patterns and conventions
  - Reports issues, suggests fixes only when requested
  - Skills: All pattern skills (context-dependent)

- **@rails-refactor** - Refactor code following Rails conventions
  - Extracts logic to service objects
  - Applies Rails conventions and removes code smells
  - Optimizes queries and improves performance
  - Ensures tests pass after refactoring
  - Skills: All pattern skills (context-dependent)

## Tech Stack

- Ruby 3.4.5, Rails 8.0.3 with PostgreSQL
- RSpec, FactoryBot, Shoulda Matchers (testing)
- RuboCop, Brakeman (quality/security)
- ViewComponent (UI components)
- Hotwire/Turbo (frontend)
- Devise (authentication), Pagy (pagination)

## Git Policy

**CRITICAL: Agents must never modify git history.** The following git operations are explicitly prohibited:

- `git add` or `git stage` - Agents must NOT stage changes
- `git reset HEAD` - Agents must NOT unstage changes
- `git commit` - Agents must NOT create commits
- `git commit --amend` - Agents must NOT amend commits
- `git rebase` - Agents must NOT perform rebases
- `git push` - Agents must NOT push to remote repositories
- Any other git history modification operations

**If agents require git operations:**
1. Complete all code changes using standard file tools (Read, Write, Edit)
2. Run tests and quality checks to verify the changes are correct
3. Ask the user to perform git staging, committing, or other git operations
4. Provide clear instructions on what commands to run and what changes to commit

**Rationale:** Git history modifications are destructive operations that should always be performed intentionally by the user. This policy prevents accidental data loss and ensures the user maintains full control over version control operations.

## Important Notes

- Active development on `develop` branch
- Admin interface at `/admin/dashboard`
- Always run tests and linting before committing
- ViewComponent tests use `type: :component`
- System specs use Capybara and Puma

## Development Plans

See `docs/plans/README.md` for:
- Active development plans and their status
- Implementation tracking and progress metrics
- Plan documentation patterns and templates

