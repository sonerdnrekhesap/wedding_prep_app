# Store Release Checklist

## Google Play

- [ ] App name final: `Hazirlik Takibi`
- [ ] Package id final: `com.sonerdnrekhesap.hazirliktakibi`
- [ ] Production upload key created
- [ ] `android/key.properties` configured locally or in CI
- [x] Production AdMob Android app id added to `AndroidManifest.xml`
- [x] Production AdMob Android unit ids documented for `--dart-define`
- [x] App icon replaced
- [x] Splash screen replaced
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
- [ ] App Store Connect IAP products created: `premium_monthly`, `premium_6months`, `premium_lifetime`
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
- [ ] Premium checklist CSV export
- [ ] Premium budget CSV export
- [ ] Reset all data
- [ ] Offline usage
- [ ] Release AAB installed on a real Android device
- [ ] Play Console IAP products created and tested with license tester
- [ ] Store purchase restore tested on iOS sandbox

## Current Known Gaps

- AdMob apps are created but still require store linking/review after Play Store/App Store listings exist.
- Production signing key is not in the repo.
- Premium purchase skeleton is implemented; real store products and subscription validation are still pending.
- Android release builds now fail without production keystore unless `-PallowDebugReleaseSigning=true` is passed for a local test build.
- Debug APK build remains available for local QA.
- Splash is branded; final store screenshot polish remains.
- iOS build must be verified on macOS.
