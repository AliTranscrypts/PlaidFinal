const { Configuration, PlaidApi, PlaidEnvironments } = require('plaid');
const supabase = require('../supabase-client');

const configuration = new Configuration({
  basePath: PlaidEnvironments[process.env.PLAID_ENV],
  baseOptions: {
    headers: {
      'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
      'PLAID-SECRET': process.env.PLAID_SECRET,
    },
  },
});

const client = new PlaidApi(configuration);

module.exports = async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { public_token, user_id = 'user_123', institution } = req.body;

    if (!public_token) {
      return res.status(400).json({ error: 'public_token is required' });
    }

    console.log('Exchanging public token for access token');
    const response = await client.itemPublicTokenExchange({
      public_token: public_token,
    });

    const accessToken = response.data.access_token;
    const itemId = response.data.item_id;

    console.log('Token exchange successful, fetching accounts');

    // Fetch account information
    const accountsResponse = await client.accountsGet({
      access_token: accessToken,
    });

    const accounts = accountsResponse.data.accounts;
    const item = accountsResponse.data.item;

    // APPEND DATA INSTEAD OF OVERWRITING
    // Each connection creates a new item record with current timestamp
    console.log('Creating new connection record with timestamp');
    
    const { data: savedItem, error: itemError } = await supabase
      .from('plaid_items')
      .insert({
        item_id: itemId,
        user_id: user_id,
        access_token: accessToken,
        institution_name: institution?.name || 'Unknown Institution',
        institution_id: institution?.institution_id || null,
        created_at: new Date().toISOString(), // Explicitly set timestamp
        updated_at: new Date().toISOString()
      })
      .select()
      .single();

    if (itemError) {
      console.error('Error saving item:', itemError);
      throw itemError;
    }

    console.log(`New connection saved with ID: ${savedItem.id} at ${savedItem.created_at}`);

    // Save accounts and balances - each as new records
    for (const account of accounts) {
      // Create new account record (not upsert)
      const { data: savedAccount, error: accountError } = await supabase
        .from('plaid_accounts')
        .insert({
          account_id: account.account_id,
          item_id: itemId,
          name: account.name,
          official_name: account.official_name,
          type: account.type,
          subtype: account.subtype,
          mask: account.mask,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .select()
        .single();

      if (accountError) {
        console.error('Error saving account:', accountError);
        continue; // Continue with other accounts
      }

      // Save balance snapshot
      if (account.balances) {
        const { error: balanceError } = await supabase
          .from('plaid_balances')
          .insert({
            account_id: account.account_id,
            current: account.balances.current,
            available: account.balances.available,
            limit: account.balances.limit,
            iso_currency_code: account.balances.iso_currency_code,
            unofficial_currency_code: account.balances.unofficial_currency_code,
            last_updated: new Date().toISOString() // Timestamp for balance snapshot
          });

        if (balanceError) {
          console.error('Error saving balance:', balanceError);
        } else {
          console.log(`Balance snapshot saved for account ${account.name} at ${new Date().toISOString()}`);
        }
      }
    }

    console.log('Data saved to Supabase successfully');

    res.json({ 
      success: true,
      access_token: accessToken,
      item_id: itemId,
      accounts: accounts.map(acc => ({
        id: acc.account_id,
        name: acc.name,
        type: acc.type,
        subtype: acc.subtype,
        mask: acc.mask,
        balance: acc.balances
      }))
    });
  } catch (error) {
    console.error('Error in exchange-public-token:', error);
    res.status(500).json({ 
      error: 'Failed to exchange public token',
      details: error.message 
    });
  }
};
