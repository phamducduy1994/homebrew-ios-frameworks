#!/usr/bin/env bash
#
# Generate a Homebrew formula for a Google iOS SDK version.
#
# Usage:
#   generate-formula.sh <sdk> <version> <url> <sha256>
#
# Where <sdk> is one of:
#   googlemobileads
#   googleusermessagingplatform
#
# Writes to Formula/<sdk>@<version>.rb. Idempotent — overwrites if exists.
# Invoked by the check-updates workflow after parsing upstream Package.swift.

set -euo pipefail

sdk=${1:?missing sdk}
version=${2:?missing version}
url=${3:?missing url}
sha=${4:?missing sha256}

repo_root=$(cd "$(dirname "$0")/.." && pwd)
out=$repo_root/Formula/${sdk}@${version}.rb

# Class name: camelcase, strip @ and dots, prefix AT.
# "googlemobileads@13.0.0" -> "GooglemobileadsAT1300"
class_base=$(python3 -c "print('${sdk}'.capitalize())")
version_suffix=$(echo "${version}" | tr -d '.')
classname="${class_base}AT${version_suffix}"

case "$sdk" in
  googlemobileads)
    desc="Google Mobile Ads iOS SDK ${version}, installed as an xcframework"
    homepage="https://developers.google.com/admob/ios/quick-start"
    # GMA is under Google's commercial SDK license, which has no SPDX identifier.
    # Leaving `license` unset lets brew audit pass.
    license_line=""
    framework_name="GoogleMobileAds"
    ;;
  googleusermessagingplatform)
    desc="Google User Messaging Platform iOS SDK ${version}, installed as an xcframework"
    homepage="https://developers.google.com/admob/ump/ios/quick-start"
    license_line='license "Apache-2.0"'
    framework_name="UserMessagingPlatform"
    ;;
  *)
    echo "unknown sdk: $sdk" >&2
    exit 2
    ;;
esac

cat >"$out" <<FORMULA
class ${classname} < Formula
  desc "${desc}"
  homepage "${homepage}"
  url "${url}"
  sha256 "${sha}"
${license_line:+  ${license_line}}

  depends_on :macos
  depends_on arch: :arm64

  def install
    # Homebrew strips the single top-level directory on zip extraction, so
    # cwd at install time is already inside ${framework_name}.xcframework/.
    # Install cwd's contents into the keg's Frameworks/<name>.xcframework/.
    # Consumers reference the per-slice path directly:
    #   prefix/Frameworks/${framework_name}.xcframework/ios-arm64
    #   prefix/Frameworks/${framework_name}.xcframework/ios-arm64_x86_64-simulator
    xcframework = "${framework_name}.xcframework"
    (prefix/"Frameworks"/xcframework).install Dir["*"]
  end

  test do
    xcf = prefix/"Frameworks/${framework_name}.xcframework"
    assert_predicate xcf, :directory?, "xcframework missing"
    assert_predicate xcf/"Info.plist", :exist?, "xcframework Info.plist missing"
    assert_predicate xcf/"ios-arm64/${framework_name}.framework/${framework_name}",
                     :exist?, "device slice missing"
    assert_predicate xcf/"ios-arm64_x86_64-simulator/${framework_name}.framework/${framework_name}",
                     :exist?, "simulator slice missing"
  end
end
FORMULA

echo "wrote $out"
