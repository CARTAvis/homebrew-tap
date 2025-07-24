cask 'carta' do
  if Hardware::CPU.arm?
    # Native Apple Silicon version
    version '5.0.0'
    sha256 'f81c72280c12a772999c3b45335bf32d83ff960168fa25f49aaf1b807ff9f28b'
    url 'https://github.com/CARTAvis/carta/releases/download/v5.0.0/CARTA-v5.0.0-arm64.dmg'
  else
    # Native Intel version
    version '5.0.0'
    sha256 'c3cf8786e8db8a9d9686ebce127be812c6fc188935508bd76cb9b50cc1b32cfc'
    url 'https://github.com/CARTAvis/carta/releases/download/v5.0.0/CARTA-v5.0.0-x64.dmg'
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
      #{carta_dir}/CARTA-v5.0.0.app/Contents/Resources/app/carta-backend/bin/carta.sh "$@"
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
