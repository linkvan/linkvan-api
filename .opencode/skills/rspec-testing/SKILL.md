---
name: rspec-testing
description: RSpec testing patterns, conventions, and test commands for this Rails codebase
---

## Testing Commands

```bash
bin/rspec                                    # Run all tests
bin/rspec spec/models/facility_spec.rb      # Run single test file
bin/rspec spec/models/facility_spec.rb:42   # Run specific test by line
bin/rspec spec/models/facility_spec.rb -e "validates name presence"  # Run by description
bin/rspec spec/models/                      # All model specs
bin/rspec spec/services/facility_serializer_spec.rb  # Specific service spec
```

## Testing Patterns

- Use RSpec's `describe` for context and `it` for examples
- Prefer `expect(x).to eq(y)` over `expect(x) == y`
- Use `let` for lazy evaluation, `let!` for immediate
- Use `subject` for the main object being tested
- Use shared contexts with `it_behaves_like` for repeated patterns

## Testing Structure

- Test files use `*_spec.rb` suffix (e.g., `facility_spec.rb`)
- Test directory mirrors app structure:
  - `spec/models/` - Model tests
  - `spec/services/` - Service tests
  - `spec/controllers/` - Controller tests
- ViewComponent tests use `type: :component`
- System specs use Capybara and Puma

## Example Test Pattern

```ruby
RSpec.describe Facility do
  subject(:facility) { create(:facility, :with_verified) }

  describe "#managed_by?" do
    it "returns true for admin users" do
      expect(facility.managed_by?(admin_user)).to be true
    end
  end
end
```

## Factory Usage

- Use FactoryBot for test data
- Define factories with `factory :name` (e.g., `factory :facility`)
- Use traits with `:trait_name` syntax (e.g., `:with_verified`)

## Important Notes

- Always run tests before committing: `bin/rspec`
- Use factory-bot gem for test fixtures
- Test coverage should mirror application structure
