#!/bin/bash
# Script to apply Supabase migrations

echo "Applying Supabase migrations to remote project..."

# Apply migrations one by one
supabase db push --linked <<EOF
y
EOF

echo "Migrations applied successfully!"


