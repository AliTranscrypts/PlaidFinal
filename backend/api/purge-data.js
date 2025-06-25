const supabase = require('../supabase-client');

module.exports = async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'DELETE') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    console.log('🗑️ Starting data purge...');

    // Delete in reverse order of foreign key dependencies
    // First delete balances (references accounts)
    const { error: balancesError } = await supabase
      .from('plaid_balances')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000'); // Delete all rows

    if (balancesError) {
      console.error('Error deleting balances:', balancesError);
      throw balancesError;
    }

    // Delete holdings (references accounts)
    const { error: holdingsError } = await supabase
      .from('plaid_holdings')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000');

    if (holdingsError) {
      console.error('Error deleting holdings:', holdingsError);
      throw holdingsError;
    }

    // Delete transactions (references accounts)
    const { error: transactionsError } = await supabase
      .from('plaid_transactions')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000');

    if (transactionsError) {
      console.error('Error deleting transactions:', transactionsError);
      throw transactionsError;
    }

    // Delete accounts (references items)
    const { error: accountsError } = await supabase
      .from('plaid_accounts')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000');

    if (accountsError) {
      console.error('Error deleting accounts:', accountsError);
      throw accountsError;
    }

    // Delete securities (no foreign key dependencies)
    const { error: securitiesError } = await supabase
      .from('plaid_securities')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000');

    if (securitiesError) {
      console.error('Error deleting securities:', securitiesError);
      throw securitiesError;
    }

    // Finally delete items (parent table)
    const { error: itemsError } = await supabase
      .from('plaid_items')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000');

    if (itemsError) {
      console.error('Error deleting items:', itemsError);
      throw itemsError;
    }

    console.log('✅ All data purged successfully');

    res.json({
      success: true,
      message: 'All data has been purged from Supabase'
    });
  } catch (error) {
    console.error('Purge error:', error);
    res.status(500).json({
      error: error.message,
      details: error
    });
  }
}; 