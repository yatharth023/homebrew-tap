 cask "iterm2-shader-cli" do
    version "2026.05.22"
    sha256 "9e0ba9ef2241122e124233f80f31e05f79d4e6d9afebec6f15fb9444ad300045"

    url "https://github.com/yatharthkhattri/iTerm2ShaderCLI/releases/download/v#{version}/PremiumTerminalShader-#{version}.tar.gz"
    name "iTerm2 Shader CLI"
    desc "Premium GPU-accelerated shader engine for terminal backgrounds"
    homepage "https://github.com/yatharthkhattri/iTerm2ShaderCLI"

    depends_on macos: ">= :ventura"

    app "PremiumTerminalShader.app"

    postflight do
      # Set executable permissions on the daemon binary
      system_command "/bin/chmod",
                     args: ["+x", "#{appdir}/PremiumTerminalShader.app/Contents/MacOS/PremiumTerminalShader"]

      # Write the CLI wrapper script
      wrapper = <<~SCRIPT
        #!/bin/bash
        #
        # iterm2-shader — command-line interface for PremiumTerminalShader daemon
        #

        APP="#{appdir}/PremiumTerminalShader.app/Contents/MacOS/PremiumTerminalShader"
        PROCESS_NAME="PremiumTerminalShader"

        usage() {
          cat <<'HELP'
        ┌─────────────────────────────────────────────────────┐
        │           iterm2-shader · CLI Interface              │
        │   Premium GPU-Accelerated Terminal Shader Engine     │
        ├─────────────────────────────────────────────────────┤
        │                                                     │
        │  USAGE:                                             │
        │    iterm2-shader <command>                           │
        │                                                     │
        │  COMMANDS:                                          │
        │    start    Launch the shader daemon (background)   │
        │    stop     Stop the running shader daemon          │
        │    next     Cycle to the next shader preset         │
        │    prev     Cycle to the previous shader preset     │
        │    list     Show all available shader presets       │
        │                                                     │
        │  EXAMPLES:                                          │
        │    iterm2-shader start                              │
        │    iterm2-shader next                               │
        │    iterm2-shader stop                               │
        │                                                     │
        └─────────────────────────────────────────────────────┘
        HELP
        }

        case "${1}" in
          start)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              echo "▸ Shader daemon is already running (PID $(pgrep -x $PROCESS_NAME))"
            else
              "$APP" > /dev/null 2>&1 &
              echo "▸ Shader daemon launched"
            fi
            ;;
          stop)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              killall "$PROCESS_NAME"
              echo "▸ Shader daemon stopped"
            else
              echo "▸ No shader daemon running"
            fi
            ;;
          next)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              pkill -USR1 "$PROCESS_NAME"
              echo "▸ Switched to next preset"
            else
              echo "▸ No shader daemon running — start it with: iterm2-shader start"
            fi
            ;;
          prev)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              pkill -USR2 "$PROCESS_NAME"
              echo "▸ Switched to previous preset"
            else
              echo "▸ No shader daemon running — start it with: iterm2-shader start"
            fi
            ;;
          list)
            cat <<'PRESETS'
        ┌─────────────────────────────────────────────────────┐
        │              Available Shader Presets                │
        ├─────────────────────────────────────────────────────┤
        │                                                     │
        │   1.  Spaceflight            Star field flythrough  │
        │   2.  Night-Sky-Flight       Starry night clouds    │
        │   3.  Morning-Sky-Flight     Sunrise golden hour    │
        │   4.  Ocean-Wave-Flight      Realistic ocean waves  │
        │   5.  Evening-Sky-Flight     Sunset atmosphere      │
        │                                                     │
        └─────────────────────────────────────────────────────┘
        PRESETS
            ;;
          -h|--help|help|"")
            usage
            ;;
          *)
            echo "Unknown command: ${1}"
            echo "Run 'iterm2-shader --help' for usage information."
            exit 1
            ;;
        esac
      SCRIPT

      # Write wrapper to Homebrew bin directory
      wrapper_path = "#{HOMEBREW_PREFIX}/bin/iterm2-shader"
      File.write(wrapper_path, wrapper)
      system_command "/bin/chmod",
                     args: ["+x", wrapper_path]
    end

    uninstall_preflight do
      # Remove the CLI wrapper script
      wrapper_path = "#{HOMEBREW_PREFIX}/bin/iterm2-shader"
      File.delete(wrapper_path) if File.exist?(wrapper_path)
    end

    uninstall quit:   "com.premiumterminalshader.app",
              signal: ["TERM", "com.premiumterminalshader.app"]

    zap trash: [
      "~/Library/Preferences/com.premiumterminalshader.app.plist",
      "~/Library/Application Support/PremiumTerminalShader",
      "~/Library/Caches/com.premiumterminalshader.app",
    ]

    caveats <<~EOS
      iTerm2 Shader CLI installed successfully!

      Usage:
        iterm2-shader start   Launch the shader daemon
        iterm2-shader stop    Stop the shader daemon
        iterm2-shader next    Cycle to next preset
        iterm2-shader prev    Cycle to previous preset
        iterm2-shader list    Show available presets

      The daemon runs as a headless background process.
      Preset cycling is controlled via UNIX signals (USR1/USR2).

      Report issues:
        https://github.com/yatharthkhattri/iTerm2ShaderCLI/issues
    EOS
  end