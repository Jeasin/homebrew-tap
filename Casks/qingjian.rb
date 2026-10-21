# frozen_string_literal: true

cask "qingjian" do
  version "0.2.1"
  sha256 "7b3c23361642d59bb914c89a5ab3314a3ff4eb40e71e5242e54ec4467c5cb633"

  url "https://github.com/qingjian-team/qingjian/releases/download/v#{version}/qingjian-#{version}-macos-arm64.pkg"
  name "青简"
  desc "Chinese input method"
  homepage "https://github.com/qingjian-team/qingjian"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :ventura

  pkg "qingjian-#{version}-macos-arm64.pkg"

  uninstall pkgutil: "app.qingjian.inputmethod"
end
