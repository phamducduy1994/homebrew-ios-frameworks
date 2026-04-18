class GooglemobileadsAT1300 < Formula
  desc "Google Mobile Ads iOS SDK 13.0.0, installed as an xcframework"
  homepage "https://developers.google.com/admob/ios/quick-start"
  url "https://dl.google.com/googleadmobadssdk/fc88eeb0fca23ae3/googlemobileadsios-spm-13.0.0.zip"
  sha256 "fc88eeb0fca23ae31df34d92a4db1fcb4b497eb739f39378cb114ff512ce1080"


  depends_on :macos
  depends_on arch: :arm64

  def install
    # Homebrew strips the single top-level directory on zip extraction, so
    # cwd at install time is already inside GoogleMobileAds.xcframework/.
    # Install cwd's contents into the keg's Frameworks/<name>.xcframework/.
    # Consumers reference the per-slice path directly:
    #   prefix/Frameworks/GoogleMobileAds.xcframework/ios-arm64
    #   prefix/Frameworks/GoogleMobileAds.xcframework/ios-arm64_x86_64-simulator
    xcframework = "GoogleMobileAds.xcframework"
    (prefix/"Frameworks"/xcframework).install Dir["*"]
  end

  test do
    xcf = prefix/"Frameworks/GoogleMobileAds.xcframework"
    assert_predicate xcf, :directory?, "xcframework missing"
    assert_predicate xcf/"Info.plist", :exist?, "xcframework Info.plist missing"
    assert_predicate xcf/"ios-arm64/GoogleMobileAds.framework/GoogleMobileAds",
                     :exist?, "device slice missing"
    assert_predicate xcf/"ios-arm64_x86_64-simulator/GoogleMobileAds.framework/GoogleMobileAds",
                     :exist?, "simulator slice missing"
  end
end
