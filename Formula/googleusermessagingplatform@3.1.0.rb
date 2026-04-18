class GoogleusermessagingplatformAT310 < Formula
  desc "Google User Messaging Platform iOS SDK 3.1.0, installed as an xcframework"
  homepage "https://developers.google.com/admob/ump/ios/quick-start"
  url "https://dl.google.com/googleadmobadssdk/90fe6bf3b0f4ce0d/googleusermessagingplatformios-spm-3.1.0.zip"
  sha256 "90fe6bf3b0f4ce0d0199628c0871de58b6f673375148b98d52348aecc86db231"
  license "Apache-2.0"

  depends_on :macos
  depends_on arch: :arm64

  def install
    # Homebrew strips the single top-level directory on zip extraction, so
    # cwd at install time is already inside UserMessagingPlatform.xcframework/.
    # Install cwd's contents into the keg's Frameworks/<name>.xcframework/.
    # Consumers reference the per-slice path directly:
    #   prefix/Frameworks/UserMessagingPlatform.xcframework/ios-arm64
    #   prefix/Frameworks/UserMessagingPlatform.xcframework/ios-arm64_x86_64-simulator
    xcframework = "UserMessagingPlatform.xcframework"
    (prefix/"Frameworks"/xcframework).install Dir["*"]
  end

  test do
    xcf = prefix/"Frameworks/UserMessagingPlatform.xcframework"
    assert_predicate xcf, :directory?, "xcframework missing"
    assert_predicate xcf/"Info.plist", :exist?, "xcframework Info.plist missing"
    assert_predicate xcf/"ios-arm64/UserMessagingPlatform.framework/UserMessagingPlatform",
                     :exist?, "device slice missing"
    assert_predicate xcf/"ios-arm64_x86_64-simulator/UserMessagingPlatform.framework/UserMessagingPlatform",
                     :exist?, "simulator slice missing"
  end
end
