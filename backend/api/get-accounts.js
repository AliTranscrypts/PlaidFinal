const supabase = require('../supabase-client');

module.exports = async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const user_id = req.query.user_id || 'default_user';

    // Fetch all items for this user
    const { data: items, error: itemsError } = await supabase
      .from('plaid_items')
      .select('*')
      .eq('user_id', user_id)
      .order('created_at', { ascending: false });

    if (itemsError) {
      throw itemsError;
    }

    // For each item, fetch accounts and their balances
    const itemsWithAccounts = await Promise.all(
      items.map(async (item) => {
        // Fetch accounts for this item
        const { data: accounts, error: accountsError } = await supabase
          .from('plaid_accounts')
          .select('*')
          .eq('item_id', item.item_id);

        if (accountsError) {
          console.error('Error fetching accounts:', accountsError);
          return { ...item, accounts: [] };
        }

        // Fetch balances for each account
        const accountsWithBalances = await Promise.all(
          accounts.map(async (account) => {
            const { data: balances, error: balancesError } = await supabase
              .from('plaid_balances')
              .select('*')
              .eq('account_id', account.account_id)
              .order('last_updated', { ascending: false })
              .limit(1)
              .single();

            if (balancesError) {
              console.error('Error fetching balance:', balancesError);
              return { ...account, balance: null };
            }

            return { ...account, balance: balances };
          })
        );

        return {
          ...item,
          accounts: accountsWithBalances
        };
      })
    );

    res.json({
      success: true,
      data: itemsWithAccounts
    });
  } catch (error) {
    console.error('Error fetching accounts:', error);
    res.status(500).json({ 
      error: 'Failed to fetch accounts',
      details: error.message 
    });
  }
}; 