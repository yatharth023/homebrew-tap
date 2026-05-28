cask "iterm2-shader-cli" do
  version "2026.05.27"
  sha256 "0a531cb35461e535cd12527c01967c1e453e0ce4ab981ef11b7dbe04d1cf5c43"

  url "https://github.com/yatharth023/iTerm2Shader/releases/download/v0.8.0/PremiumTerminalShader-2026.05.27.tar.gz"
  name "iTerm2 Shader CLI"
  desc "Pure UNIX GPU-accelerated shader daemon for terminal backgrounds"
  homepage "https://github.com/yatharth023/iTerm2Shader"

  depends_on macos: ">= :ventura"

  binary "iterm2-shader-engine"

  postflight do
    wrapper = <<~SCRIPT
      #!/bin/bash
      #
      # iterm2-shader — Pure command-line controller for the background rendering engine
      #

      BINARY="#{HOMEBREW_PREFIX}/bin/iterm2-shader-engine"
      PROCESS_NAME="iterm2-shader-engine"

      clear_iterm_bg() {
        osascript -e 'tell application "iTerm" to set background image of current session of current window to ""' >/dev/null 2>&1
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
      │    stop     Stop daemon and restore background      │
      │    next     Cycle to the next shader preset         │
      │    prev     Cycle to the previous shader preset     │
      │    list     Show all available shader presets       │
      │                                                     │
      └─────────────────────────────────────────────────────┘
      HELP
      }

      case "${1}" in
        start)
          if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
            echo "▸ Shader daemon is already running (PID \$(pgrep -x \$PROCESS_NAME))"
          else
            clear_iterm_bg
            "\$BINARY" > /dev/null 2>&1 &
            echo "▸ Pure CLI shader daemon launched successfully"
          fi
          ;;
        stop)
          if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
            killall "$PROCESS_NAME"
            clear_iterm_bg
            echo "▸ Shader daemon stopped & default canvas background restored"
          else
            clear_iterm_bg
            echo "▸ No shader daemon running"
          fi
          ;;
        next)
          if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
            pkill -USR1 "$PROCESS_NAME"
            echo "▸ Switched to next preset"
          else
            echo "▸ Daemon is not running — run: iterm2-shader start"
          fi
          ;;
        prev)
          if pgrep -x "$PROCESS_NAME" > /dev/null 2>&1; then
            pkill -USR2 "$PROCESS_NAME"
            echo "▸ Switched to previous preset"
          else
            echo "▸ Daemon is not running — run: iterm2-shader start"
          fi
          ;;
        list)
          cat <<'PRESETS'
      ┌─────────────────────────────────────────────────────┐
      │              Available Shader Presets                │
      ├─────────────────────────────────────────────────────┤
      │   1.  Spaceflight            Star field flythrough  │
      │   2.  Night-Sky-Flight       Starry night clouds    │
      │   3.  Morning-Sky-Flight     Sunrise golden hour    │
      │   4.  Ocean-Wave-Flight      Realistic ocean waves  │
      │   5.  Evening-Sky-Flight     Sunset atmosphere      │
      └─────────────────────────────────────────────────────┘
      PRESETS
          ;;
        -h|--help|help|"")
          usage
          ;;
        *)
          echo "Unknown command: \${1}"
          echo "Run 'iterm2-shader help' for usage details."
          exit 1
          ;;
      esac
    SCRIPT

    wrapper_path = "#{HOMEBREW_PREFIX}/bin/iterm2-shader"
    File.write(wrapper_path, wrapper)
    system_command "/bin/chmod", args: ["+x", wrapper_path]
  end

  uninstall_preflight do
    # Gracefully shut down the daemon engine if running
    system "/usr/bin/killall", "iterm2-shader-engine" rescue nil
    
    # Execute the clear script natively within a valid system execution wrapper
    system "osascript", "-e", 'tell application "iTerm" to set background image of current session of current window to ""' rescue nil
    
    # Clean up the binary link wrapper script
    wrapper_path = "#{HOMEBREW_PREFIX}/bin/iterm2-shader"
    File.delete(wrapper_path) if File.exist?(wrapper_path)
  end

  zap trash: [
    "~/Library/Application Support/PremiumTerminalShader",
    "~/Library/Caches/iterm2-shader-engine",
  ]
end