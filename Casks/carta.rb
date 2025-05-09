cask 'carta' do
  arch arm: "arm64", intel: "x64"

  version "4.1.0"
  sha256 arm:   "4adc6a7429de51fcf55befb27166c4543353ef230a51cc4c37aab290fa51b572",
         intel: "6ef4c59053687f64010a581302ae4cde5a31992251a6824083533e726e761147"
  url "https://github.com/CARTAvis/carta/releases/download/v#{version}/CARTA-v#{version}-#{arch}.dmg",
      verified: "github.com/CARTAvis/carta/releases/download"

  name 'CARTA'
  desc 'Electron version of CARTA provided as a Homebrew Cask'
  homepage 'https://cartavis.org'

  app "CARTA.app"

  postflight do
    # Setup a 'carta' executable to the 'carta.sh' script.
    # The 'carta.sh' bypasses the Electron component so that the user's default web browser is used to display the carta-frontend.
    bin_dir = Hardware::CPU.arm? ? '/opt/homebrew/bin' : '/usr/local/bin'
    bin_path = "#{bin_dir}/carta"

    File.write(bin_path, <<~EOS)
      #!/bin/bash
      #{appdir}/CARTA.app/Contents/Resources/app/carta-backend/bin/carta.sh "$@"
    EOS
    system_command '/bin/chmod', args: ['755', bin_path]
  end

  uninstall_postflight do
    # Remove the custom 'carta' executable on uninstall
    bin_dir = Hardware::CPU.arm? ? '/opt/homebrew/bin' : '/usr/local/bin'
    bin_path = "#{bin_dir}/carta"
    system_command '/bin/rm', args: [bin_path]
  end
end
