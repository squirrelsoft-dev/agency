# Project Context: Database & ORM Detection

Detect database system and ORM/query builder to handle migrations, schema changes, and database queries correctly.

## Detection Strategy

Check for database and ORM tools in order of likelihood:

### 1. Prisma (Node.js/TypeScript ORM)

**Primary Indicators**:
```bash
# Check package.json
grep '"@prisma/client"' package.json || grep '"prisma"' package.json
```

**Secondary Indicators**:
- `prisma/schema.prisma` file
- `prisma/migrations/` directory
- `node_modules/@prisma/client`
- `package.json` scripts: `prisma generate`, `prisma migrate`

**Schema File**: `prisma/schema.prisma`

**Common Commands**:
```bash
# Generate client
npx prisma generate

# Create migration
npx prisma migrate dev --name [migration_name]

# Apply migrations
npx prisma migrate deploy

# Studio (GUI)
npx prisma studio

# Reset database
npx prisma migrate reset
```

**Database Detection**:
```prisma
// Check datasource in schema.prisma
datasource db {
  provider = "postgresql"  // or mysql, sqlite, sqlserver, mongodb
  url      = env("DATABASE_URL")
}
```

**ORM**: `Prisma`
**Databases**: PostgreSQL, MySQL, SQLite, SQL Server, MongoDB, CockroachDB
**Migration**: Built-in migration system

---

### 2. Drizzle ORM (Node.js/TypeScript)

**Primary Indicators**:
```bash
# Check package.json
grep '"drizzle-orm"' package.json
```

**Secondary Indicators**:
- `drizzle.config.ts` or `drizzle.config.js`
- `drizzle/` directory with schema files
- Schema files: `*.schema.ts` or defined in `src/db/schema.ts`
- `drizzle-kit` for migrations

**Common Commands**:
```bash
# Generate migrations
npx drizzle-kit generate:pg  # PostgreSQL
npx drizzle-kit generate:mysql  # MySQL
npx drizzle-kit generate:sqlite  # SQLite

# Apply migrations
npx drizzle-kit push:pg

# Studio (GUI)
npx drizzle-kit studio
```

**Database Detection**:
```typescript
// Check imports in schema files
import { pgTable } from 'drizzle-orm/pg-core';  // PostgreSQL
import { mysqlTable } from 'drizzle-orm/mysql-core';  // MySQL
import { sqliteTable } from 'drizzle-orm/sqlite-core';  // SQLite
```

**ORM**: `Drizzle ORM`
**Databases**: PostgreSQL, MySQL, SQLite
**Migration**: drizzle-kit

---

### 3. Supabase (PostgreSQL + Client)

**Primary Indicators**:
```bash
# Check package.json
grep '"@supabase/supabase-js"' package.json
```

**Secondary Indicators**:
- `supabase/` directory
- `supabase/migrations/` directory
- `.env` with `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- Often paired with Prisma or Drizzle

**Common Commands**:
```bash
# Initialize Supabase
npx supabase init

# Start local Supabase
npx supabase start

# Create migration
npx supabase migration new [migration_name]

# Apply migrations
npx supabase db push

# Reset database
npx supabase db reset
```

**Database**: Always PostgreSQL (Supabase is PostgreSQL-as-a-Service)

**Platform**: `Supabase`
**ORM**: Often used with Prisma or Drizzle
**Database**: PostgreSQL
**Migration**: Supabase CLI

---

### 4. TypeORM (Node.js/TypeScript)

**Primary Indicators**:
```bash
# Check package.json
grep '"typeorm"' package.json
```

**Secondary Indicators**:
- `ormconfig.json` or `data-source.ts`
- Entity files with `@Entity()` decorator
- `src/entities/` or `src/models/` directory
- Migration files in `src/migrations/`

**Common Commands**:
```bash
# Run migrations
npx typeorm migration:run

# Revert migration
npx typeorm migration:revert

# Generate migration
npx typeorm migration:generate -n [MigrationName]

# Create migration
npx typeorm migration:create -n [MigrationName]

# Sync schema (dev only)
npx typeorm schema:sync
```

**Database Detection**:
```typescript
// Check data-source.ts or ormconfig.json
type: "postgres"  // or mysql, mariadb, sqlite, mssql, mongodb
```

**ORM**: `TypeORM`
**Databases**: PostgreSQL, MySQL, MariaDB, SQLite, SQL Server, MongoDB
**Migration**: Built-in migration system

---

### 5. Sequelize (Node.js)

**Primary Indicators**:
```bash
# Check package.json
grep '"sequelize"' package.json
```

**Secondary Indicators**:
- `.sequelizerc` configuration
- `models/` directory with model definitions
- `migrations/` directory
- `seeders/` directory
- Database driver: `pg`, `mysql2`, `sqlite3`, `tedious`

**Common Commands**:
```bash
# Run migrations
npx sequelize-cli db:migrate

# Undo migration
npx sequelize-cli db:migrate:undo

# Create migration
npx sequelize-cli migration:generate --name [migration-name]

# Run seeders
npx sequelize-cli db:seed:all
```

**Database Detection**:
```javascript
// Check config/config.json or models/index.js
dialect: "postgres"  // or mysql, sqlite, mssql
```

**ORM**: `Sequelize`
**Databases**: PostgreSQL, MySQL, MariaDB, SQLite, SQL Server
**Migration**: sequelize-cli

---

### 6. Django ORM (Python)

**Primary Indicators**:
```bash
# Check for Django
test -f manage.py && grep -i "django" requirements.txt
```

**Secondary Indicators**:
- `models.py` files in apps
- `migrations/` directories in each app
- `settings.py` with `DATABASES` configuration

**Common Commands**:
```bash
# Create migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Show migrations
python manage.py showmigrations

# SQL for migration
python manage.py sqlmigrate [app_name] [migration_number]

# Create superuser
python manage.py createsuperuser
```

**Database Detection**:
```python
# Check settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',  # or mysql, sqlite3, oracle
    }
}
```

**ORM**: `Django ORM` (built-in)
**Databases**: PostgreSQL, MySQL, SQLite, Oracle
**Migration**: Django migrations (built-in)

---

### 7. SQLAlchemy (Python)

**Primary Indicators**:
```bash
# Check requirements
grep -i "sqlalchemy" requirements.txt || grep -i "sqlalchemy" pyproject.toml
```

**Secondary Indicators**:
- `models.py` or `database.py` with SQLAlchemy imports
- `alembic/` directory (migration tool)
- `alembic.ini` configuration
- Base model extending `declarative_base()`

**Common Commands**:
```bash
# Create migration
alembic revision --autogenerate -m "[message]"

# Apply migrations
alembic upgrade head

# Downgrade
alembic downgrade -1

# Show current version
alembic current

# History
alembic history
```

**Database Detection**:
```python
# Check database URL in config
DATABASE_URL = "postgresql://..."  # or mysql, sqlite
```

**ORM**: `SQLAlchemy`
**Databases**: PostgreSQL, MySQL, SQLite, Oracle, SQL Server
**Migration**: Alembic

---

### 8. Eloquent ORM (Laravel/PHP)

**Primary Indicators**:
```bash
# Check for Laravel
test -f artisan && grep '"laravel/framework"' composer.json
```

**Secondary Indicators**:
- `database/migrations/` directory
- `app/Models/` directory with Eloquent models
- `database/seeders/` directory
- `config/database.php`

**Common Commands**:
```bash
# Run migrations
php artisan migrate

# Rollback
php artisan migrate:rollback

# Create migration
php artisan make:migration create_users_table

# Create model with migration
php artisan make:model User -m

# Seed database
php artisan db:seed

# Fresh migration (drop all + migrate)
php artisan migrate:fresh
```

**Database Detection**:
```php
// Check .env or config/database.php
DB_CONNECTION=mysql  // or pgsql, sqlite, sqlsrv
```

**ORM**: `Eloquent` (Laravel built-in)
**Databases**: MySQL, PostgreSQL, SQLite, SQL Server
**Migration**: Laravel migrations (built-in)

---

### 9. ActiveRecord (Ruby on Rails)

**Primary Indicators**:
```bash
# Check for Rails
test -f bin/rails || test -f config/application.rb
```

**Secondary Indicators**:
- `db/migrate/` directory
- `app/models/` with Rails models
- `db/schema.rb` or `db/structure.sql`
- `config/database.yml`

**Common Commands**:
```bash
# Run migrations
rails db:migrate

# Rollback
rails db:rollback

# Create migration
rails generate migration AddNameToUsers name:string

# Reset database
rails db:reset

# Seed
rails db:seed

# Show status
rails db:migrate:status
```

**Database Detection**:
```yaml
# Check config/database.yml
adapter: postgresql  # or mysql2, sqlite3
```

**ORM**: `ActiveRecord` (Rails built-in)
**Databases**: PostgreSQL, MySQL, SQLite
**Migration**: Rails migrations (built-in)

---

## Detection Algorithm

```bash
# Check for ORM/database tools in order:

# Node.js/TypeScript ORMs
if grep -q '"@prisma/client"' package.json 2>/dev/null; then
  ORM="Prisma"
  # Detect database from schema.prisma
  DB=$(grep 'provider =' prisma/schema.prisma | awk '{print $3}' | tr -d '"')
elif grep -q '"drizzle-orm"' package.json 2>/dev/null; then
  ORM="Drizzle ORM"
  # Check schema imports for database type
elif grep -q '"@supabase/supabase-js"' package.json 2>/dev/null; then
  ORM="Supabase Client"
  DB="PostgreSQL"
elif grep -q '"typeorm"' package.json 2>/dev/null; then
  ORM="TypeORM"
elif grep -q '"sequelize"' package.json 2>/dev/null; then
  ORM="Sequelize"
fi

# Python ORMs
if test -f manage.py && grep -qi "django" requirements.txt 2>/dev/null; then
  ORM="Django ORM"
elif grep -qi "sqlalchemy" requirements.txt 2>/dev/null || grep -qi "sqlalchemy" pyproject.toml 2>/dev/null; then
  ORM="SQLAlchemy"
  # Check for Alembic
  if test -d alembic || test -f alembic.ini; then
    MIGRATION="Alembic"
  fi
fi

# PHP ORMs
if test -f artisan && grep -q '"laravel/framework"' composer.json 2>/dev/null; then
  ORM="Eloquent (Laravel)"
fi

# Ruby ORMs
if test -f bin/rails || test -f config/application.rb; then
  ORM="ActiveRecord (Rails)"
fi
```

---

## Environment Variables

Common database environment variables to check:

### PostgreSQL
```bash
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=dbname
```

### MySQL
```bash
DATABASE_URL="mysql://user:password@localhost:3306/dbname"
MYSQL_HOST=localhost
MYSQL_USER=user
MYSQL_PASSWORD=password
MYSQL_DATABASE=dbname
```

### SQLite
```bash
DATABASE_URL="file:./dev.db"
DB_CONNECTION=sqlite
```

### Supabase
```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
DATABASE_URL=postgresql://postgres:[password]@db.xxx.supabase.co:5432/postgres
```

---

## Migration Workflows

### Create Migration

**Prisma**:
```bash
npx prisma migrate dev --name add_user_email
```

**Drizzle**:
```bash
npx drizzle-kit generate:pg
```

**Django**:
```bash
python manage.py makemigrations
```

**SQLAlchemy/Alembic**:
```bash
alembic revision --autogenerate -m "add user email"
```

**Laravel**:
```bash
php artisan make:migration add_email_to_users_table
```

**Rails**:
```bash
rails generate migration AddEmailToUsers email:string
```

### Apply Migration

**Prisma**:
```bash
npx prisma migrate deploy
```

**Drizzle**:
```bash
npx drizzle-kit push:pg
```

**Django**:
```bash
python manage.py migrate
```

**SQLAlchemy/Alembic**:
```bash
alembic upgrade head
```

**Laravel**:
```bash
php artisan migrate
```

**Rails**:
```bash
rails db:migrate
```

---

## Database-Specific Considerations

### PostgreSQL
- Supports advanced features: JSON, arrays, full-text search
- ACID compliant
- Strong type system
- Best for: Complex queries, data integrity, JSONB

### MySQL
- Wide adoption
- Good performance for read-heavy workloads
- Best for: Web applications, WordPress, general use

### SQLite
- File-based, no server
- Zero configuration
- Best for: Development, small apps, testing, mobile

### MongoDB
- NoSQL document database
- Flexible schema
- Best for: Unstructured data, rapid prototyping
- Note: Some ORMs support it (Prisma, TypeORM, Django)

---

## Multiple Databases

### Detection Strategy

If multiple database systems detected:

1. **Check `.env` for active connection**
2. **Check primary ORM configuration**
3. **Look for migration directories**

Example: Prisma + Supabase
- Prisma is the ORM
- Supabase is the hosting platform
- Database is PostgreSQL
- Use Prisma migrations OR Supabase migrations (not both)

---

## Fallback Strategy

### When No Database Detected

1. **Check environment variables**:
   ```bash
   grep -E "DATABASE|DB_|POSTGRES|MYSQL|MONGO" .env
   ```

2. **Search for connection strings**:
   ```bash
   grep -r "postgresql://" --include="*.ts" --include="*.js" --include="*.py"
   ```

3. **Ask user**:
   ```
   ⚠️ No database/ORM detected.

   Is this project using a database?
   - If yes: Which database and ORM?
   - If no: Confirm "No database needed"
   ```

---

## Usage Examples

### Example 1: Prisma + PostgreSQL
```bash
$ grep '"@prisma/client"' package.json
"@prisma/client": "^5.7.0"
$ grep 'provider =' prisma/schema.prisma
provider = "postgresql"

✅ Database Stack Detected:
- ORM: Prisma 5.7.0
- Database: PostgreSQL
- Schema: prisma/schema.prisma
- Migrations: prisma/migrations/

📋 Common Commands:
- Generate: npx prisma generate
- Migrate: npx prisma migrate dev
- Studio: npx prisma studio
```

### Example 2: Django + PostgreSQL
```bash
$ test -f manage.py
$ grep -i "django" requirements.txt
Django==5.0.1
$ grep ENGINE settings.py
'ENGINE': 'django.db.backends.postgresql'

✅ Database Stack Detected:
- ORM: Django ORM (built-in)
- Database: PostgreSQL
- Migrations: app_name/migrations/

📋 Common Commands:
- Migrate: python manage.py migrate
- Make migrations: python manage.py makemigrations
```

### Example 3: Supabase + Drizzle
```bash
$ grep '"@supabase/supabase-js"' package.json
"@supabase/supabase-js": "^2.38.0"
$ grep '"drizzle-orm"' package.json
"drizzle-orm": "^0.29.0"

✅ Database Stack Detected:
- Platform: Supabase
- ORM: Drizzle ORM
- Database: PostgreSQL (Supabase)
- Migrations: Use Drizzle Kit OR Supabase CLI

⚠️ Choose migration strategy:
1. Drizzle migrations (code-first)
2. Supabase migrations (SQL-first)
```

---

## Validation

After detection, verify by:

1. **Connection Test**: Verify database connection works
2. **Migration Status**: Check if migrations are up to date
3. **Schema Validation**: Confirm schema files exist

**Report Format**:
```markdown
## Database Detection

**ORM**: [ORM Name] [Version]
**Database**: [Database Type]
**Migration Tool**: [Tool]

**Configuration**:
- Schema: [file path]
- Migrations: [directory]
- Environment: [.env variables]

**Connection Status**: ✅ Connected / ❌ Not configured

**Migrations**:
- Pending: [count]
- Applied: [count]
- Latest: [migration name]

**Common Commands**:
- Migrate: [command]
- Create migration: [command]
- Reset: [command]
```

---

## Commands Using This Component

- `/agency:implement` - Create database models and migrations
- `/agency:work` - Handle schema changes during development
- `/agency:refactor` - Refactor database schema safely
- `/agency:deploy` - Run migrations in production
- `/agency:test` - Set up test database
- `/agency:review` - Review schema changes
- `/agency:sprint` - Handle database changes across issues
