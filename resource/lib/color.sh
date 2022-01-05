
set -eu
set -o pipefail

# Return if color already loaded.
declare -f 'color::export_colors' >/dev/null && return 0

color::export_colors() {
  C_NORMAL='\e[0m'
  C_FG_YELLOW='\e[33m'
  C_FG_RED='\e[91m'
  C_FG_GREEN='\e[92m'

  BRed='\033[1;31m'    # Bold red
  BGreen='\033[1;32m'  # Bold Green
  BBlue='\033[1;34m'   # Bold Blue
  BYellow='\033[1;33m' # Bold Yellow
  NC='\033[0m'         # No Color

}

color::boldred(){
  color::export_colors
  printf '%b%s%b\n' "$BRed" "$*" "$NC"
}

color::boldgreen(){
  color::export_colors
  printf '%b%s%b\n' "$BGreen" "$*" "$NC"
}

color::boldblue(){
  color::export_colors
  printf '%b%s%b\n' "$BBlue" "$*" "$NC"
}

color::boldyellow(){
  color::export_colors
  printf '%b%s%b\n' "$BYellow" "$*" "$NC"
}

color::highlight() {
  color::export_colors
  printf '%b%s%b\n' "$C_FG_YELLOW" "$*" "$C_NORMAL"
}

color::error() {
  color::export_colors
  printf '%b[ERROR]%b %s\n' "$C_FG_RED" "$C_NORMAL" "$*"
}

color::info() {
  color::export_colors
  printf '%b[INFO]%b %s\n' "$C_FG_GREEN" "$C_NORMAL" "$*"
}