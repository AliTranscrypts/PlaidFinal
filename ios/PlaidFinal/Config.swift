//
//  Config.swift
//  PlaidFinal
//
//  Configuration file containing all environment variables and API endpoints
//

import Foundation

enum Config {
    // Backend Configuration
    static let backendURL = "https://plaid-backend-ls8zfv8y0-2fa-transcrypts-projects.vercel.app"
    
    // User Configuration
    static let defaultUserId = "user_123"
    static let appName = "PlaidFinal"
    
    // Plaid Configuration (for reference - actual values are in backend)
    static let plaidProducts = ["auth"]
    static let plaidCountryCodes = ["US"]
    
    // Debug Configuration
    static let enableDebugLogging = true
    static let networkTimeout: TimeInterval = 30.0
    
    // Supabase Configuration (for reference - actual values are in backend)
    static let supabaseProjectRef = "gopghvkksnlzisvaazhl"
} 