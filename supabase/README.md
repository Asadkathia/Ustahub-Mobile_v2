# Supabase Backend Setup

This directory contains the Supabase backend configuration, migrations, and Edge Functions for the Ustahub marketplace application.

## Structure

```
supabase/
├── config.toml          # Supabase local development configuration
├── migrations/          # Database migration files (SQL)
│   ├── 20240101000001_initial_schema.sql
│   ├── 20240101000002_rls_policies.sql
│   ├── 20240101000003_database_functions.sql
│   └── 20240101000004_indexes.sql
├── functions/           # Edge Functions (TypeScript/Deno)
│   ├── otp-auth/       # Custom OTP authentication
│   ├── fcm-token/      # FCM token management
│   ├── booking-workflow/ # Booking state management
│   └── wallet/         # Wallet operations
└── seed.sql            # Seed data for development
```

## Getting Started

### Prerequisites

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

### Local Development

1. Start Supabase locally:
   ```bash
   supabase start
   ```

2. This will start:
   - PostgreSQL database (port 54322)
   - PostgREST API (port 54321)
   - Supabase Studio (port 54323)
   - Inbucket (email testing, port 54324)

3. Access Supabase Studio:
   - Open http://localhost:54323
   - Default credentials are in the output of `supabase start`

### Database Migrations

1. Apply migrations:
   ```bash
   supabase db reset  # Resets database and applies all migrations
   ```

2. Create new migration:
   ```bash
   supabase migration new migration_name
   ```

3. Apply migrations to remote:
   ```bash
   supabase db push
   ```

### Edge Functions

1. Deploy all functions:
   ```bash
   supabase functions deploy
   ```

2. Deploy specific function:
   ```bash
   supabase functions deploy otp-auth
   ```

3. Test function locally:
   ```bash
   supabase functions serve otp-auth
   ```

### Linking to Remote Project

1. Create a new project on [Supabase Dashboard](https://supabase.com/dashboard)

2. Link local project:
   ```bash
   supabase link --project-ref your-project-ref
   ```

3. Push migrations:
   ```bash
   supabase db push
   ```

4. Deploy functions:
   ```bash
   supabase functions deploy
   ```

## Environment Variables

Create a `.env` file in the project root (not in supabase/) with:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

For Edge Functions, set secrets:
```bash
supabase secrets set SMTP_HOST=smtp.sendgrid.net
supabase secrets set SMTP_PASS=your-api-key
```

## Database Schema

The database consists of:

- **User Management**: `user_profiles`, `addresses`, `fcm_tokens`
- **Services**: `services`, `provider_services`, `plans`
- **Providers**: `providers`, `provider_documents`
- **Bookings**: `bookings`, `booking_notes`
- **Engagement**: `ratings`, `favorites`, `banners`
- **Financial**: `wallet_transactions`, `wallet_balance`
- **Auth**: `otp_verifications`

All tables have Row Level Security (RLS) policies enabled.

## Edge Functions

### otp-auth
Handles OTP-based authentication:
- `send`: Generates and sends OTP via email
- `verify`: Verifies OTP and creates user session

### fcm-token
Manages FCM tokens for push notifications:
- `store`: Stores FCM token for user
- `remove`: Removes FCM token

### booking-workflow
Manages booking state transitions:
- `accept`: Accept booking request
- `reject`: Reject booking request
- `start`: Start work on booking
- `complete`: Complete booking

### wallet
Handles wallet operations:
- `add_funds`: Add funds to provider wallet
- `get_balance`: Get current wallet balance
- `get_transactions`: Get transaction history

## Testing

1. Run migrations locally:
   ```bash
   supabase db reset
   ```

2. Test Edge Functions:
   ```bash
   supabase functions serve
   ```

3. Use Supabase Studio to test queries and view data

## Production Deployment

1. Ensure all migrations are applied:
   ```bash
   supabase db push
   ```

2. Deploy all Edge Functions:
   ```bash
   supabase functions deploy
   ```

3. Set production secrets:
   ```bash
   supabase secrets set --env-file .env.production
   ```

4. Update Flutter app with production Supabase URL and keys

## Troubleshooting

### Migration Errors
- Check migration files for syntax errors
- Ensure migrations are in correct order
- Use `supabase db reset` to start fresh

### Edge Function Errors
- Check function logs: `supabase functions logs <function-name>`
- Verify environment variables are set
- Test locally first with `supabase functions serve`

### RLS Policy Issues
- Use Supabase Studio to test policies
- Check user authentication status
- Verify user has correct role/permissions

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgREST API](https://postgrest.org/)
- [Edge Functions Guide](https://supabase.com/docs/guides/functions)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)


