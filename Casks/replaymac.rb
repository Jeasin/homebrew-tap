cask "replaymac" do
  version "2.3.0"
  sha256 "e8b7091b25c91ef3fed19cc7e753684a63215c682835b66614aeb2e3766895d9"

  url "https://github.com/picccassso/ReplayMac/releases/download/v#{version}/ReplayMac-#{version}.dmg"
  name "ReplayMac"
  desc "Menu bar instant-replay clipper"
  homepage "https://github.com/picccassso/ReplayMac"

  livecheck do
    url :url
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on macos: :sequoia

  app "ReplayMac.app"

  zap trash: [
    "~/Library/Application Scripts/com.replaymac.app",
    "~/Library/Containers/com.replaymac.app",
  ]
end
