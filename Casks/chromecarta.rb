cask "chromecarta" do
  version "2.0.0"
  sha256 :no_check
  url "http://alma.asiaa.sinica.edu.tw/_downloads/chromeCARTA.tgz",
      verified: "http://alma.asiaa.sinica.edu.tw"
  name "chromeCARTA"
  desc "Launcher for Homebrew installed CARTA"
  homepage "https://cartavis.org/"
  app "chromeCARTA.app"
end
