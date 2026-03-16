---
name: rails-code-quality
description: RuboCop metrics, Brakeman security, code style conventions, and quality checks for this Rails codebase
---

## Code Quality Commands

```bash
bin/rubocop          # Lint Ruby code
bin/rubocop -a       # Auto-fix issues
bin/brakeman         # Security scan
```

## Ruby Code Style

### Basic Style
- **ALWAYS** start with `# frozen_string_literal: true`
- Use double quotes for strings
- Use new hash syntax: `{ a: 1 }` not `{ :a => 1 }`
- Two spaces for indentation, no tabs
- No trailing whitespace
- Use `&&/||` instead of `and/or`
- Method definitions with parentheses: `def my_method(arg)` not `def my_method arg`

### Constants & Magic Numbers
- Define constants at class level using SCREAMING_SNAKE_CASE
- Avoid magic numbers, use named constants
- Freeze constants to prevent mutation:
  ```ruby
  MAX_ATTEMPTS = 5.freeze
  STATUS_CLASSES = {
    active: "success",
    pending: "warning"
  }.freeze
  ```

## RuboCop Metrics (Enforced)

These metrics are enforced by RuboCop in this codebase:

- **Method length**: max 50 lines
- **Class length**: max 300 lines
- **Cyclomatic complexity**: max 15
- **Perceived complexity**: max 12
- **AbcSize**: max 41 (excludes migrations)
- **Block length**: max 75 (excluded in specs)

## Running Quality Checks

```bash
# Check all code
bin/rubocop

# Check specific file
bin/rubocop app/models/facility.rb

# Auto-fix issues
bin/rubocop -a

# Auto-fix with safety level
bin/rubocop -a --safe

# Security scan
bin/brakeman

# Check for warnings only
bin/brakeman --no-pager --no-highlight --skip-warning-list
```

## Fixing RuboCop Issues

1. Run `bin/rubocop` to see issues
2. Run `bin/rubocop -a` to auto-fix
3. Manually fix remaining issues
4. Run `bin/rubocop` again to verify

## Security Best Practices (Brakeman)

- Never expose secrets or API keys
- Use strong parameters to prevent mass assignment
- Sanitize user input
- Use HTTPS in production
- Keep dependencies updated
- Run `bin/brakeman` regularly

## Code Organization

- Keep methods under 50 lines
- Keep classes under 300 lines
- Reduce complexity by extracting methods
- Use services for complex business logic
- Follow SOLID principles

## Naming Conventions

### Ruby/Rails
- Models: Singular PascalCase (e.g., `Facility`)
- Controllers: Plural PascalCase (e.g., `FacilitiesController`)
- Components: Namespace::Name (e.g., `Facilities::CardComponent`)
- Services: Action + Service (e.g., `FacilitySerializer`)
- Factories: `factory :name` (e.g., `factory :facility`)
- Tests: *_spec.rb suffix (e.g., `facility_spec.rb`)
- Constants: SCREAMING_SNAKE_CASE (e.g., `STATUS_CLASSES`)

## Error Handling

- Use `raise` for programmer errors
- Use `Result.new(errors: [...])` for service object validation failures
- Handle exceptions with `begin/rescue` blocks when necessary
- Log errors appropriately before re-raising if needed

## Pre-Commit Workflow

Always run before committing:

```bash
# Run tests
bin/rspec

# Run linter
bin/rubocop

# Run security scan
bin/brakeman

# Fix auto-fixable issues
bin/rubocop -a
```

## Important Notes

- Always run tests and linting before committing
- Follow Ruby style guide conventions
- Keep complexity low by extracting methods
- Use RuboCop metrics as guidelines
- Security scan with Brakeman regularly
