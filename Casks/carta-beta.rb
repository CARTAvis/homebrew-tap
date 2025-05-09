cask 'carta-beta' do
  if Hardware::CPU.arm?
    # Native Apple Silicon version
    version '5.0.0-beta.1'
    sha256 '237bc0a47258cd6b39609c503078cd069ec7a22b0a43763c445c9560de3d4782'
    url 'https://github.com/CARTAvis/carta/releases/download/v5.0.0-beta.1/CARTA-v5.0.0-beta.1-arm64_OS15.4.dmg'
  else
    # Native Intel version
    version '5.0.0-beta.1'
    sha256 '3976c716b879df4524e694458a9314cd606a35ac28a5ab0ea78d475590222802'
    url 'https://github.com/CARTAvis/carta/releases/download/v5.0.0-beta.1/CARTA-v5.0.0-beta.1-x64.dmg'
  end

  name 'CARTA'
  desc 'Electron version of CARTA provided as a Homebrew Cask'
  homepage 'https://cartavis.org'

  if Hardware::CPU.arm?
    app 'CARTA-v5.0.0-beta.1.app' , target: '/opt/homebrew/Caskroom/CARTA-v5.0.0-beta.1.app'
  else
    app 'CARTA-v5.0.0-beta.1.app' , target: '/usr/local/Caskroom/CARTA-v5.0.0-beta.1.app'
  end

  postflight do
    # Setup a 'carta' executable to the 'carta.sh' script.
    # The 'carta.sh' bypasses the Electron component so that the user's default web browser is used to display the carta-frontend.
    bin_dir = Hardware::CPU.arm? ? '/opt/homebrew/bin' : '/usr/local/bin'
    bin_path = "#{bin_dir}/carta-beta"
    carta_dir = Hardware::CPU.arm? ? '/opt/homebrew/Caskroom' : '/usr/local/Caskroom'

    File.write(bin_path, <<~EOS)
      #!/bin/bash
      #{carta_dir}/CARTA-v5.0.0-beta.1.app/Contents/Resources/app/carta-backend/bin/carta.sh "$@"
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
