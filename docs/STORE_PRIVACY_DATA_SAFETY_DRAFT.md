# Store Privacy And Data Safety Draft

Date: 24 July 2026

This draft must be reviewed against the final store build before submission.

## Data Collection Summary

Current app behavior:

- No required account login.
- Core planning data is stored locally on the device.
- User-entered names, budget values, checklist items, guest details and notes are not uploaded to an app backend.
- Photo/receipt files selected by the user are stored locally for app use.
- Sharing/export actions are user-initiated through the operating system share sheet.
- Ads use Google Mobile Ads/AdMob when enabled and when the user is not premium.
- In-app purchases use App Store / Google Play purchase infrastructure.
- Monetization funnel counters for QA/product tuning are stored locally on device and are not uploaded to a developer backend in the current build.

## Google Play Data Safety Draft

Data collected by the app developer:

- Personal info: Not collected by developer backend.
- Financial info: Not collected by developer backend. Budget values are stored locally.
- Photos and videos: User-selected photos can be stored locally; not uploaded by developer backend.
- App activity: Not collected by developer backend. Local monetization counters stay on device.
- Device or other IDs: AdMob/Google Play services may process identifiers for ads, fraud prevention and purchases.

Data sharing:

- Ads: Google Mobile Ads may process ad-related data according to Google policies.
- Purchases: Google Play billing handles purchase events.
- User-initiated sharing: CSV/report files can be shared to apps selected by the user.

Security:

- Planning data is local to the device.
- No custom backend transmission is used in the current version.

Delete data:

- User can reset app data from Settings.
- Removing the app also removes local app data according to platform behavior.

## App Store Privacy Draft

Data used to track:

- None by the app developer.
- Review AdMob configuration before submission, because ad SDK behavior may require declaring identifiers/usage.

Data linked to user:

- Purchases may be handled by Apple.
- The app developer does not operate a login system or backend profile.

Data not linked to user:

- Local checklist, budget, guest, note and photo data remain on device unless the user shares/export files.

## Permission Texts

Photos:

- Used so the user can attach inspiration, product and receipt photos to preparation items.

Camera:

- Used if camera capture is enabled by platform picker for adding item photos.

## Manual Review Before Submit

- Confirm no analytics SDK has been added.
- Confirm final AdMob privacy disclosures.
- Confirm final IAP product list only includes enabled products.
- Confirm privacy policy URL matches this behavior.
