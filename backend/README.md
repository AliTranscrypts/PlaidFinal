# Plaid Backend Server

This backend server provides API endpoints for Plaid Link integration with your iOS app.

## Setup Instructions

### 1. Get Your Plaid Secret Key

1. Go to [Plaid Dashboard](https://dashboard.plaid.com)
2. Navigate to **Team Settings** → **Keys**
3. Copy your **sandbox secret key** (starts with `sandbox_`)
4. Update the `.env` file with your secret key

### 2. Update Environment Variables

Edit `.env` file:
```bash
PLAID_CLIENT_ID=6679bca416b4a5001a33b360
PLAID_SECRET=your_actual_sandbox_secret_key_here
PLAID_ENV=sandbox
```

### 3. Deploy to Vercel

1. Install Vercel CLI:
   ```bash
   npm install -g vercel
   ```

2. Deploy:
   ```bash
   vercel
   ```

3. Set environment variables on Vercel:
   - Go to your Vercel dashboard
   - Select your project
   - Go to Settings → Environment Variables
   - Add:
     - `PLAID_CLIENT_ID`: `6679bca416b4a5001a33b360`
     - `PLAID_SECRET`: Your actual sandbox secret key
     - `PLAID_ENV`: `sandbox`

4. Redeploy after setting environment variables:
   ```bash
   vercel --prod
   ```

## API Endpoints

### POST /api/create-link-token
Creates a Plaid link token for the iOS app.

**Request:**
```json
{
  "user_id": "demo-user-123"
}
```

**Response:**
```json
{
  "link_token": "link-sandbox-..."
}
```

### POST /api/exchange-public-token
Exchanges a public token for an access token.

**Request:**
```json
{
  "public_token": "public-sandbox-..."
}
```

**Response:**
```json
{
  "success": true,
  "access_token": "access-sandbox-...",
  "item_id": "item-id-..."
}
```

## Testing

After deployment, your backend will be available at:
- `https://your-project-name.vercel.app/api/create-link-token`
- `https://your-project-name.vercel.app/api/exchange-public-token`

Update your iOS app's `backendURL` with your Vercel URL.
