# URGENT: Action Required Before Making Repository Public

## ⚠️ Critical Security Actions Needed

Dear Repository Owner,

This repository previously contained sensitive Firebase credentials that have been removed from the current codebase. However, **these credentials are still accessible in the git commit history** and must be invalidated before making this repository public.

## Immediate Actions Required (MUST DO)

### 1. Revoke Exposed Service Account Key (CRITICAL - Do this NOW)

The file `firestore_seed/serviceAccountKey.json` containing a private key was committed in the git history.

**How to revoke:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `studnet-ai-buddy`
3. Navigate to: **IAM & Admin** → **Service Accounts**
4. Find service account: `firebase-adminsdk-fbsvc@studnet-ai-buddy.iam.gserviceaccount.com`
5. Click on it → Go to **Keys** tab
6. Find the key with ID: `e23913dbd3fa86723dfb1b9e39079169d4e85192`
7. Click **Delete** on that key
8. Generate a new key if needed (and keep it secure!)

### 2. Rotate Firebase API Keys (HIGH Priority)

The following API keys were exposed in git history:

**Web API Key**: `AIzaSyBeiqrIFi02yUGFc12T4MZ59sOq4JXMvd0`
**Android API Key**: `AIzaSyDZrKLasZtS6gZAdbplbBNIdFPM6PBp2XU`
**iOS API Key**: `AIzaSyCPXMRH7LHGATqnp9Ti-7DHwAkP3RX772c`

**How to secure:**

Option A (Recommended): Create a new Firebase project
1. Create a new Firebase project with a different name
2. Migrate your data
3. Update your application configuration
4. Delete the old project once migration is complete

Option B: Rotate keys in existing project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `studnet-ai-buddy`
3. Go to Project Settings → General
4. For each app (Web, Android, iOS), regenerate the API keys
5. Update your local configuration

### 3. Review and Restrict API Key Usage

Even after rotation, ensure your API keys have proper restrictions:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to: **APIs & Services** → **Credentials**
3. For each API key, click Edit
4. Under "Application restrictions", select appropriate restrictions (e.g., Android apps, iOS apps, HTTP referrers)
5. Under "API restrictions", limit to only the APIs your app needs

### 4. (Optional but Recommended) Clean Git History

To completely remove the sensitive data from git history:

**Using BFG Repo-Cleaner (easier):**
```bash
# Download BFG from https://rtyley.github.io/bfg-repo-cleaner/
# Clone a fresh copy
git clone --mirror https://github.com/leekonjk/ai-study-buddy-2.git

# Remove the sensitive files from history
java -jar bfg.jar --delete-files serviceAccountKey.json ai-study-buddy-2.git
java -jar bfg.jar --delete-files google-services.json ai-study-buddy-2.git
java -jar bfg.jar --delete-files firebase_options.dart ai-study-buddy-2.git

# Clean up
cd ai-study-buddy-2.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (WARNING: This will rewrite history)
git push --force
```

**Using git filter-repo (recommended by GitHub):**
```bash
# Install git-filter-repo
pip install git-filter-repo

# Clone a fresh copy
git clone https://github.com/leekonjk/ai-study-buddy-2.git
cd ai-study-buddy-2

# Remove sensitive files
git filter-repo --path firestore_seed/serviceAccountKey.json --invert-paths
git filter-repo --path android/app/google-services.json --invert-paths
git filter-repo --path lib/firebase_options.dart --invert-paths

# Force push
git push origin --force --all
```

**⚠️ WARNING**: Cleaning git history requires force-pushing, which will affect anyone who has cloned the repository. Coordinate with collaborators before doing this.

## After Completing the Above

1. ✅ Verify all old credentials have been revoked
2. ✅ Set up new Firebase configuration locally using the templates provided
3. ✅ Test that the app works with the new credentials
4. ✅ Consider enabling Firebase App Check for additional security
5. ✅ Set up monitoring alerts for unusual Firebase usage

## Files That Were Removed

- `firestore_seed/serviceAccountKey.json` - Service account private key
- `android/app/google-services.json` - Android Firebase config
- `lib/firebase_options.dart` - Multi-platform Firebase config

## Template Files Provided

- `firestore_seed/serviceAccountKey.json.template`
- `android/app/google-services.json.template`
- `lib/firebase_options.dart.template`

## Setup Instructions

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions on setting up your Firebase configuration.

## Questions?

If you have any questions about these security measures, please refer to:
- [SECURITY_AUDIT.md](SECURITY_AUDIT.md) - Full security audit report
- [GitHub's guide on removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

---

**DO NOT make this repository public until you have completed at least steps 1 and 2 above.**
