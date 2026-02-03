cask "carta" do
    version "5.1.0"
    on_arm do
        # Native Apple Silicon version
        sha256 "4a5e8c301b81c2f30f81a779240721af1ac2398924dc59a018a1f786f660c4d8"
        url "https://github.com/CARTAvis/carta/releases/download/v5.1.0/CARTA-arm64.dmg"
    else
        # Native Intel version
        sha256 "e143a3961546700c53aaaa5649971b5d4b884fb9359aea78efa2255c1a50d623"
        url "https://github.com/CARTAvis/carta/releases/download/v5.1.0/CARTA-x64.dmg"
    end

    name "CARTA"
    desc "Electron version of CARTA provided as a Homebrew Cask"
    homepage "https://cartavis.org"

    on_arm do
        app "CARTA.app" , target: "/opt/homebrew/Caskroom/CARTA.app"
    else
        app "CARTA.app" , target: "/usr/local/Caskroom/CARTA.app"
    end

    postflight do
        # Setup a "carta" executable to the "carta.sh" script.
        # The "carta.sh" bypasses the Electron component so that the user's default web browser is used to display the carta-frontend.
        bin_dir = Hardware::CPU.arm? ? "/opt/homebrew/bin" : "/usr/local/bin"
        bin_path = "#{bin_dir}/carta"
        carta_dir = Hardware::CPU.arm? ? "/opt/homebrew/Caskroom" : "/usr/local/Caskroom"

        File.write(bin_path, <<~EOS)
        #!/bin/bash
        #{carta_dir}/CARTA.app/Contents/Resources/app/carta-backend/bin/carta.sh "$@"
        EOS
        system_command "/bin/chmod", args: ["755", bin_path]
    end

    uninstall_postflight do
        # Remove the custom "carta" executable on uninstall
        bin_dir = Hardware::CPU.arm? ? "/opt/homebrew/bin" : "/usr/local/bin"
        bin_path = "#{bin_dir}/carta"
        system_command "/bin/rm", args: [bin_path]
    end

end
