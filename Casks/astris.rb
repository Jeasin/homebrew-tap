cask "astris" do
  version "1.0.32,2398e7c80"
  sha256 "661f01a47816b3baeda5c6c924f92d32e7a2bf42db98483c259207f0eb5feb6f"

  url "https://github.com/V380-Ori/Astris.Binaries/releases/download/astris-#{version.csv.first}/Astris-#{version.csv.first}%2B#{version.csv.second}.dmg"
  name "Astris"
  desc "Nintendo Switch emulator"
  homepage "https://github.com/V380-Ori/Astris.Binaries"

  livecheck do
    url :url
    regex(/astris[._-]?v?(\d+(?:\.\d+)+)/i)
  end

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Astris.app"

  zap trash: [
    "~/Library/Application Support/Astris",
    "~/Library/Caches/V380-Ori.Astris",
    "~/Library/Preferences/V380-Ori.Astris.plist",
    "~/Library/Saved Application State/V380-Ori.Astris.savedState",
  ]
end
