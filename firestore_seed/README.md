# Firestore Seed Script

This directory contains a script to seed your Firestore database with initial data.

## ⚠️ Security Warning

**NEVER** commit `serviceAccountKey.json` to version control! This file contains sensitive credentials that grant administrative access to your Firebase project.

## Setup

1. **Generate a Service Account Key**
   
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save the downloaded file as `serviceAccountKey.json` in this directory

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Run the Seeding Script**
   ```bash
   node seed.js
   ```

## File Structure

- `serviceAccountKey.json.template` - Template file showing the structure of the service account key
- `serviceAccountKey.json` - **Your actual service account key (gitignored, DO NOT COMMIT)**
- `package.json` - Node.js dependencies
- `seed.js` - The seeding script (if present)

## Notes

- The `serviceAccountKey.json` file is already added to `.gitignore` to prevent accidental commits
- Keep your service account key secure and never share it publicly
- Use different service accounts for development and production environments
- Regularly rotate your service account keys for security
