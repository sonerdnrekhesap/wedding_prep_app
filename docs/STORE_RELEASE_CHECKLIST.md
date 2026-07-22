# Store Release Checklist

## Google Play

- [ ] App name final: `Hazirlik Takibi`
- [ ] Package id final: `com.sonerdnrekhesap.hazirliktakibi`
- [ ] Production upload key created
- [ ] `android/key.properties` configured locally or in CI
- [ ] Production AdMob Android app id added to `AndroidManifest.xml`
- [ ] Production AdMob unit ids passed with `--dart-define`
- [ ] App icon replaced
- [ ] Splash screen replaced
- [ ] Privacy policy hosted and URL added
- [ ] Data Safety form completed
- [ ] Content rating completed
- [ ] Support email added
- [ ] At least 5 portrait screenshots prepared
- [ ] 1024x500 feature graphic prepared
- [ ] Closed testing track created
- [ ] AAB uploaded

## App Store

- [ ] Bundle id final: `com.sonerdnrekhesap.hazirliktakibi`
- [ ] Apple Developer signing configured on macOS/Xcode
- [ ] iOS no-codesign build verified on macOS
- [ ] Production AdMob iOS app id added to `Info.plist`
- [ ] Photo permission text reviewed
- [ ] Camera permission text reviewed
- [ ] App Privacy details completed
- [ ] App screenshots prepared

## In-App QA

- [ ] First launch and onboarding
- [ ] Date, budget, bride/groom settings
- [ ] Weekly plan recommendations
- [ ] Item add/edit/delete
- [ ] Item complete/uncomplete and price entry
- [ ] Guest add/edit/delete/status changes
- [ ] CSV guest export
- [ ] Reset all data
- [ ] Offline usage
- [ ] Release AAB installed on a real Android device

## Current Known Gaps

- Real AdMob IDs are not in the repo.
- Production signing key is not in the repo.
- Premium purchase is intentionally hidden in release until real purchase integration is ready.
- App icon and splash still use template assets.
- iOS build must be verified on macOS.
