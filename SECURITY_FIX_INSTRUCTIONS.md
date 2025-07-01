# Security Fix Instructions for Exposed API Key

## Immediate Actions Required:

### 1. ✅ Added google-services.json to .gitignore
Already completed - the file is now ignored by git.

### 2. Remove Sensitive File from Git History

Since the API key was exposed in commit 66aa651b, you need to:

#### Option A: Using BFG Repo-Cleaner (Recommended)
```bash
# Download BFG
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar

# Remove google-services.json from history
java -jar bfg-1.14.0.jar --delete-files google-services.json

# Clean up the repository
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# Force push to remove from remote
git push origin --force --all
git push origin --force --tags
```

#### Option B: Using git filter-repo
```bash
# Install git-filter-repo
pip install git-filter-repo

# Remove the file from history
git filter-repo --invert-paths --path google-services.json

# Force push
git push origin --force --all
```

### 3. Rotate Your API Key in Firebase Console

**CRITICAL**: Since your API key `AIzaSyDbrINFFXiT21lRzuI14uZToGVZfM77R3Y` is exposed:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `mdreader-59a15`
3. Go to Project Settings → General
4. Scroll to "Web API Key" section
5. Click "Regenerate key" or create a new one
6. Update your local google-services.json with the new key

### 4. Restrict Your API Key

In Google Cloud Console:
1. Go to [APIs & Services → Credentials](https://console.cloud.google.com/apis/credentials)
2. Find your API key
3. Click on it and add restrictions:
   - Application restrictions: HTTP referrers (for web)
   - API restrictions: Select only the APIs your app uses

### 5. For Web Deployment

Good news: For Firebase Hosting (web deployment), you don't need google-services.json at all! This file is only for Android/iOS apps.

For web, Firebase config is usually embedded in the HTML/JavaScript, and web API keys are meant to be public (but should be restricted by domain).

## Prevention for Future:

1. **Never commit sensitive files**: Always add them to .gitignore first
2. **Use environment variables**: For sensitive data in web apps
3. **Enable Secret Scanning**: In your GitHub repository settings
4. **Pre-commit hooks**: Install tools like `gitleaks` to prevent accidental commits

## Next Steps:

1. Clean the git history using one of the methods above
2. Rotate the API key in Firebase Console
3. Add API key restrictions
4. Force push the cleaned repository

Remember: Anyone who cloned or forked your repository before the cleanup will still have access to the old API key, which is why rotation is critical.