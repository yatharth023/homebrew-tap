cask "iterm2-shader-cli" do
    version "2026.05.27"
    sha256 "359d5fc256aedcc0e3494ced074be352cf906f45b75f02718b1674ab4a70b292"

    url "https://github.com/yatharth023/iTerm2Shader/releases/download/v0.8.0/PremiumTerminalShader-2026.05.27.tar.gz"
    name "iTerm2 Shader CLI"
    desc "Premium GPU-accelerated shader engine for terminal backgrounds"
    homepage "https://github.com/yatharth023/iTerm2Shader"

    depends_on macos: ">= :ventura"

    binary "iterm2-shader-engine", target: "#{HOMEBREW_PREFIX}/bin/iterm2-shader-engine"

    postflight do
      # Copy metallib alongside the binary
      metallib_src = "#{staged_path}/default.metallib"
      metallib_dst = "#{HOMEBREW_PREFIX}/bin/default.metallib"
      FileUtils.cp(metallib_src, metallib_dst) if File.exist?(metallib_src)

      # Write the CLI wrapper script
      wrapper = <<~SCRIPT
        #!/bin/bash
        #
        # iterm2-shader — command-line interface for iterm2-shader-engine
        #

        ENGINE="#{HOMEBREW_PREFIX}/bin/iterm2-shader-engine"
        PROCESS_NAME="iterm2-shader-engine"

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
              "$ENGINE" > /dev/null 2>&1 &
              echo "▸ Shader daemon launched (PID $!)"
            fi
            ;;
          stop)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              killall "$PROCESS_NAME"
              osascript -e 'tell application "iTerm2" to set background image of current session of current window to ""'
              echo "▸ Shader daemon stopped"
            else
              echo "▸ No shader daemon running"
            fi
            ;;
          next)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              pkill -USR1 "$PROCESS_NAME"
              osascript -e 'tell application "iTerm2" to set background image of current session of current window to ""'
              echo "▸ Switched to next preset"
            else
              echo "▸ No shader daemon running — start it with: iterm2-shader start"
            fi
            ;;
          prev)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              pkill -USR2 "$PROCESS_NAME"
              osascript -e 'tell application "iTerm2" to set background image of current session of current window to ""'
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

      wrapper_path = "#{HOMEBREW_PREFIX}/bin/iterm2-shader"
      File.write(wrapper_path, wrapper)
      system_command "/bin/chmod",
                     args: ["+x", wrapper_path]
    end

    uninstall_preflight do
      # Kill the daemon if running
      system_command "/usr/bin/pkill",
                     args: ["-x", "iterm2-shader-engine"],
                     must_succeed: false

      # Remove wrapper and metallib
      wrapper_path = "#{HOMEBREW_PREFIX}/bin/iterm2-shader"
      metallib_path = "#{HOMEBREW_PREFIX}/bin/default.metallib"
      File.delete(wrapper_path) if File.exist?(wrapper_path)
      File.delete(metallib_path) if File.exist?(metallib_path)
    end

    uninstall delete: "#{HOMEBREW_PREFIX}/bin/iterm2-shader-engine"

      "~/Library/Preferences/com.premiumterminalshader.app.plist",
      "~/.config/iTerm2ShaderCLI",
    ]

    caveats <<~EOS
      iTerm2 Shader CLI installed successfully!

      Usage:
        iterm2-shader start   Launch the shader daemon
        iterm2-shader stop    Stop the shader daemon
        iterm2-shader next    Cycle to next preset
        iterm2-shader prev    Cycle to previous preset
        iterm2-shader list    Show available presets

      The engine runs as a headless UNIX background process.
      Preset cycling is controlled via UNIX signals (USR1/USR2).
      Auto-terminates when parent terminal session exits.

      Report issues:
        https://github.com/yatharth023/iTerm2Shader/issues
    EOS
  end
  
  ---
  Summary of changes:
  
  ┌────────────────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────────┐
  │                      File                      │                                   Change                                    │
  ├────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ App/main.swift                                 │ Added getppid() == 1 orphan lifecycle monitor (2s interval timer)           │
  ├────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ Rendering/HeadlessMetalRenderer.swift          │ Loads default.metallib relative to binary path via CommandLine.arguments[0] │
  ├────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ Rendering/MetalRenderer.swift                  │ Same metallib path fix                                                      │
  ├────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ App/Settings/SettingsPanelViewController.swift │ Deleted (Cocoa GUI, incompatible with CLI)                                  │
  ├────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ build.sh                                       │ Complete rewrite: xcrun metal + swiftc → flat binary + metallib             │
  ├────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ Tarball                                        │ 66KB, contains iterm2-shader-engine + default.metallib                      │
  ├────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ SHA256                                         │ 359d5fc256aedcc0e3494ced074be352cf906f45b75f02718b1674ab4a70b292            │
  └────────────────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────────┘