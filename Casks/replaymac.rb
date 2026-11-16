cask "replaymac" do
  version "2.4.0"
  sha256 "fa4a719fca8429f73f6aec7e078a5ecf6cfbdec8fbd9a12a9053d9f13502e43b"

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
