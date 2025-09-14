#!/usr/bin/env bash
# Simple CLI uploader for PlatformIO ESP8266 projects
# Usage examples:
#   ./upload.sh                      # auto-detect port, build + upload
#   ./upload.sh -p /dev/ttyUSB0      # specify port
#   ./upload.sh -m                   # upload then open serial monitor
#   ./upload.sh -e esp12e            # specify env (default: esp12e)
#   ./upload.sh -b 115200            # set monitor baud (default: 115200)
#   ./upload.sh --dry-run            # show what would run

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ENV_NAME="esp12e"
PORT=""
OPEN_MONITOR=false
MONITOR_BAUD=115200
DRY_RUN=false

print_help() {
  cat <<EOF
PlatformIO upload helper

Options:
  -e, --env <name>        PlatformIO environment name (default: esp12e)
  -p, --port <port>       Serial port (e.g. /dev/ttyUSB0, COM3). Auto-detect if omitted
  -b, --baud <number>     Serial monitor baud rate (default: 115200)
  -m, --monitor           Open serial monitor after upload
      --dry-run           Print commands without executing
  -h, --help              Show this help
EOF
}

# Detect OS platform
OS="$(uname -s 2>/dev/null || echo Unknown)"

# Best-effort serial port auto-detection without jq
find_port() {
  # If PlatformIO can list devices, try to grab the first matching port
  if command -v pio >/dev/null 2>&1; then
    local first
    first=$(pio device list 2>/dev/null | awk '/(tty|cu|COM)/ {print $2; exit}') || true
    if [[ -n "${first:-}" ]]; then
      echo "$first"
      return 0
    fi
  fi

  case "$OS" in
    Darwin)
      # macOS common USB serial names
      for p in /dev/tty.usbserial-* /dev/tty.usbmodem* /dev/cu.usbserial-* /dev/cu.wchusbserial* /dev/cu.SLAB_USBtoUART; do
        [[ -e "$p" ]] && echo "$p" && return 0
      done
      ;;
    Linux)
      for p in /dev/ttyUSB* /dev/ttyACM* /dev/ttyAMA*; do
        [[ -e "$p" ]] && echo "$p" && return 0
      done
      ;;
    MINGW*|MSYS*|CYGWIN*)
      # Git Bash / MSYS: rely on PlatformIO listing
      ;;
  esac

  return 1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)
      ENV_NAME="$2"; shift 2;;
    -p|--port)
      PORT="$2"; shift 2;;
    -b|--baud)
      MONITOR_BAUD="$2"; shift 2;;
    -m|--monitor)
      OPEN_MONITOR=true; shift;;
    --dry-run)
      DRY_RUN=true; shift;;
    -h|--help)
      print_help; exit 0;;
    *)
      echo "Unknown option: $1" >&2; print_help; exit 1;;
  esac
done

# Check PlatformIO
if ! command -v pio >/dev/null 2>&1; then
  echo "Error: PlatformIO (pio) is not installed. Install with: pip install platformio" >&2
  exit 1
fi

# Ensure platformio.ini exists here
if [[ ! -f platformio.ini ]]; then
  echo "Error: platformio.ini not found in $(pwd). Run this script from the platformio/ folder." >&2
  exit 1
fi

# Auto-detect port if not provided
if [[ -z "$PORT" ]]; then
  if PORT=$(find_port); then
    echo "Auto-detected serial port: $PORT"
  else
    echo "Warning: Could not auto-detect serial port." >&2
    echo "Hint: connect your board and try again, or pass --port manually." >&2
  fi
fi

BUILD_CMD=(pio run -e "$ENV_NAME")
UPLOAD_CMD=(pio run -e "$ENV_NAME" --target upload)
MONITOR_CMD=(pio device monitor --baud "$MONITOR_BAUD")

# Append port if available
if [[ -n "$PORT" ]]; then
  UPLOAD_CMD+=(--upload-port "$PORT")
  MONITOR_CMD+=(--port "$PORT")
fi

run_cmd() {
  echo "+ $*"
  if [[ "$DRY_RUN" == true ]]; then
    return 0
  fi
  "$@"
}

# Build
run_cmd "${BUILD_CMD[@]}"
# Upload
run_cmd "${UPLOAD_CMD[@]}"

# Optional monitor
if [[ "$OPEN_MONITOR" == true ]]; then
  echo "Opening serial monitor (baud=$MONITOR_BAUD)..."
  run_cmd "${MONITOR_CMD[@]}"
fi

echo "Done."
