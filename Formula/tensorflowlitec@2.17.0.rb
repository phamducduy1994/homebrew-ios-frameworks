class TensorflowlitecAT2170 < Formula
  desc "TensorFlow Lite C 2.17.0, installed as xcframeworks (Core + CoreML + Metal)"
  homepage "https://github.com/tensorflow/tensorflow"
  url "https://dl.google.com/tflite-release/ios/prod/tensorflow/lite/release/ios/release/32/20240729-115310/TensorFlowLiteC/2.17.0/0c10b3543e01f547/TensorFlowLiteC-2.17.0.tar.gz"
  sha256 "9667b476015f136e5b332ce040e12822c4ac6d5c58947882ddc809cdff0fb99e"

  depends_on arch: :arm64
  depends_on :macos

  def install
    # Homebrew strips the single top-level directory on extraction, so cwd at
    # install time is already inside TensorFlowLiteC-2.17.0/. The tarball ships
    # a Frameworks/ subtree containing three xcframeworks plus a README.
    # Consumers reference per-slice paths directly, e.g.:
    #   prefix/Frameworks/TensorFlowLiteC.xcframework/ios-arm64
    #   prefix/Frameworks/TensorFlowLiteC.xcframework/ios-arm64_x86_64-simulator
    prefix.install "Frameworks"
  end

  test do
    %w[TensorFlowLiteC TensorFlowLiteCCoreML TensorFlowLiteCMetal].each do |name|
      xcf = prefix/"Frameworks/#{name}.xcframework"
      assert_predicate xcf, :directory?, "#{name}.xcframework missing"
      assert_path_exists xcf/"Info.plist"
      assert_path_exists xcf/"ios-arm64/#{name}.framework/#{name}"
      assert_path_exists xcf/"ios-arm64_x86_64-simulator/#{name}.framework/#{name}"
    end
  end
end
