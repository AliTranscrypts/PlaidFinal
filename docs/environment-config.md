# Environment Configuration

This document explains all environment variables and configuration settings used in the PlaidFinal project.

## Backend Environment Variables

The backend uses a `.env` file located at `backend/.env` with the following variables:

### Plaid Configuration
- `PLAID_CLIENT_ID`: Your Plaid client ID (currently: `6679bca416b4a5001a33b360`)
- `PLAID_SECRET`: Your Plaid sandbox secret key (currently: `919c6c071114037a76c03ab180a3d2`)
- `PLAID_ENV`: Plaid environment - `sandbox`, `development`, or `production` (currently: `sandbox`)

### Supabase Configuration
- `SUPABASE_URL`: Your Supabase project URL (currently: `https://gopghvkksnlzisvaazhl.supabase.co`)
- `SUPABASE_ANON_KEY`: Your Supabase anonymous/public key

### Application Configuration
- `NODE_ENV`: Node environment - `development` or `production` (currently: `production`)
- `PORT`: Port for local development (currently: `3000`)

## iOS Configuration

The iOS app uses a `Config.swift` file located at `PlaidFinal/Config.swift` with the following settings:

### Backend Configuration
- `backendURL`: The deployed backend URL (update this when you deploy to a new URL)
- Currently: `https://plaid-backend-ls8zfv8y0-2fa-transcrypts-projects.vercel.app`

### User Configuration
- `defaultUserId`: Default user ID for demo purposes (currently: `user_123`)
- `appName`: Application name (currently: `PlaidFinal`)

### Debug Configuration
- `enableDebugLogging`: Enable/disable debug logs (currently: `true`)
- `networkTimeout`: Network request timeout in seconds (currently: `30.0`)

## Updating Configuration

### For Backend:
1. Edit `backend/.env` file with your values
2. Redeploy to Vercel: `cd backend && vercel --prod`
3. Add environment variables in Vercel dashboard if needed

### For iOS:
1. Edit `PlaidFinal/Config.swift` file
2. Update `backendURL` if you deploy to a new URL
3. Rebuild the iOS app

## Security Note

While these environment variables are included in the repository for team convenience, in a production environment you should:
- Never commit production secrets to version control
- Use environment-specific configuration files
- Store sensitive values in secure secret management systems 