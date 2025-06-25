module.exports = async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  res.json({
    message: 'PlaidFinal backend is working!',
    timestamp: new Date().toISOString(),
    endpoints: {
      createLinkToken: '/api/create-link-token (POST)',
      exchangePublicToken: '/api/exchange-public-token (POST)',
      getAccounts: '/api/get-accounts (GET)',
      test: '/api/test (GET)'
    }
  });
}; 