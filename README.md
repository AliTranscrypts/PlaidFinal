# PlaidFinal - iOS Plaid Integration with Supabase

A complete iOS application that integrates Plaid API for brokerage account authentication with Supabase for data persistence.

## 🏗 Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   iOS App       │────▶│  Node.js API    │────▶│    Plaid API    │
│   (SwiftUI)     │     │   (Vercel)      │     │   (Sandbox)     │
│                 │     │                 │     │                 │
└─────────────────┘     └────────┬────────┘     └─────────────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │                 │
                        │    Supabase     │
                        │   (PostgreSQL)  │
                        │                 │
                        └─────────────────┘
```

## 🚀 Features

- **Plaid Integration**: Connect to brokerage accounts using Plaid Link
- **Real-time Data**: Fetch and display account balances and holdings
- **Data Persistence**: Store connection data in Supabase PostgreSQL database
- **Debug Tools**: Built-in network testing and logging capabilities
- **Clean Architecture**: Separated concerns between iOS app and backend API

## 📋 Prerequisites

- macOS with Xcode 15.0 or later
- iOS Simulator or physical device running iOS 14.0+
- Node.js 18.0 or later
- npm or yarn package manager
- Vercel CLI (for backend deployment)
- Git

## 🛠 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/PlaidFinal.git
cd PlaidFinal
```

### 2. Run Quick Start Script

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run quick start
./scripts/quick-start.sh
```

This will:
- Check prerequisites
- Install backend dependencies
- Resolve iOS dependencies
- Prepare everything for deployment

### 3. Deploy Backend

```bash
./scripts/deploy-backend.sh
```

### 4. Run iOS App

```bash
./scripts/build-ios.sh
```

This script will:
- Build the iOS app
- Boot the simulator
- Install and launch the app

#### Alternative: Using Xcode
1. Open `ios/PlaidFinal.xcodeproj`
2. Select target device (iPhone simulator)
3. Press `Cmd+R` to build and run

## 📱 Using the App

### Connecting an Account

1. **Launch the app** - You'll see the main screen with two buttons
2. **Click "Connect Brokerage Account"** (blue button)
3. **Plaid Link will open** - Select any bank (e.g., Chase, Wells Fargo)
4. **Enter credentials**:
   - Username: `user_good`
   - Password: `pass_good`
5. **Complete the flow** - You'll see "Successfully connected!" message

### Viewing Saved Accounts

1. **Click "View Saved Accounts"** (indigo button)
2. **View your connections** - Shows all saved accounts with balances
3. **Connection timestamps** - Each connection shows when it was created

## 🔧 Configuration

### Environment Variables

All configuration is centralized in:
- **Backend**: `backend/.env`
- **iOS**: `PlaidFinal/Config.swift`

See [Environment Configuration](docs/environment-config.md) for detailed information.

### Updating Backend URL

If you deploy to a new Vercel instance:

1. Deploy backend: `./scripts/deploy-backend.sh`
2. Copy the new URL from Vercel output
3. Update `ios/PlaidFinal/Config.swift`:
   ```swift
   static let backendURL = "https://your-new-url.vercel.app"
   ```
4. Rebuild iOS app: `./scripts/build-ios.sh`

## 🐛 Debugging

### Enable Logging

The app includes comprehensive logging. To view logs:

```bash
# Start log streaming with colored output
./scripts/view-logs.sh
```

### Network Testing

Use the built-in "Test Network" button (orange) to verify backend connectivity.

### Common Issues

1. **Plaid Link won't load**
   - Verify backend is deployed and accessible
   - Check backend URL in Config.swift
   - Ensure environment variables are set in Vercel

2. **"Invalid response format" error**
   - Check that user_id matches between connections
   - Verify Supabase tables are created
   - Check backend logs in Vercel dashboard

3. **Build errors**
   - Run `swift package resolve`
   - Clean build folder: `rm -rf .build/`
   - Restart Xcode if needed

## 📁 Project Structure

```
PlaidFinal/
├── ios/                     # iOS application
│   ├── PlaidFinal/          # App source code
│   │   ├── PlaidFinalApp.swift
│   │   ├── ContentView.swift
│   │   └── Config.swift
│   ├── PlaidFinal.xcodeproj # Xcode project
│   └── Package.swift        # Swift package manifest
├── backend/                 # Node.js backend
│   ├── api/                 # API endpoints
│   ├── .env                 # Environment variables
│   └── package.json         # Dependencies
├── scripts/                 # Helper scripts
│   ├── quick-start.sh       # Initial setup
│   ├── build-ios.sh         # Build & run iOS
│   ├── deploy-backend.sh    # Deploy to Vercel
│   └── view-logs.sh         # View app logs
├── docs/                    # Documentation
│   ├── ios-setup.md
│   ├── backend-setup.md
│   └── environment-config.md
└── supabase_schema.sql      # Database schema
```

## 🗄 Database Schema

The app uses Supabase with the following main tables:
- `plaid_items` - Stores Plaid connection information
- `plaid_accounts` - Account details
- `plaid_balances` - Current balances
- `plaid_holdings` - Investment holdings (if applicable)
- `plaid_securities` - Security information
- `plaid_transactions` - Transaction history

See [supabase_schema.sql](supabase_schema.sql) for complete schema.

## 🚀 Deployment

### Backend Deployment

```bash
cd backend
vercel --prod
```

Follow prompts to:
1. Link to existing project or create new
2. Confirm deployment settings
3. Wait for deployment to complete

### iOS Distribution

For TestFlight or App Store:
1. Update bundle identifier and team in Xcode
2. Archive the app: Product → Archive
3. Distribute through App Store Connect

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is proprietary and confidential.

## 🙏 Acknowledgments

- [Plaid](https://plaid.com) for financial data APIs
- [Supabase](https://supabase.com) for backend infrastructure
- [Vercel](https://vercel.com) for hosting 