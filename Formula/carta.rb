cask 'carta' do
  if Hardware::CPU.arm?
    # Native Apple Silicon version
    version '5.0.3'
    sha256 'e88b21a9ce9c39111eb1ab2934357f03c4651f78f5107f5a0549f15c817b3e58'
    url 'https://github.com/CARTAvis/carta/releases/download/v5.0.3/CARTA-arm64.dmg'
  else
    # Native Intel version
    version '5.0.3'
    sha256 'd9a9375b38d10a648c0a16a5025e4aab6d0d6348f284c13a1d91a3a5046f0cc7'
    url 'https://github.com/CARTAvis/carta/releases/download/v5.0.3/CARTA-x64.dmg'
  end

  name 'CARTA'
  desc 'Electron version of CARTA provided as a Homebrew Cask'
  homepage 'https://cartavis.org'

  if Hardware::CPU.arm?
    app 'CARTA.app' , target: '/opt/homebrew/Caskroom/CARTA.app'
  else
    app 'CARTA.app' , target: '/usr/local/Caskroom/CARTA.app'
  end

  postflight do
    # Setup a 'carta' executable to the 'carta.sh' script.
    # The 'carta.sh' bypasses the Electron component so that the user's default web browser is used to display the carta-frontend.
    bin_dir = Hardware::CPU.arm? ? '/opt/homebrew/bin' : '/usr/local/bin'
    bin_path = "#{bin_dir}/carta"
    carta_dir = Hardware::CPU.arm? ? '/opt/homebrew/Caskroom' : '/usr/local/Caskroom'

    File.write(bin_path, <<~EOS)
      #!/bin/bash
      #{carta_dir}/CARTA.app/Contents/Resources/app/carta-backend/bin/carta.sh "$@"
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
