cask "iterm2-shader-cli" do
    version "0.8.0"
    sha256 "0ebc3374e0dcfb14557fe37105c0c46e24bf641e9c31858fc8cb2f8a3bb72ca7"

    url "https://github.com/yatharth023/iTerm2ShaderCLI/releases/download/v0.8.0/PremiumTerminalShader-2026.05.26-v2.tar.gz"
    name "iTerm2 Shader CLI"
    desc "Premium GPU-accelerated shader engine for terminal backgrounds"
    homepage "https://github.com/yatharth023/iTerm2ShaderCLI"

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

    # Installation verification and release notes
    caveats <<~EOS
      ✅ PremiumTerminalShader v0.8.0 installed successfully!

      🎉 WHAT'S NEW IN v0.8.0 - Major Performance & Color Fix Update

      🎨 CRITICAL COLOR FIXES:
        • Fixed BGRA color channel bug - all shaders now display accurate colors!
        • Morning-Sky-Flight: Now realistic bright blue (was orange/brown)
        • Ocean-Wave-Flight: Deep ocean blues (was orange/black)
        • Night-Sky-Flight: Proper dark cosmic backdrop
        • Evening-Sky-Flight: Natural sunset gradient with clouds drifting right-to-left

      ⚡ MASSIVE PERFORMANCE IMPROVEMENTS (3× smoother!):
        • Internal rendering: 30 FPS → 60 FPS (2× faster)
        • iTerm2 refresh rate: 15 FPS → 45 FPS (3× improvement)
        • All shaders optimized (25-40% performance boost)
        • Buttery smooth animation with no lag

      ✨ VISUAL ENHANCEMENTS:
        • Morning-Sky: Bright realistic blue morning sky with white clouds
        • Night-Sky: Glowing stars with radiant halos + white clouds moving right-to-left
        • Evening-Sky: Sunless sunset gradient (deep purple → amber horizon) + drifting clouds
        • Ocean-Wave: Pure deep ocean blues with cyan wave crests
        • All clouds: Pure white/neutral (no color bias)

      🚀 QUICK START:
        1. Launch the app:
           open -a PremiumTerminalShader

           Or run in background:
           iterm2-shader &

        2. Keyboard shortcuts:
           • Cmd+1  : Cycle through presets
           • Cmd+,  : Open settings panel

      🎨 AVAILABLE PRESETS:
        • Spaceflight          : 3D star field with forward motion
        • Night-Sky-Flight     : Dark cosmic sky with glowing stars + drifting white clouds
        • Morning-Sky-Flight   : Bright blue morning sky (NOW ACTUALLY BLUE!)
        • Ocean-Wave-Flight    : Deep ocean blues with rolling waves (NOW ACTUALLY BLUE!)
        • Evening-Sky-Flight   : Sunset gradient with right-to-left cloud drift

      ⚙️   SETTINGS PANEL:
        • Real-time shader parameter tuning
        • 7 adjustable controls (Intensity, Speed, Depth, Contrast, Color Temp, Glow, Typing Reactivity)
        • Live preview while adjusting
        • Auto-save on change

      📝 Settings persist across restarts and are stored in:
         ~/Library/Preferences/com.premiumterminalshader.app.plist

      📊 PERFORMANCE:
        • Smooth 60 FPS internal rendering
        • 45 FPS iTerm2 background updates
        • Optimized GPU usage for battery efficiency

      🔧 REQUIREMENTS:
        • macOS 13.0+ (Ventura or later)
        • iTerm2 3.0.0+
        • Apple Silicon or Intel Mac

      📝 LOGS:
         Logs are written to: /tmp/iterm2shader.log
         View logs: tail -f /tmp/iterm2shader.log

      🐛 TROUBLESHOOTING:
        • Ensure iTerm2 3.0.0+ is installed
        • Background appears within 2 seconds of launch
        • Check logs if issues occur

      🐛 REPORT ISSUES:
         https://github.com/yatharth023/iTerm2ShaderCLI/issues
      📖 FULL DOCUMENTATION:
         https://github.com/yatharth023/iTerm2ShaderCLI/blob/main/README.md

      🎉 Enjoy your beautifully colored and buttery smooth animated terminal backgrounds!
    EOS
end
