# Store Release Checklist

## Google Play

- [ ] App name final: `Hazirlik Takibi`
- [ ] Package id final: `com.sonerdnrekhesap.hazirliktakibi`
- [ ] Production upload key created
- [ ] `android/key.properties` configured locally or in CI
- [x] Production AdMob Android app id added to `AndroidManifest.xml`
- [x] Production AdMob Android unit ids documented for `--dart-define`
- [x] App icon replaced
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
- [x] Production AdMob iOS app id added to `Info.plist`
- [x] Production AdMob iOS unit ids documented for `--dart-define`
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

- AdMob apps are created but still require store linking/review after Play Store/App Store listings exist.
- Production signing key is not in the repo.
- Premium purchase is intentionally hidden in release until real purchase integration is ready.
- Splash still uses template assets.
- iOS build must be verified on macOS.
