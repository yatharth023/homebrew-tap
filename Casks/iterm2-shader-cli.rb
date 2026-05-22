cask "iterm2-shader-cli" do
  version "2026.05.22"
  sha256 "873cdb697429fee335a13a7ab3e04758295b503e30444f5280bdefb5405e671b"

  url "https://github.com/yatharth023/iTerm2Shader/releases/download/v1.0.0/PremiumTerminalShader-2026.05.22.tar.gz"
  name "iTerm2 Shader CLI"
  desc "Premium GPU-accelerated shader engine for terminal backgrounds"
  homepage "https://github.com/yatharthkhattri/iTerm2Shader"

  # Requires macOS 13.0+ (Ventura) for Metal and Swift features
  depends_on macos: ">= :ventura"

  app "PremiumTerminalShader.app"

  # Create symlink for command-line access
  binary "#{appdir}/PremiumTerminalShader.app/Contents/MacOS/PremiumTerminalShader", target: "iterm2-shader"

  postflight do
    # Create preferences directory
    system_command "/bin/mkdir",
                   args: ["-p", "#{Dir.home}/.claude/projects/-Users-#{ENV['USER']}-Desktop-iTerm2ShaderCLI/memory"]

    # Set executable permissions
    system_command "/bin/chmod",
                   args: ["+x", "#{appdir}/PremiumTerminalShader.app/Contents/MacOS/PremiumTerminalShader"]
  end

  uninstall quit: "com.premiumterminalshader.app"

  zap trash: [
    "~/Library/Preferences/com.premiumterminalshader.app.plist",
    "~/Library/Application Support/PremiumTerminalShader",
    "~/Library/Caches/com.premiumterminalshader.app",
    "~/.claude/projects/-Users-#{ENV['USER']}-Desktop-iTerm2ShaderCLI"
  ]

  # Installation verification
  caveats <<~EOS
    ✅ PremiumTerminalShader installed successfully!

    🚀 Quick Start:
      1. Launch the app:
         open -a PremiumTerminalShader

      2. Use keyboard shortcuts:
         • Cmd+1       : Cycle through presets
         • Cmd+,       : Open settings panel
         • Cmd+D       : Toggle diagnostics overlay

    🎨 Available Presets:
      • Spaceflight          : Classic star field
      • Night-Sky-Flight     : Starry night with clouds
      • Morning-Sky-Flight   : Sunrise with golden clouds
      • Ocean-Wave-Flight    : Realistic ocean waves
      • Evening-Sky-Flight   : Sunset sky

    ⚙️  Settings Panel Features:
      • Real-time shader parameter tuning
      • 7 adjustable controls (Intensity, Speed, Depth, etc.)
      • Live preview while adjusting
      • Auto-save on change

    📝 Settings persist across app restarts and are stored in:
       ~/Library/Preferences/com.premiumterminalshader.app.plist

    🐛 Report issues:
       https://github.com/yatharthkhattri/iTerm2ShaderCLI/issues

    📖 Full documentation:
       https://github.com/yatharthkhattri/iTerm2ShaderCLI/blob/main/README.md
  EOS
end
