# Supabase Setup Instructions for PlaidFinal

## Quick Setup

1. Go to your Supabase project: https://gopghvkksnlzisvaazhl.supabase.co

2. Navigate to the SQL Editor in the left sidebar

3. Copy and paste the entire contents of `supabase_schema.sql` into the editor

4. Click "Run" to execute the SQL and create all tables

## What This Creates

- **plaid_items**: Stores Plaid connection information
- **plaid_accounts**: Stores individual account details
- **plaid_balances**: Stores account balance information
- **plaid_holdings**: Stores investment holdings (stocks, ETFs, etc.)
- **plaid_securities**: Stores security/stock information
- **plaid_transactions**: Stores transaction history

## Verify Setup

After running the SQL, you can verify the tables were created:

1. Go to the Table Editor in Supabase
2. You should see all 6 tables listed
3. Each table should have the appropriate columns

## API Keys

Your project details:
- **URL**: https://gopghvkksnlzisvaazhl.supabase.co
- **Anon Key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdvcGdodmtrc25semlzdmFhemhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4Njc0NDcsImV4cCI6MjA2NjQ0MzQ0N30.NbX1EP8x_wqzG15hVmXhWckBjPmqdGE__VfbEYgBkgY

## Next Steps

The backend API endpoints will be updated to:
1. Store access tokens in Supabase after exchange
2. Fetch and store account data
3. Provide endpoints for the iOS app to retrieve data 