---
name: rails-migrations
description: Database migration patterns, reversible migrations, indexes, and conventions for this Rails codebase
---

## Migration Commands

```bash
rails db:create db:migrate db:seed db:reset rails console
rails db:migrate:status  # Check migration status
rails db:rollback        # Rollback last migration
rails db:migrate:redo    # Rollback and re-run
```

## Migration Structure

- Migrations located in `db/migrate/` directory
- Use timestamp prefix: `YYYYMMDDHHMMSS_migration_name.rb`
- Name migrations descriptively: `add_email_to_users.rb`

## Reversible Migrations

- Use `change` method instead of `up/down` when possible:
  ```ruby
  class AddEmailToUsers < ActiveRecord::Migration[8.0]
    def change
      add_column :users, :email, :string
    end
  end
  ```

## Creating Migrations

```bash
rails generate migration AddFieldToTable field:type
rails generate migration RemoveFieldFromTable field:type
rails generate migration CreateTableName field1:type field2:type
```

## Common Migration Patterns

### Add Column
```ruby
def change
  add_column :users, :email, :string, null: false
end
```

### Remove Column
```ruby
def change
  remove_column :users, :email, :string
end
```

### Add Index
```ruby
def change
  add_index :users, :email, unique: true
end
```

### Add Reference
```ruby
def change
  add_reference :bookings, :facility, foreign_key: true
end
```

### Add Foreign Key Constraint
```ruby
def change
  add_foreign_key :bookings, :facilities
end
```

### Create Table
```ruby
def change
  create_table :facilities do |t|
    t.string :name, null: false
    t.text :address
    t.timestamps
  end
end
```

## Best Practices

- Keep migrations reversible
- Use `change` method instead of `up/down`
- Add indexes for foreign keys and frequently queried columns
- Use `null: false` and foreign key constraints
- Use appropriate data types
- Include defaults when appropriate

## Adding Indexes

```ruby
# Single column index
add_index :users, :email

# Composite index
add_index :bookings, [:user_id, :facility_id]

# Unique index
add_index :users, :email, unique: true

# Index with name
add_index :users, :email, name: 'index_users_on_email_lower'
```

## Foreign Keys

```ruby
# Add reference with foreign key
add_reference :bookings, :facility, foreign_key: true

# Add foreign key constraint
add_foreign_key :bookings, :facilities

# Add foreign key with options
add_foreign_key :bookings, :facilities, on_delete: :cascade
```

## When to Use Up/Down

Use `up/down` when `change` doesn't support the operation:

```ruby
class ChangeUserEmailFormat < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      UPDATE users SET email = LOWER(email)
    SQL
  end

  def down
    # Cannot automatically rollback
    raise ActiveRecord::IrreversibleMigration
  end
end
```

## Important Notes

- Always test migrations in development
- Keep migrations small and focused
- Use `rails db:migrate:status` to check status
- Never modify existing migrations after deployment
- Use `null: false` for required fields
- Add indexes for performance
