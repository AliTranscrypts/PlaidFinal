# Backend Setup & Deployment Guide

This guide covers setting up, running, and deploying the Node.js backend for PlaidFinal.

## Prerequisites

- Node.js 18.0 or later
- npm or yarn package manager
- Vercel CLI (for deployment)
- Git

## Local Development Setup

### 1. Navigate to Backend Directory
```bash
cd backend
```

### 2. Install Dependencies
```bash
npm install
# or
yarn install
```

### 3. Environment Variables
The `.env` file is already configured with necessary values:
```bash
# Plaid Configuration
PLAID_CLIENT_ID=6679bca416b4a5001a33b360
PLAID_SECRET=919c6c071114037a76c03ab180a3d2
PLAID_ENV=sandbox

# Supabase Configuration
SUPABASE_URL=https://gopghvkksnlzisvaazhl.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Application Configuration
NODE_ENV=production
PORT=3000
```

### 4. Run Locally
```bash
# Using Vercel CLI (recommended)
vercel dev

# Or using Node.js directly
node api/create-link-token.js
```

## API Endpoints

### 1. Create Link Token
**POST** `/api/create-link-token`

Creates a Plaid Link token for client initialization.

Request:
```json
{
  "user_id": "user_123"
}
```

Response:
```json
{
  "link_token": "link-sandbox-xxxxx"
}
```

### 2. Exchange Public Token
**POST** `/api/exchange-public-token`

Exchanges Plaid public token for access token and saves to Supabase.

Request:
```json
{
  "public_token": "public-sandbox-xxxxx",
  "user_id": "user_123",
  "institution": {
    "name": "Chase"
  }
}
```

Response:
```json
{
  "success": true,
  "message": "Token exchanged and data saved successfully"
}
```

### 3. Get Accounts
**GET** `/api/get-accounts?user_id=user_123`

Retrieves saved account data from Supabase.

Response:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "institution_name": "Chase",
      "created_at": "2025-06-25T18:00:00Z",
      "accounts": [...]
    }
  ]
}
```

### 4. Purge Data
**DELETE** `/api/purge-data`

Removes all data from Supabase (keeping schema intact).

Response:
```json
{
  "success": true,
  "message": "All data purged successfully"
}
```

### 5. Test Endpoint
**GET** `/api/test`

Simple health check endpoint.

Response:
```json
{
  "status": "Backend is running!",
  "timestamp": "2025-06-25T18:00:00Z"
}
```

## Testing Locally

### Using cURL
```bash
# Test endpoint
curl http://localhost:3000/api/test

# Create link token
curl -X POST http://localhost:3000/api/create-link-token \
  -H "Content-Type: application/json" \
  -d '{"user_id":"user_123"}'

# Get accounts
curl "http://localhost:3000/api/get-accounts?user_id=user_123"
```

### Using Postman
1. Import the endpoints above
2. Set base URL to `http://localhost:3000`
3. Add JSON body for POST requests

## Deployment to Vercel

### First-Time Setup

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy**
   ```bash
   cd backend
   vercel
   ```

4. **Follow the prompts**:
   - Set up and deploy: `Y`
   - Which scope: Select your account
   - Link to existing project: `N` (first time)
   - Project name: `plaid-backend` (or your choice)
   - Directory: `./` (current directory)
   - Override settings: `N`

### Subsequent Deployments

#### Production Deployment
```bash
vercel --prod
```

#### Preview Deployment
```bash
vercel
```

### Environment Variables in Vercel

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Select your project
3. Navigate to "Settings" → "Environment Variables"
4. Add the following:

| Key | Value |
|-----|-------|
| PLAID_CLIENT_ID | 6679bca416b4a5001a33b360 |
| PLAID_SECRET | 919c6c071114037a76c03ab180a3d2 |
| PLAID_ENV | sandbox |
| SUPABASE_URL | https://gopghvkksnlzisvaazhl.supabase.co |
| SUPABASE_ANON_KEY | eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... |

5. Redeploy after adding variables:
   ```bash
   vercel --prod --force
   ```

## Monitoring & Logs

### View Deployment Logs
```bash
vercel logs <deployment-url>
```

### View Function Logs
1. Go to Vercel Dashboard
2. Select your project
3. Navigate to "Functions" tab
4. Click on specific function to view logs

### Real-time Logs
```bash
vercel logs --follow
```

## Troubleshooting

### Common Issues

#### "Module not found" Error
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

#### Environment Variables Not Loading
- Ensure `.env` file exists in backend directory
- For Vercel, check dashboard for proper configuration
- Redeploy after changing environment variables

#### CORS Issues
All endpoints include CORS headers:
```javascript
res.setHeader('Access-Control-Allow-Origin', '*');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, DELETE');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
```

#### Supabase Connection Failed
- Verify API key is correct and not expired
- Check Supabase project is active
- Ensure tables exist (run schema SQL)

## Database Management

### Setting Up Supabase Tables
1. Go to Supabase Dashboard
2. Navigate to SQL Editor
3. Run the contents of `supabase_schema.sql`

### Backing Up Data
```sql
-- Export data
pg_dump -h <host> -U postgres -d postgres > backup.sql
```

### Monitoring Database
- Use Supabase Dashboard for real-time monitoring
- Check table sizes and row counts
- Monitor API usage and limits

## Security Best Practices

1. **API Keys**: Never commit production keys
2. **Rate Limiting**: Implement rate limiting for production
3. **Input Validation**: Validate all incoming data
4. **Error Handling**: Don't expose sensitive errors
5. **HTTPS**: Always use HTTPS in production

## Performance Optimization

### Caching
Consider implementing caching for frequently accessed data:
```javascript
const cache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes
```

### Database Queries
- Use indexes on frequently queried columns
- Implement pagination for large datasets
- Use connection pooling

### Monitoring
- Set up alerts for high response times
- Monitor function execution duration
- Track API usage patterns

## Updating Dependencies

```bash
# Check for outdated packages
npm outdated

# Update all dependencies
npm update

# Update specific package
npm install package-name@latest
```

## Additional Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Plaid API Documentation](https://plaid.com/docs/)
- [Supabase Documentation](https://supabase.com/docs)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices) 