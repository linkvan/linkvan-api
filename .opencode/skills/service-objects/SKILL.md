---
name: service-objects
description: Service object patterns, Result objects, and validation conventions for this Rails codebase
---

## Service Object Pattern

All services inherit from `ApplicationService` and follow this structure:

```ruby
class MyService < ApplicationService
  def initialize(arg1, arg2)
    super()
    @arg1 = arg1
    @arg2 = arg2
  end

  def call
    return Result.new(errors: ["validation error"]) unless valid?
    Result.new(data: result_data)
  end

  private

  def validate
    add_error("Invalid input") if invalid_condition?
  end
end
```

## Usage Pattern

```ruby
# Call service directly
result = MyService.call(arg1, arg2)

# Check for errors
if result.errors.any?
  # Handle errors
else
  # Use result.data
end
```

## Naming Convention

- Services use "Action + Service" pattern (e.g., `FacilitySerializer`)
- File names match class names: `facility_serializer.rb`
- Located in `app/services/` directory

## Result Pattern

- Services return `Result` objects
- `Result.new(errors: [...])` for validation failures
- `Result.new(data: ...)` for successful operations
- Check `result.errors.any?` to determine success/failure

## Validation in Services

- Use private `validate` methods for validation logic
- Use `add_error(message)` to collect validation errors
- Return early with error Result if validation fails
- Keep validation logic separate from business logic

## Error Handling

- Use `raise` for programmer errors
- Use `Result.new(errors: [...])` for service object validation failures
- Handle exceptions with `begin/rescue` blocks when necessary
- Log errors appropriately before re-raising if needed

## Testing Services

- Test files located in `spec/services/`
- Use `*_service_spec.rb` suffix (e.g., `facility_serializer_spec.rb`)
- Test both success and error paths
- Verify Result objects structure

## Important Notes

- Keep services focused on single responsibilities
- Avoid complex nested logic in services
- Use services to keep controllers thin
