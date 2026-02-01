---
name: rails-controllers
description: Controller patterns, service delegation, strong parameters, and HTTP conventions for this Rails codebase
---

## Controller Naming

- Controllers use Plural PascalCase (e.g., `FacilitiesController`)
- File names match class names: `facilities_controller.rb`
- Located in `app/controllers/` directory

## Thin Controller Pattern

- Keep controllers thin, delegate logic to services
- Controllers should handle:
  - Request/response cycle
  - Parameter handling
  - Response formatting
  - Redirect/flow control

## Service Delegation

```ruby
def create
  result = FacilityCreateService.call(facility_params)

  if result.errors.any?
    render json: { errors: result.errors }, status: :unprocessable_content
  else
    render json: result.data, status: :created
  end
end
```

## Before Actions

- Use `before_action` for shared logic:
  ```ruby
  before_action :authenticate_user!
  before_action :set_facility, only: [:show, :update, :destroy]
  ```

## Strong Parameters

```ruby
def facility_params
  params.require(:facility).permit(:name, :address, :status)
end

def nested_params
  params.require(:facility).permit(:name, bookings_attributes: [:id, :date, :_destroy])
end
```

## HTTP Status Codes

- Return appropriate HTTP status codes:
  - `200 OK` - Successful GET/PUT/PATCH
  - `201 Created` - Successful POST
  - `204 No Content` - Successful DELETE
  - `400 Bad Request` - Invalid request
  - `401 Unauthorized` - Not authenticated
  - `403 Forbidden` - Not authorized
  - `404 Not Found` - Resource not found
  - `422 Unprocessable Content` - Validation errors
  - `500 Internal Server Error` - Server error

## Response Formats

```ruby
# JSON response
render json: @facility

# JSON with status
render json: @facility, status: :ok

# JSON with errors
render json: { errors: ["Validation failed"] }, status: :unprocessable_content

# Redirect
redirect_to @facility, notice: "Success"

# Render template
render :new
```

## Testing Controllers

- Test files located in `spec/controllers/`
- Use `*_controller_spec.rb` suffix
- Test actions, status codes, and responses
- Use RSpec request specs for API endpoints

## Example Controller

```ruby
class FacilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_facility, only: [:show, :update, :destroy]

  def index
    @facilities = Facility.all
    render json: @facilities
  end

  def show
    render json: @facility
  end

  def create
    result = FacilityCreateService.call(facility_params)

    if result.errors.any?
      render json: { errors: result.errors }, status: :unprocessable_content
    else
      render json: result.data, status: :created
    end
  end

  private

  def set_facility
    @facility = Facility.find(params[:id])
  end

  def facility_params
    params.require(:facility).permit(:name, :address, :status)
  end
end
```

## Important Notes

- Always use strong parameters
- Delegate business logic to services
- Return appropriate HTTP status codes
- Keep actions focused on request/response
