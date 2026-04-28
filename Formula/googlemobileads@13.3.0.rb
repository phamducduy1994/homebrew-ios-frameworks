class GooglemobileadsAT1330 < Formula
  desc "Google Mobile Ads iOS SDK 13.3.0, installed as an xcframework"
  homepage "https://developers.google.com/admob/ios/quick-start"
  url "https://dl.google.com/googleadmobadssdk/d9caa601b1a02d0f/googlemobileadsios-spm-13.3.0.zip"
  sha256 "d9caa601b1a02d0f96f9ce4b96acef13ff32f53b67f6ab042bf7c9870149348f"


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
