---
name: ruby-gem-update
description: Standardized Ruby gem update workflow with version checking, breaking change analysis, security advisory detection, and testing
license: MIT
compatibility: opencode
metadata:
  audience: developers
  language: ruby
---

## When to Use This Skill

- User asks to update a gem (e.g., "update puma", "upgrade faker", "bump devise version")
- Performing routine gem maintenance
- Responding to security advisories
- User wants to check if a gem needs updating

## Prerequisites

- This skill works with Ruby/Rails projects using Bundler
- Test command: `bin/rspec` (per AGENTS.md conventions)

## Complete Workflow

### Phase 1: Discovery

#### Step 1.1: Identify Current Version
- Read the Gemfile to find the gem and its current version constraint
- Also check `.ruby-lsp/Gemfile.lock` if present
- Note the current installed version from Gemfile.lock

#### Step 1.2: Check if Gem is Already a Dependency
Before adding or updating a gem explicitly in Gemfile, check Gemfile.lock to see if it's already pulled in as a dependency:
- If the gem appears under another gem's dependencies, it's already installed
- Only add/update explicitly if:
  - The user specifically requests it
  - There's a version constraint conflict that requires it
  - The gem needs a different version than what the dependency pulls in

#### Step 1.3: Check RubyGems for Latest Version
- Fetch: `https://rubygems.org/gems/<gem-name>`
- Record:
  - Latest version number
  - Required Ruby version
  - License
  - Runtime dependencies

#### Step 1.4: Check GitHub Release Notes
- Fetch: `https://github.com/<owner>/<repo>/releases`
- Look for:
  - Breaking changes between current and latest version
  - Deprecated/removed features
  - Security fixes
  - Ruby version requirement changes
- Check major versions (v6.x → v7.x) carefully for breaking changes

### Phase 2: Security Advisory Check

#### Step 2.1: Check RubySec Advisories
- Fetch: `https://rubysec.com/` or search for advisories on the gem
- Check: `https://github.com/rubygems/rubygems/tree/master/security`
- Also check: Gem's GitHub security tab

#### Step 2.2: Evaluate Risk
- If security advisory exists:
  - Note severity (Critical/High/Medium/Low)
  - Determine if update is urgent
- If no advisory, proceed with normal update process

### Phase 3: Breaking Change Analysis

#### Step 3.1: Parse Release Notes
For each version between current and latest:
- Look for "Breaking Changes" sections
- Note renamed APIs (e.g., `on_worker_boot` → `before_worker_boot`)
- Note removed deprecated features
- Note configuration changes

#### Step 3.2: Check Codebase Usage
- If deprecated features found in release notes:
  - Search codebase with grep for the deprecated API
  - Note what needs to be updated
  - Prepare migration steps

### Phase 4: Planning

#### Step 4.1: Create Update Plan
Present to user with:
- Current version vs latest version
- Version type (patch/minor/major)
- Ruby requirement compatibility
- Breaking changes found
- Security advisories (if any)
- Code changes needed (if any)
- Proposed steps

#### Step 4.2: Get User Approval
Wait for user confirmation before proceeding with:
- Gemfile changes
- Bundle updates
- Code migrations

### Phase 5: Execution

#### Step 5.1: Update Gemfile
- Edit Gemfile to change version constraint
- Use pessimistic version constraint for minor updates: `~> X.Y`
- Use specific version for major updates: `= X.0.0`

#### Step 5.2: Run Bundle Update
```bash
bundle update <gem-name>
```

#### Step 5.3: Verify Installation
```bash
bundle exec <gem-name> --version
```
Or for gems without CLI:
```bash
bundle exec ruby -e "require '<gem-name>'; puts <GemName>::VERSION"
```

#### Step 5.4: Run Tests
```bash
bin/rspec
```

### Phase 6: Reporting

#### Step 6.1: Report Results
- New version installed
- Test results (pass/fail)
- Any issues encountered

#### Step 6.2: Handle Failures
If tests fail:
1. Analyze failure message
2. Check if related to gem update
3. If breaking change caused failure:
   - Document the issue
   - Suggest fix to user
   - Do NOT proceed without user approval

## Version Constraint Guide

| Update Type | Constraint Example | Notes |
|-------------|---------------------|-------|
| Patch only | `~> 1.0.0` | Allows 1.0.x |
| Minor | `~> 1.4` | Allows 1.x (x >= 4) |
| Major | `= 2.0.0` | Lock to specific version |
| Latest | `~> 3.6` | Allows any 3.x |

## Common Version Upgrade Patterns

### Minor/Patch Updates
- Generally safe
- Run tests to verify
- Check release notes for any notable changes

### Major Updates
- Review breaking changes carefully
- May require code updates
- Test thoroughly
- Consider incremental updates (e.g., 6.x → 7.x → 8.x)

### Security Updates
- Prioritize based on severity
- May require immediate action
- Check for exploit availability

## Example: Complete Update Workflow

```
User: Update puma

Assistant (using this skill):
1. Finds current: puma ~> 6.4.2
2. Checks RubyGems: latest 7.2.0
3. Checks GitHub releases:
   - v7.0.0: Breaking changes (hook renames, Ruby 3.0+)
   - v7.1.0: Bugfixes
   - v7.2.0: Performance improvements
4. Checks security: None found
5. Checks codebase: config/puma.rb uses no deprecated hooks
6. Presents plan to user

User: proceed

Assistant:
1. Updates Gemfile: puma ~> 7.2
2. bundle update puma
3. Verifies: puma 7.2.0
4. bin/rspec → 1914 examples, 0 failures
5. Reports success
```

## Important Notes

1. **Always get user approval** before making changes
2. **Check Ruby version compatibility** before major updates
3. **Review breaking changes** for major version jumps
4. **Run tests** after every update
5. **Report results** clearly to user

## Testing

After any gem update, always run:
```bash
bin/rspec
```

This follows the project's AGENTS.md convention for test execution.

## Error Handling

- If bundle update fails: Analyze error, check gem dependencies
- If tests fail: Investigate cause, report to user
- If breaking changes found: Stop and consult user before proceeding
