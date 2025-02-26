cask 'carta-beta' do
    if Hardware::CPU.arm?
      # Native Apple Silicon version
      version '5.0.0-beta1'
      sha256 '81303791e52d94090310f767635dcd4088fb41aac1bbfb54d95e21d0622b9af1'
      url 'https://github.com/CARTAvis/carta/releases/download/v5.0.0-beta.1/CARTA-v5.0.0-beta.1-arm64.dmg'
    else
      # Native Intel version
      version '5.0.0-beta1'
      sha256 '518c77167844e984c1acf5e387d7f864d094e714d32cd946e3ebfe442a711396'
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
  