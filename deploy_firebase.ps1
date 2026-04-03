# Firebase Deployment Script for NLP-Digitox (Windows PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Firebase deployment..." -ForegroundColor Green

# Check if Firebase CLI is installed
if (!(Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Firebase CLI not found. Please install: npm install -g firebase-tools" -ForegroundColor Red
    exit 1
}

# Check if user is logged in
Write-Host "📝 Checking Firebase authentication..." -ForegroundColor Cyan
firebase login:list

# Deploy Realtime Database rules
Write-Host "📦 Deploying Realtime Database rules..." -ForegroundColor Cyan
firebase deploy --only database:rules

# Deploy Firestore rules
Write-Host "📦 Deploying Firestore security rules..." -ForegroundColor Cyan
firebase deploy --only firestore:rules

# Deploy Storage rules (if exists)
if (Test-Path "storage.rules") {
    Write-Host "📦 Deploying Storage rules..." -ForegroundColor Cyan
    firebase deploy --only storage
}

# Deploy Cloud Functions (if exists)
if (Test-Path "functions") {
    Write-Host "📦 Deploying Cloud Functions..." -ForegroundColor Cyan
    firebase deploy --only functions
}

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Next steps:"
Write-Host "  1. Verify rules in Firebase Console"
Write-Host "  2. Test with Firebase Emulator: firebase emulators:start"
Write-Host "  3. Monitor logs: firebase functions:log"
