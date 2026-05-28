cask "iterm2-shader-cli" do
    version "2026.05.28"
    sha256 "e33ba2c5b4fa81ccd28bc24fe65d2dddcd30ac7461be5a5e5bd3fadcff180a26"

    url "https://github.com/yatharth023/iTerm2Shader/releases/download/v0.8.0/PremiumTerminalShader-2026.05.28.tar.gz"
    name "iTerm2 Shader CLI"
    desc "Premium GPU-accelerated shader engine for terminal backgrounds"
    homepage "https://github.com/yatharth023/iTerm2Shader"

    depends_on macos: ">= :ventura"

    binary "iterm2-shader-engine", target: "#{HOMEBREW_PREFIX}/bin/iterm2-shader-engine"

    postflight do
      metallib_src = "#{staged_path}/default.metallib"
      metallib_dst = "#{HOMEBREW_PREFIX}/bin/default.metallib"
      FileUtils.cp(metallib_src, metallib_dst) if File.exist?(metallib_src)

      wrapper = <<~SCRIPT
        #!/bin/bash
        ENGINE="#{HOMEBREW_PREFIX}/bin/iterm2-shader-engine"
        PROCESS_NAME="iterm2-shader-engine"

        clear_iterm_bg() {
          osascript -e 'tell application "iTerm2" to set background image of current session of current window to ""' 2>/dev/null
        }

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
              echo "▸ Clearing stale daemon instance..."
              killall -9 "$PROCESS_NAME" >/dev/null 2>&1
              sleep 0.3
              clear_iterm_bg
            fi
            "$ENGINE" > /dev/null 2>&1 &
            echo "▸ Shader daemon launched (PID $!)"
            ;;
          stop)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              killall "$PROCESS_NAME" 2>/dev/null
              COUNTER=0
              while pgrep -x "$PROCESS_NAME" > /dev/null 2>&1 && [ $COUNTER -lt 30 ]; do
                sleep 0.1
                COUNTER=$((COUNTER + 1))
              done
              clear_iterm_bg
              echo "▸ Shader daemon stopped"
            else
              echo "▸ No shader daemon running"
            fi
            ;;
          next)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              pkill -USR1 "$PROCESS_NAME"
              sleep 0.15
              clear_iterm_bg
              echo "▸ Switched to next preset"
            else
              echo "▸ No shader daemon running — start it with: iterm2-shader start"
            fi
            ;;
          prev)
            if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
              pkill -USR2 "$PROCESS_NAME"
              sleep 0.15
              clear_iterm_bg
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
      system_command "/usr/bin/pkill",
                     args: ["-x", "iterm2-shader-engine"],
                     must_succeed: false
      wrapper_path = "#{HOMEBREW_PREFIX}/bin/iterm2-shader"
      metallib_path = "#{HOMEBREW_PREFIX}/bin/default.metallib"
      File.delete(wrapper_path) if File.exist?(wrapper_path)
      File.delete(metallib_path) if File.exist?(metallib_path)
    end

    uninstall delete: "#{HOMEBREW_PREFIX}/bin/iterm2-shader-engine"

    zap trash: [
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