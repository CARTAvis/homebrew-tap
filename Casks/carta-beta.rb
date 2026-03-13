cask "carta-beta" do
    version "v6.0.0-beta.1"

    on_arm do
        # Native Apple Silicon version
        sha256 "a6b332ff80110730ca92bbe9722d41fe9cbd6d12a6ad9f1e01cdf0dbc0df2b21"

        url "https://github.com/CARTAvis/carta/releases/download/v6.0.0-beta.1/CARTA-v6.0.0-beta.1-arm64.dmg"

        app "CARTA-v6.0.0-beta.1.app", target: "/opt/homebrew/Caskroom/CARTA-v6.0.0-beta.1.app"
    end
    on_intel do
        # Native Intel version
        sha256 "227b8e57882e43755b97290e2740689386543e925f1533715a9121024c14812a"

        url "https://github.com/CARTAvis/carta/releases/download/v6.0.0-beta.1/CARTA-v6.0.0-beta.1-x64.dmg"

        app "CARTA-v6.0.0-beta.1.app", target: "/opt/homebrew/Caskroom/CARTA-v6.0.0-beta.1.app"
    end

    name "CARTA"
    desc "Electron version of CARTA provided as a Homebrew Cask"
    homepage "https://cartavis.org/"

    postflight do
        # Setup a "CARTA-v6.0.0-beta.1" executable to the "carta.sh" script.
        # The "carta.sh" bypasses the Electron component so that the user's
        # default web browser is used to display the carta-frontend.

        bin_dir = "/opt/homebrew/bin" if Hardware::CPU.arm?
        bin_dir = "/usr/local/bin" if Hardware::CPU.intel?

        carta_dir = "/opt/homebrew/Caskroom" if Hardware::CPU.arm?
        carta_dir = "/usr/local/Caskroom" if Hardware::CPU.intel?

        bin_path = "#{bin_dir}/carta-beta"

        File.write(bin_path, <<~EOS)
          #!/bin/bash
          #{carta_dir}/CARTA-v6.0.0-beta.1.app/Contents/Resources/app/carta-backend/bin/carta.sh "$@"
        EOS
        system_command "/bin/chmod", args: ["755", bin_path]
    end

    uninstall_postflight do
        # Remove the custom "CARTA-v6.0.0-beta.1" executable on uninstall
        bin_dir = "/opt/homebrew/bin" if Hardware::CPU.arm?
        bin_dir = "/usr/local/bin" if Hardware::CPU.intel?
        bin_path = "#{bin_dir}/carta-beta"
        system_command "/bin/rm", args: [bin_path]
    end
end
