# Wishlist

Native SwiftUI wishlist app for iOS 17+ (adaptive to iPadOS + macOS) using iCloud/CloudKit and Sign in with Apple.

## Features
- Sign in with Apple for private accounts
- Create/manage wishlist boards
- Add products from URLs with automatic metadata extraction
- Offline-friendly CloudKit sync in the private database
- Dark, glassmorphic interface with haptics and animations

## Architecture
- SwiftUI + MVVM
- Services: Authentication, CloudKit persistence, metadata ingestion
- Dependency-injected view models using async/await

## CloudKit
Schema is defined in `Documentation/CloudKitSchema.md`. Uses the default container with private database.

## Running
Open the project in Xcode 15+, ensure iCloud and Sign in with Apple capabilities are enabled, and set the bundle identifier to your team. Build for iOS 17+.
