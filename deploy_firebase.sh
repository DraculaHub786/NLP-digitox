#!/bin/bash

# Firebase Deployment Script for NLP-Digitox
# This script deploys Firebase security rules and functions

set -e  # Exit on error

echo "🚀 Starting Firebase deployment..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install: npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
echo "📝 Checking Firebase authentication..."
firebase login:list

# Deploy Realtime Database rules
echo "📦 Deploying Realtime Database rules..."
firebase deploy --only database:rules

# Deploy Firestore rules
echo "📦 Deploying Firestore security rules..."
firebase deploy --only firestore:rules

# Deploy Storage rules (if exists)
if [ -f "storage.rules" ]; then
    echo "📦 Deploying Storage rules..."
    firebase deploy --only storage
fi

# Deploy Cloud Functions (if exists)
if [ -d "functions" ]; then
    echo "📦 Deploying Cloud Functions..."
    firebase deploy --only functions
fi

echo "✅ Deployment complete!"
echo ""
echo "📊 Next steps:"
echo "  1. Verify rules in Firebase Console"
echo "  2. Test with Firebase Emulator: firebase emulators:start"
echo "  3. Monitor logs: firebase functions:log"
