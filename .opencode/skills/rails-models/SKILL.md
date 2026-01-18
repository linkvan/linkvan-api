---
name: rails-models
description: ActiveRecord model patterns, validations, scopes, and conventions for this Rails codebase
---

## Model Naming

- Models use Singular PascalCase (e.g., `Facility`)
- File names match class names: `facility.rb`
- Located in `app/models/` directory

## Validations

- Use ActiveRecord validations for model-level validation:
  ```ruby
  validates :name, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  ```

## Scopes

- Use scopes for complex queries:
  ```ruby
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }
  ```

## Enums

- Use enum for fixed state fields:
  ```ruby
  enum status: { pending: 0, active: 1, archived: 2 }
  ```

## Callbacks

- Use callbacks sparingly
- Prefer explicit methods over callbacks
- Keep callback logic simple and focused

## Associations

- Define standard ActiveRecord associations
- Use proper foreign key conventions
- Consider inverse_of for better performance

## Model Methods

- Define business logic as instance methods
- Use class methods for collection operations
- Keep methods small and focused

## Testing Models

- Test files located in `spec/models/`
- Use `*_spec.rb` suffix (e.g., `facility_spec.rb`)
- Test validations, scopes, and custom methods
- Use factories for test data

## Example Model

```ruby
class Facility < ApplicationRecord
  has_many :bookings

  validates :name, presence: true
  validates :status, presence: true

  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  enum status: { pending: 0, active: 1, archived: 2 }

  def active?
    status == 'active'
  end
end
```

## Important Notes

- Keep database logic in models
- Avoid complex business logic in models (use services)
- Use factories for test fixtures
- Always run model tests after changes
