-- Supabase Schema for PlaidFinal App
-- This creates tables to store Plaid connection data

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table for storing Plaid Items (connections)
CREATE TABLE IF NOT EXISTS plaid_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id TEXT NOT NULL,
    access_token TEXT NOT NULL,
    item_id TEXT NOT NULL UNIQUE,
    institution_name TEXT NOT NULL,
    institution_id TEXT,
    webhook TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for storing Plaid Accounts
CREATE TABLE IF NOT EXISTS plaid_accounts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    item_id TEXT NOT NULL REFERENCES plaid_items(item_id) ON DELETE CASCADE,
    account_id TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    official_name TEXT,
    type TEXT NOT NULL, -- e.g., 'investment', 'depository'
    subtype TEXT, -- e.g., 'brokerage', 'checking'
    mask TEXT, -- Last 4 digits of account
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for storing Account Balances
CREATE TABLE IF NOT EXISTS plaid_balances (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    account_id TEXT NOT NULL REFERENCES plaid_accounts(account_id) ON DELETE CASCADE,
    current DECIMAL(20, 2),
    available DECIMAL(20, 2),
    "limit" DECIMAL(20, 2),
    iso_currency_code TEXT DEFAULT 'USD',
    unofficial_currency_code TEXT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for storing Investment Holdings (for brokerage accounts)
CREATE TABLE IF NOT EXISTS plaid_holdings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    account_id TEXT NOT NULL REFERENCES plaid_accounts(account_id) ON DELETE CASCADE,
    security_id TEXT NOT NULL,
    institution_price DECIMAL(20, 4),
    institution_value DECIMAL(20, 2),
    quantity DECIMAL(20, 4),
    cost_basis DECIMAL(20, 2),
    iso_currency_code TEXT DEFAULT 'USD',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for storing Securities information
CREATE TABLE IF NOT EXISTS plaid_securities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    security_id TEXT NOT NULL UNIQUE,
    ticker_symbol TEXT,
    name TEXT,
    type TEXT, -- e.g., 'equity', 'etf', 'mutual fund'
    close_price DECIMAL(20, 4),
    close_price_as_of DATE,
    iso_currency_code TEXT DEFAULT 'USD',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for storing Transactions
CREATE TABLE IF NOT EXISTS plaid_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    account_id TEXT NOT NULL REFERENCES plaid_accounts(account_id) ON DELETE CASCADE,
    transaction_id TEXT NOT NULL UNIQUE,
    amount DECIMAL(20, 2) NOT NULL,
    iso_currency_code TEXT DEFAULT 'USD',
    category_id TEXT,
    date DATE NOT NULL,
    name TEXT NOT NULL,
    merchant_name TEXT,
    pending BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_plaid_items_user_id ON plaid_items(user_id);
CREATE INDEX idx_plaid_accounts_item_id ON plaid_accounts(item_id);
CREATE INDEX idx_plaid_balances_account_id ON plaid_balances(account_id);
CREATE INDEX idx_plaid_holdings_account_id ON plaid_holdings(account_id);
CREATE INDEX idx_plaid_transactions_account_id ON plaid_transactions(account_id);
CREATE INDEX idx_plaid_transactions_date ON plaid_transactions(date);

-- Add updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_plaid_items_updated_at BEFORE UPDATE ON plaid_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plaid_accounts_updated_at BEFORE UPDATE ON plaid_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plaid_securities_updated_at BEFORE UPDATE ON plaid_securities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
ALTER TABLE plaid_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE plaid_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE plaid_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE plaid_holdings ENABLE ROW LEVEL SECURITY;
ALTER TABLE plaid_securities ENABLE ROW LEVEL SECURITY;
ALTER TABLE plaid_transactions ENABLE ROW LEVEL SECURITY;

-- For now, we'll create simple policies that allow all operations
-- In production, you'd want to restrict based on authenticated user
CREATE POLICY "Enable all access for plaid_items" ON plaid_items
    FOR ALL USING (true);

CREATE POLICY "Enable all access for plaid_accounts" ON plaid_accounts
    FOR ALL USING (true);

CREATE POLICY "Enable all access for plaid_balances" ON plaid_balances
    FOR ALL USING (true);

CREATE POLICY "Enable all access for plaid_holdings" ON plaid_holdings
    FOR ALL USING (true);

CREATE POLICY "Enable all access for plaid_securities" ON plaid_securities
    FOR ALL USING (true);

CREATE POLICY "Enable all access for plaid_transactions" ON plaid_transactions
    FOR ALL USING (true); 