# homebrew-ios-frameworks

Homebrew tap for iOS SDKs distributed as prebuilt xcframeworks — primarily
Google's ad SDKs consumed by
[`admobLib`](https://github.com/phamducduy1994/admobLib) at cinterop / link
time.

## Motivation

Kotlin Multiplatform libraries that wrap iOS Swift Packages (via plugins like
[`spmForKmp`](https://github.com/frankois944/spmForKmp)) bake absolute
filesystem paths into the published klib's cinterop manifest. Those paths
point at the publisher's SPM scratch directory and are unreachable on any
other machine, breaking `ld`'s framework resolution at consumer link time.

This tap gives consumers a deterministic, machine-independent install location
for the same Google xcframeworks that SPM would fetch, so admoblib's
klib manifest can reference a path like
`/opt/homebrew/opt/googlemobileads@13.0.0/Frameworks/GoogleMobileAds.xcframework/ios-arm64/GoogleMobileAds.framework`
that exists on every Apple Silicon Mac that has run `brew install`.

## Installation

```sh
brew tap phamducduy1994/ios-frameworks
brew install phamducduy1994/ios-frameworks/googlemobileads@13.0.0
brew install phamducduy1994/ios-frameworks/googleusermessagingplatform@3.1.0
```

## Versioning

Formula names mirror the upstream binary version exactly
(e.g. `googlemobileads@13.0.0`, not `@13`). Every upstream patch bump becomes
a separate formula. This means admoblib can pin against an exact framework
version and never risk a silent patch upgrade drifting consumers off the
tested version.

## Apple Silicon only

Homebrew's default prefix differs between arm64 (`/opt/homebrew`) and x86_64
(`/usr/local`). admoblib bakes the `/opt/homebrew` variant into its published
klib manifest, so Intel Macs are not supported.

## Automation

A daily workflow (`.github/workflows/check-updates.yml`) polls upstream Google
SPM repositories, detects new releases, and opens a PR adding a formula for
each new version.

## Formulas

| Formula | Upstream | Homebrew prefix |
|---|---|---|
| `googlemobileads@13.0.0` | [swift-package-manager-google-mobile-ads 13.0.0](https://github.com/googleads/swift-package-manager-google-mobile-ads) | `/opt/homebrew/opt/googlemobileads@13.0.0/` |
| `googleusermessagingplatform@3.1.0` | [swift-package-manager-google-user-messaging-platform 3.1.0](https://github.com/googleads/swift-package-manager-google-user-messaging-platform) | `/opt/homebrew/opt/googleusermessagingplatform@3.1.0/` |

Each formula installs the full xcframework under its keg at
`Frameworks/<Name>.xcframework/`, preserving Google's original layout
(including the `ios-arm64/` and `ios-arm64_x86_64-simulator/` slice
directories). Consumers reference the slice paths directly:

- `Frameworks/<Name>.xcframework/ios-arm64/<Name>.framework` — device slice.
- `Frameworks/<Name>.xcframework/ios-arm64_x86_64-simulator/<Name>.framework` — simulator slice.

Top-level slice symlinks (e.g. `Frameworks/ios-arm64/`) are deliberately NOT
added, because Homebrew links each keg's `Frameworks/` into
`/opt/homebrew/Frameworks/` and slice-named entries would collide across
formulas (GMA and UMP both ship `ios-arm64/`).
