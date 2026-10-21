cask "astris" do
  version "1.0.32"
  sha256 "661f01a47816b3baeda5c6c924f92d32e7a2bf42db98483c259207f0eb5feb6f"

  url "https://github.com/V380-Ori/Astris.Binaries/releases/download/astris-1.0.32/Astris-1.0.32%2B2398e7c80.dmg"
  name "Astris"
  desc "Nintendo Switch emulator"
  homepage "https://github.com/V380-Ori/Astris.Binaries"

  depends_on arch: :arm64

  app "Astris.app"
end
