cask "jpop-corpus-tool" do
  version "0.3.5"
  sha256 "f71e7f995633dc75972e46bad877d0c395012ee1ae68541a7b613993aa4c779d"

  url "https://github.com/Yisoragoto/jpop-corpus-tool/releases/download/v#{version}/JPOP.Corpus.Tool_#{version}_macOS_arm64.dmg"
  name "JPOP Corpus Tool"
  desc "Local J-pop corpus search, Anki card generation and synced lyrics player"
  homepage "https://github.com/Yisoragoto/jpop-corpus-tool"

  livecheck do
    url :url
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "JPOP Corpus.app"

  zap trash: [
    "~/Library/Application Support/io.github.yisoragoto.jpcorpus",
    "~/Library/Caches/io.github.yisoragoto.jpcorpus",
    "~/Library/Preferences/io.github.yisoragoto.jpcorpus.plist",
    "~/Library/Saved Application State/io.github.yisoragoto.jpcorpus.savedState",
    "~/Library/WebKit/io.github.yisoragoto.jpcorpus",
  ]
end
