# Local Production Environment Setup

This setup allows you to run a production-like environment locally for testing purposes. It mirrors the Heroku production environment but runs on your local machine.

## Prerequisites

- Docker and Docker Compose installed
- The application's development environment working

## Quick Start

### 1. Build the production images

```bash
./bin/docker/prod-build
```

### 2. Set up the environment

```bash
./bin/docker/prod-setup
```

### 3. Start the production environment

```bash
./bin/docker/prod-start
```

The application will be available at:

- **Main app**: <http://localhost:3001>
- **Admin panel**: <http://localhost:3001/admin>

## Available Commands

| Command | Description |
|---------|-------------|
| `./bin/docker/prod-build` | Build production Docker images |
| `./bin/docker/prod-setup` | Set up database and run migrations |
| `./bin/docker/prod-start` | Start the production environment |
| `./bin/docker/prod-stop` | Stop the production environment |
| `./bin/docker/prod-run <command>` | Run commands in production container |
| `./bin/docker/prod-clean` | Clean up production environment |

## Environment Variables

Copy the template and customize:

```bash
cp .env.production.template .env.production.local
```

Edit `.env.production.local` with your specific values, especially:

- `SECRET_KEY_BASE` - Generate with `rails secret`
- `RAILS_MASTER_KEY` - Copy from `config/master.key` if you have encrypted credentials

## Testing the Asset Pipeline Fix

To test the asset pipeline fix that resolved the Heroku crash:

1. Start the production environment:

   ```bash
   ./bin/docker/prod-start
   ```

2. Visit the admin panel:

   ```bash
   open http://localhost:3001/admin/facilities
   ```

3. Verify the logo loads correctly and no 500 errors occur

## Database Commands

```bash
# Create database
./bin/docker/prod-run rails db:create

# Run migrations
./bin/docker/prod-run rails db:migrate

# Seed database
./bin/docker/prod-run rails db:seed

# Rails console
./bin/docker/prod-run rails console

# Reset database
./bin/docker/prod-run rails db:drop db:create db:migrate
```

## Logs and Debugging

```bash
# View logs
docker-compose -f docker-compose.production.yml -p linkvan-prod logs -f web-prod

# Shell into production container
./bin/docker/prod-run bash

# Check asset compilation
./bin/docker/prod-run rails assets:precompile
```

## Differences from Development

- Assets are precompiled and served statically
- Production logging configuration
- Database optimizations
- No file watching or auto-reloading
- Runs on port 3001 (vs 3000 for development)
- Uses separate PostgreSQL database and port (35433 vs 35432)

## Cleanup

To completely remove the production environment:

```bash
./bin/docker/prod-clean
```

## Troubleshooting

### Asset Issues

If you encounter asset-related errors:

```bash
./bin/docker/prod-run rails assets:clobber
./bin/docker/prod-run rails assets:precompile
```

### Database Issues

```bash
./bin/docker/prod-run rails db:drop db:create db:migrate
```

### Container Issues

```bash
./bin/docker/prod-clean
./bin/docker/prod-build
./bin/docker/prod-setup
```
