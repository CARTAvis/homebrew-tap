cask 'carta-beta' do
  arch arm: "arm64_OS15.4", intel: "x64"

  version "5.0.0-beta.1"
  sha256 arm:   "237bc0a47258cd6b39609c503078cd069ec7a22b0a43763c445c9560de3d4782",
         intel: "3976c716b879df4524e694458a9314cd606a35ac28a5ab0ea78d475590222802"
  url "https://github.com/CARTAvis/carta/releases/download/v#{version}/CARTA-v#{version}-#{arch}.dmg",
      verified: "github.com/CARTAvis/carta/releases/download"

  name 'CARTA'
  desc 'Electron version of CARTA provided as a Homebrew Cask'
  homepage 'https://cartavis.org'

  app "CARTA-v#{version}.app"

  postflight do
    # Setup a 'carta' executable to the 'carta.sh' script.
    # The 'carta.sh' bypasses the Electron component so that the user's default web browser is used to display the carta-frontend.
    bin_dir = Hardware::CPU.arm? ? '/opt/homebrew/bin' : '/usr/local/bin'
    bin_path = "#{bin_dir}/carta-beta"

    File.write(bin_path, <<~EOS)
      #!/bin/bash
      #{appdir}/CARTA-v#{version}.app/Contents/Resources/app/carta-backend/bin/carta.sh "$@"
    EOS
    system_command '/bin/chmod', args: ['755', bin_path]
  end

  uninstall_postflight do
    # Remove the custom 'carta' executable on uninstall
    bin_dir = Hardware::CPU.arm? ? '/opt/homebrew/bin' : '/usr/local/bin'
    bin_path = "#{bin_dir}/carta-beta"
    system_command '/bin/rm', args: [bin_path]
  end
end
