---
name: viewcomponent
description: ViewComponent patterns, naming conventions, and structure for this Rails codebase
---

## ViewComponent Pattern

All components inherit from `ViewComponent::Base`:

```ruby
class Features::CardComponent < ViewComponent::Base
  def initialize(feature:)
    super()
    @feature = feature
  end

  def private_method
    # Helper methods
  end
end
```

## Naming Convention

- Components use `Namespace::Name` pattern (e.g., `Facilities::CardComponent`)
- File names match class names: `features/card_component.rb`
- Located in `app/components/` directory (namespaced)

## Component Structure

- Always call `super()` in `initialize`
- Use keyword arguments in `initialize` (e.g., `feature:`)
- Store arguments in instance variables with `@` prefix
- Define helper methods for complex logic in templates

## Directory Structure

```
app/components/
├── facilities/
│   └── card_component.rb
└── features/
    └── card_component.rb
```

## Testing Components

- Test files located in `spec/components/`
- Use `type: :component` in RSpec specs
- Test rendering output and state
- Test helper methods individually

## Usage in Views

```ruby
# Render component with arguments
<%= render Features::CardComponent.new(feature: @feature) %>

# Or with shorthand
<%= render Features::CardComponent.new(@feature) %>
```

## Best Practices

- Keep components small and focused
- Use helper methods for complex logic in views
- Avoid embedding business logic in components
- Components should receive data, not fetch it
- Use components to reduce partial duplication

## Component Patterns

- Card components for displaying items
- List components for collections
- Form components for reusable form fields
- Button components for UI actions

## Important Notes

- ViewComponent is used for UI components in this codebase
- Components are namespaced by domain (e.g., `Features::`, `Facilities::`)
- Test components using `type: :component` in RSpec
