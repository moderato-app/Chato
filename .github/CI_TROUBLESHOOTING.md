 # CI Build Troubleshooting Guide

## Common Build Failures

### Provisioning Profile Expired

**Error:**
```
Provisioning profile "github-action" expired on Sep 26, 2025.
```

**Solution:**
1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list)
2. Create a new App Store Distribution provisioning profile for your app
3. Download the new `.mobileprovision` file
4. Update the GitHub secret:
   - Go to your repository → Settings → Secrets and variables → Actions
   - Update `MOBILEPROVISION` with the base64-encoded content of the new profile:
     ```bash
     base64 -i path/to/your/profile.mobileprovision | pbcopy
     ```
   - Paste the result into the `MOBILEPROVISION` secret

### Certificate Mismatch

**Error:**
```
No certificate matching '***' found: Select a different signing certificate for CODE_SIGN_IDENTITY
```

**Solution:**
1. Ensure your certificate matches the provisioning profile:
   - The certificate used in `CERTIFICATES_P12` must be the one associated with the provisioning profile
   - The `CODE_SIGN_IDENTITY` must match the certificate name exactly
2. Verify in Apple Developer Portal that:
   - Your certificate is valid and not revoked
   - The provisioning profile is associated with the correct certificate
3. If needed, update GitHub secrets:
   - `CERTIFICATES_P12`: Base64-encoded .p12 certificate file
   - `CERTIFICATES_P12_PASSWORD`: Password for the .p12 file
   - `CODE_SIGN_IDENTITY`: Exact name of the certificate (e.g., "Apple Distribution: Your Name")

### How to Generate Base64 Secrets

**For provisioning profile:**
```bash
base64 -i path/to/profile.mobileprovision | pbcopy
```

**For certificate (.p12):**
```bash
base64 -i path/to/certificate.p12 | pbcopy
```

## Required GitHub Secrets

Make sure these secrets are set in your repository:

- `CERTIFICATES_P12`: Base64-encoded .p12 certificate
- `CERTIFICATES_P12_PASSWORD`: Password for the .p12 file
- `MOBILEPROVISION`: Base64-encoded .mobileprovision file
- `CODE_SIGN_IDENTITY`: Certificate name (e.g., "Apple Distribution: Your Name")
- `TEAM_ID`: Your Apple Developer Team ID

## Checking Secret Values

To verify your secrets are set correctly:
1. Go to repository Settings → Secrets and variables → Actions
2. Ensure all required secrets are present
3. For `CODE_SIGN_IDENTITY`, check the exact name by running:
   ```bash
   security find-identity -v -p codesigning
   ```
