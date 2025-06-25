import SwiftUI
import LinkKit

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var plaidManager = PlaidManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Plaid Account Authentication")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Connect your financial account securely")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Status Display
                VStack(spacing: 16) {
                    if let status = plaidManager.status {
                        StatusView(status: status)
                    }
                    
                    if let accountInfo = plaidManager.accountInfo {
                        AccountInfoView(info: accountInfo)
                    }
                }
                
                Spacer()
                
                // Connect Button
                VStack(spacing: 12) {
                    Button(action: {
                        plaidManager.startPlaidLink()
                    }) {
                        HStack {
                            if plaidManager.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text(plaidManager.isConnected ? "Reconnect Account" : "Connect Account")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(plaidManager.isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(plaidManager.isLoading)
                    
                    // Demo Button (for testing without real backend)
                    Button(action: {
                        plaidManager.simulateSuccess()
                    }) {
                        HStack {
                            Image(systemName: "play.circle")
                            Text("Demo Mode (Test UI)")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Test Network Button
                    Button(action: {
                        plaidManager.testNetwork()
                    }) {
                        HStack {
                            Image(systemName: "network")
                            Text("Test Network")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Debug Link Token Button
                    Button(action: {
                        plaidManager.debugLinkToken()
                    }) {
                        HStack {
                            Image(systemName: "ladybug")
                            Text("Debug Link Token")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Fetch Saved Data Button
                    Button(action: {
                        plaidManager.fetchSavedAccounts()
                    }) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                            Text("View Saved Accounts")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.29, green: 0.33, blue: 0.64)) // Custom indigo color for iOS 14
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Environment Info
                Text("Environment: Sandbox")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Status View
struct StatusView: View {
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text(status)
                .font(.body)
                .foregroundColor(statusColor)
        }
        .padding()
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        if status.contains("Success") || status.contains("Connected") {
            return "checkmark.circle.fill"
        } else if status.contains("Error") || status.contains("Failed") {
            return "xmark.circle.fill"
        } else {
            return "info.circle.fill"
        }
    }
    
    private var statusColor: Color {
        if status.contains("Success") || status.contains("Connected") {
            return .green
        } else if status.contains("Error") || status.contains("Failed") {
            return .red
        } else {
            return .blue
        }
    }
}

// MARK: - Account Info View
struct AccountInfoView: View {
    let info: AccountInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text("Public Token:")
                    .fontWeight(.medium)
                Spacer()
                Text(String(info.publicToken.prefix(20)) + "...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let institutionName = info.institutionName {
                HStack {
                    Text("Institution:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(institutionName)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Account ID:")
                    .fontWeight(.medium)
                Spacer()
                Text(String(info.accountId.prefix(15)) + "...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Data Models
struct AccountInfo {
    let publicToken: String
    let accountId: String
    let institutionName: String?
}

// MARK: - Plaid Manager
class PlaidManager: ObservableObject {
    @Published var status: String?
    @Published var accountInfo: AccountInfo?
    @Published var isLoading: Bool = false
    @Published var isConnected: Bool = false
    
    private let clientId = "6679bca416b4a5001a33b360"
    private let sandboxId = "919c6c071114037a76c03ab180a3d2"
    
    // Backend URL from Config
    private let backendURL = Config.backendURL
    
    // Store the Plaid handler
    private var plaidHandler: Handler?
    
    func startPlaidLink() {
        isLoading = true
        status = "Starting... Backend URL: \(backendURL)"
        
        print("🔵 Starting Plaid Link - fetching link token from backend")
        
        // Update status after 2 seconds to show we're trying
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.isLoading {
                self.status = "Connecting to backend..."
            }
        }
        
        // Set a timeout timer on main queue
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
                if self.isLoading {
                    print("⏱️ Request timed out after 15 seconds")
                    self.handleError("Request timed out. Backend returned 200 but Plaid Link failed to initialize.")
                }
            }
        }
        
        // Step 1: Fetch link token from your backend
        fetchLinkToken { [weak self] linkToken in
            guard let self = self else { return }
            
            guard let linkToken = linkToken else {
                self.handleError("Failed to fetch link token from backend")
                return
            }
            
            DispatchQueue.main.async {
                self.status = "Initializing Plaid Link..."
                print("✅ Got link token: \(String(linkToken.prefix(20)))...")
                
                // Add a small delay to ensure UI updates
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("🔶 Creating LinkTokenConfiguration...")
                    
                    // Step 2: Create Plaid Link configuration with token
                    print("🔶 Creating LinkTokenConfiguration with token...")
                    
                    var linkConfiguration = LinkTokenConfiguration(
                        token: linkToken,
                        onSuccess: { success in
                            DispatchQueue.main.async {
                                print("✅ Plaid Link Success!")
                                self.isLoading = false
                                self.status = "Successfully connected!"
                                self.isConnected = true
                                
                                // Store account information
                                self.accountInfo = AccountInfo(
                                    publicToken: success.publicToken,
                                    accountId: success.metadata.accounts.first?.id ?? "Unknown",
                                    institutionName: success.metadata.institution.name
                                )
                                
                                print("Public Token: \(success.publicToken)")
                                print("Institution: \(success.metadata.institution.name)")
                                print("Accounts: \(success.metadata.accounts)")
                                
                                // Step 3: Exchange public token for access token
                                self.exchangePublicToken(success.publicToken)
                            }
                        }
                    )
                    
                    print("🔶 LinkTokenConfiguration created")
                    
                    linkConfiguration.onExit = { exit in
                        DispatchQueue.main.async {
                            print("❌ Plaid Link Exit")
                            self.isLoading = false
                            
                            if let error = exit.error {
                                print("Exit error: \(error.localizedDescription)")
                                print("Exit error code: \(error.errorCode)")
                                print("Exit error message: \(error.errorMessage)")
                                self.handleError("Connection failed: \(error.localizedDescription)")
                            } else {
                                print("User cancelled")
                                self.status = "Connection cancelled by user"
                            }
                        }
                    }
                    
                    linkConfiguration.onEvent = { event in
                        print("🔷 Plaid Event: \(event.eventName)")
                        
                        // Check for specific events that might indicate issues
                        switch event.eventName {
                        case .error:
                            print("❌ Plaid Error Event: \(event)")
                        case .open:
                            print("✅ Plaid Link opened successfully")
                            DispatchQueue.main.async {
                                self.status = "Plaid Link opened - please authenticate"
                                self.isLoading = false
                            }
                        case .handoff:
                            print("✅ Plaid Link handoff - success!")
                        default:
                            break
                        }
                    }
                    
                    print("🔶 Creating Plaid configuration with link token...")
                    print("🔍 Link token length: \(linkToken.count)")
                    
                    // Create Plaid handler
                    print("🔶 About to call Plaid.create...")
                    let result = Plaid.create(linkConfiguration)
                    print("🔶 Plaid.create returned")
                    
                    switch result {
                    case .failure(let error):
                        print("❌ Failed to create Plaid handler: \(error)")
                        print("❌ Error type: \(type(of: error))")
                        print("❌ Error details: \(error)")
                        self.isLoading = false
                        self.handleError("Failed to create Plaid handler: \(error.localizedDescription)")
                    case .success(let handler):
                        print("✅ Plaid handler created successfully")
                        print("🔶 Handler type: \(type(of: handler))")
                        print("🔶 Opening Plaid Link...")
                        
                        // Store the handler
                        self.plaidHandler = handler
                        
                        // Ensure we're on the main thread and have a valid view controller
                        DispatchQueue.main.async {
                            print("🔶 On main thread, about to open...")
                            // Don't stop loading here - let the onLoad callback or Link UI handle it
                            self.status = "Opening Plaid Link..."
                            
                            let vc = self.topViewController()
                            print("🔶 View controller: \(vc)")
                            print("🔶 View controller type: \(type(of: vc))")
                            
                            // Try standard presentation
                            handler.open(presentUsing: .viewController(vc))
                            print("🔶 handler.open called with viewController")
                            
                            // Stop loading after a short delay to ensure Link has opened
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if self.isLoading {
                                    self.isLoading = false
                                    self.status = "Plaid Link is open - please complete authentication"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Fetch link token from backend
    private func fetchLinkToken(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(backendURL)/api/create-link-token") else {
            print("❌ Invalid backend URL")
            DispatchQueue.main.async {
                self.handleError("Invalid backend URL")
            }
            completion(nil)
            return
        }
        
        print("🔵 Fetching link token from: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // Add 30 second timeout
        
        let body = ["user_id": "demo-user-\(UUID().uuidString)"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("📤 Sending request with body: \(body)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
                DispatchQueue.main.async {
                    self.handleError("Network error: \(error.localizedDescription)")
                }
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status code: \(httpResponse.statusCode)")
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.handleError("No data received from server")
                }
                completion(nil)
                return
            }
            
            print("📥 Received data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let linkToken = json["link_token"] as? String {
                    print("✅ Successfully fetched link token: \(String(linkToken.prefix(20)))...")
                    completion(linkToken)
                } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("❌ Response JSON: \(json)")
                    let errorMessage = json["error"] as? String ?? "Invalid response format"
                    DispatchQueue.main.async {
                        self.handleError(errorMessage)
                    }
                    completion(nil)
                } else {
                    print("❌ Invalid response format")
                    DispatchQueue.main.async {
                        self.handleError("Invalid response format from server")
                    }
                    completion(nil)
                }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                print("❌ Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                DispatchQueue.main.async {
                    self.handleError("Failed to parse server response")
                }
                completion(nil)
            }
        }
        
        task.resume()
        print("🚀 Network request started")
    }
    
    // Exchange public token for access token
    private func exchangePublicToken(_ publicToken: String) {
        guard let url = URL(string: "\(backendURL)/api/exchange-public-token") else {
            print("❌ Invalid backend URL for token exchange")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "public_token": publicToken,
            "user_id": Config.defaultUserId, // Using user_id from Config
            "institution": [
                "name": accountInfo?.institutionName ?? "Unknown Institution"
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Token exchange error: \(error.localizedDescription)")
                    self.handleError("Failed to save connection: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from token exchange")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("✅ Token exchange successful:")
                        print("📤 Full response: \(json)")
                        
                        // Update status to show data was saved
                        if let success = json["success"] as? Bool, success {
                            self.status = "✅ Connection saved to Supabase!"
                            
                            // Show account details if available
                            if let accounts = json["accounts"] as? [[String: Any]] {
                                print("📊 Received \(accounts.count) accounts")
                                for account in accounts {
                                    if let name = account["name"] as? String,
                                       let balance = account["balance"] as? Double {
                                        print("💰 Account: \(name), Balance: $\(balance)")
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("❌ Token exchange JSON parsing error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // Demo function to simulate successful connection
    func simulateSuccess() {
        isLoading = true
        status = "Simulating connection..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.status = "Successfully connected! (Demo)"
            self.isConnected = true
            
            // Simulate account information
            self.accountInfo = AccountInfo(
                publicToken: "public-sandbox-demo-token-\(UUID().uuidString.prefix(8))",
                accountId: "demo-account-\(Int.random(in: 1000...9999))",
                institutionName: "Demo Bank"
            )
            
            print("Demo Mode: Simulated successful connection")
        }
    }
    
    // Test network connectivity
    func testNetwork() {
        isLoading = true
        status = "Testing network connectivity..."
        
        // Test with a simple HTTPS request to Google
        guard let url = URL(string: "https://www.google.com") else {
            handleError("Invalid test URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.status = "Network test failed: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse {
                    self.status = "Network OK! Google returned: \(httpResponse.statusCode)"
                    
                    // Now test Vercel backend
                    self.testVercelBackend()
                } else {
                    self.status = "Network test: Unknown response"
                }
            }
        }.resume()
    }
    
    // Test Vercel backend directly
    private func testVercelBackend() {
        guard let url = URL(string: "\(backendURL)/api/create-link-token") else { return }
        
        status = "Testing Vercel backend..."
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let body = ["user_id": "test-network-\(UUID().uuidString)"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.status = "Vercel test failed: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse {
                    self.status = "Vercel responded with: \(httpResponse.statusCode)"
                    if let data = data, let body = String(data: data, encoding: .utf8) {
                        print("Vercel response: \(body)")
                    }
                } else {
                    self.status = "Vercel test: Unknown response"
                }
            }
        }.resume()
    }
    
    // Debug link token to see what we're getting
    func debugLinkToken() {
        isLoading = true
        status = "Fetching link token for debugging..."
        
        fetchLinkToken { [weak self] linkToken in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let linkToken = linkToken {
                    // Decode the JWT to see its contents
                    let parts = linkToken.split(separator: ".")
                    
                    if parts.count >= 2 {
                        // Try to decode the payload (middle part)
                        let payload = String(parts[1])
                        
                        // JWT uses base64url encoding, we need to convert to regular base64
                        var base64 = payload
                            .replacingOccurrences(of: "-", with: "+")
                            .replacingOccurrences(of: "_", with: "/")
                        
                        // Add padding if needed
                        while base64.count % 4 != 0 {
                            base64 += "="
                        }
                        
                        if let data = Data(base64Encoded: base64),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("🔍 Link Token Payload: \(json)")
                            self.status = "Token payload: \(json["exp"] ?? "no exp") | env: \(json["environment"] ?? "unknown")"
                        } else {
                            print("🔍 Raw Link Token: \(linkToken)")
                            self.status = "Got token: \(String(linkToken.prefix(40)))..."
                        }
                    } else {
                        print("🔍 Raw Link Token: \(linkToken)")
                        self.status = "Got token: \(String(linkToken.prefix(40)))..."
                    }
                } else {
                    self.status = "Failed to get link token"
                }
            }
        }
    }
    
    // Fetch saved accounts from Supabase
    func fetchSavedAccounts() {
        // Use the user_id from Config - in a real app, you'd store this after first connection
        let userId = Config.defaultUserId
        guard let url = URL(string: "\(backendURL)/api/get-accounts?user_id=\(userId)") else {
            handleError("Invalid backend URL")
            return
        }
        
        isLoading = true
        status = "Fetching saved accounts..."
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.handleError("Failed to fetch accounts: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.handleError("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool,
                       success,
                       let items = json["data"] as? [[String: Any]] {
                        
                        if items.isEmpty {
                            self.status = "No saved accounts found"
                        } else {
                            self.status = "Found \(items.count) saved connection(s)"
                            
                            // Display account information with timestamps
                            for (index, item) in items.enumerated() {
                                if let institutionName = item["institution_name"] as? String,
                                   let accounts = item["accounts"] as? [[String: Any]],
                                   let createdAt = item["created_at"] as? String {
                                    
                                    // Format the timestamp
                                    let dateFormatter = ISO8601DateFormatter()
                                    if let date = dateFormatter.date(from: createdAt) {
                                        let displayFormatter = DateFormatter()
                                        displayFormatter.dateStyle = .medium
                                        displayFormatter.timeStyle = .short
                                        let formattedDate = displayFormatter.string(from: date)
                                        
                                        print("\n🏦 Connection #\(index + 1): \(institutionName)")
                                        print("📅 Connected on: \(formattedDate)")
                                    } else {
                                        print("\n🏦 Connection #\(index + 1): \(institutionName)")
                                    }
                                    
                                    var totalBalance = 0.0
                                    for account in accounts {
                                        if let name = account["name"] as? String,
                                           let type = account["type"] as? String,
                                           let balance = account["balance"] as? [String: Any],
                                           let current = balance["current"] as? Double {
                                            print("  💰 \(name) (\(type)): $\(String(format: "%.2f", current))")
                                            
                                            // Add to total if it's an asset (not a loan)
                                            if type == "depository" || type == "investment" {
                                                totalBalance += current
                                            }
                                        }
                                    }
                                    print("  📊 Total Assets: $\(String(format: "%.2f", totalBalance))")
                                }
                            }
                            
                            // Update status with summary
                            if items.count > 1 {
                                self.status = "Showing \(items.count) connections (newest first)"
                            }
                        }
                    } else {
                        self.handleError("Invalid response format")
                    }
                } catch {
                    self.handleError("Failed to parse response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func handleError(_ message: String) {
        isLoading = false
        status = message
        print("Plaid Error: \(message)")
    }
    
    private func topViewController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("❌ Could not find root view controller")
            return UIViewController()
        }
        
        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        
        print("🔶 Found top view controller: \(topViewController)")
        return topViewController
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 