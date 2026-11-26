#!/bin/sh
# Get started with these dotfiles on a new machine:
#
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/jace/dotfiles/main/install.sh)"
#
# or with wget: sh -c "$(wget -qO- https://raw.githubusercontent.com/jace/dotfiles/main/install.sh)"
#
# It asks before installing anything. Tools come from the system's package
# manager first, then deb-get (on Debian and Ubuntu), then Homebrew, then Snap;
# when the chosen tier (see README.md) has tools none of them can install, it
# offers to install deb-get and then Homebrew. Then it
# sets up the dotfiles with `chezmoi init`. Pass a tier to skip that question:
#   sh install.sh [minimal|essential|recommended|toolbox]
# Set DOTFILES_YES=1 to answer yes to every question (unattended installs).
#
# Plain POSIX sh, so it also runs in dash.

set -u

REPO=https://github.com/jace/dotfiles.git

# The tiers. Names are the tool's usual name; pkg_name maps them per package
# manager. Keep these lists in step with the tables in README.md.
TIER_MINIMAL="git curl chezmoi"
TIER_ESSENTIAL="zsh tmux et ssh-import-id less lesspipe rsync htop ncdu jq ripgrep fd bat fzf zoxide direnv"
TIER_RECOMMENDED="eza yazi broot jless fq gron jc glow git-delta difftastic lazygit mcfly dust duf procs btop hexyl numbat chafa timg resvg ffmpeg pandoc doxx 7zip uv gh grc lsd"
TIER_TOOLBOX="rclone mtr nmap iperf3 tcpdump smartmontools tio picocom"

# Python tools that `uv tool install` can provide where no package manager has them
UV_TOOLS="ssh-import-id"

# Nerd Fonts for machines with a local terminal: MesloLGS for terminals, Fira
# Code for editors.
# Release archive, family name as fontconfig lists it, Homebrew cask.
NERD_FONTS="Meslo:MesloLGS_Nerd_Font:font-meslo-lg-nerd-font FiraCode:FiraCode_Nerd_Font:font-fira-code-nerd-font"

say() { printf '%s\n' "$*"; }
warn() { printf '%s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }
# /dev/tty can exist yet fail to open (no controlling terminal)
tty_ok() { (: </dev/tty) 2>/dev/null; }

# Questions go to the terminal, since stdin may be the script itself
ask() {
  if [ "${DOTFILES_YES:-}" = 1 ]; then
    return 0
  fi
  if ! tty_ok; then
    warn "No terminal to ask \"$1\", so answering no (set DOTFILES_YES=1 to answer yes)"
    return 1
  fi
  printf '%s [y/N] ' "$1" >/dev/tty
  read -r reply </dev/tty || return 1
  case $reply in
    y | Y | yes | Yes) return 0 ;;
    *) return 1 ;;
  esac
}

fetch() {
  if have curl; then
    curl -fsSL "$1"
  elif have wget; then
    wget -qO- "$1"
  else
    warn "Neither curl nor wget is installed"
    return 1
  fi
}

# Root for system package managers, if we aren't root already
as_root() {
  if [ "$(id -u)" = 0 ]; then
    "$@"
  elif have sudo; then
    sudo "$@"
  else
    warn "Need root for: $*, but sudo isn't installed"
    return 1
  fi
}

detect_platform() {
  if [ -n "${TERMUX_VERSION:-}" ] || case "${PREFIX:-}" in */com.termux/*) true ;; *) false ;; esac; then
    PLATFORM=termux
  elif [ "$(uname -s)" = Darwin ]; then
    PLATFORM=macos
  else
    PLATFORM=linux
  fi

  # The system's own package manager comes first. On macOS that's Homebrew.
  # Never probe the root filesystem on Termux.
  SYSTEM=
  if [ "$PLATFORM" = termux ]; then
    SYSTEM=pkg
  elif [ "$PLATFORM" = macos ]; then
    find_brew && SYSTEM=brew
  elif have apt-get; then
    SYSTEM=apt
  elif have dnf; then
    SYSTEM=dnf
  elif have apk; then
    SYSTEM=apk
  elif have pacman; then
    SYSTEM=pacman
  fi

  # On Linux, deb-get, Homebrew and then Snap fill in what the system lacks.
  # deb-get first: its packages are .deb files that apt installs as root,
  # resolving their dependencies with the system's, where Homebrew brings its
  # own (its python3 can shadow the system's) and runs in the user's account.
  # Homebrew comes before Snap for its fewer broken builds.
  EXTRA=
  if [ "$PLATFORM" = linux ]; then
    [ "$SYSTEM" = apt ] && have deb-get && EXTRA="deb-get"
    find_brew && EXTRA="${EXTRA:+$EXTRA }brew"
    have snap && EXTRA="${EXTRA:+$EXTRA }snap"
  fi
  # deb-get reads GitHub's API, which allows few requests without a token
  if [ -z "${DEBGET_TOKEN:-}" ] && have gh; then
    DEBGET_TOKEN=$(gh auth token 2>/dev/null) || DEBGET_TOKEN=
    [ -n "$DEBGET_TOKEN" ] && export DEBGET_TOKEN
  fi
}

# Find Homebrew where its installer puts it, and set up its environment
find_brew() {
  for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$brew" ]; then
      eval "$("$brew" shellenv)"
      return 0
    fi
  done
  return 1
}

# The package that provides a tool, for a package manager
pkg_name() {
  case "$1:$2" in
    apt:fd) echo fd-find ;;
    # Debian and Fedora ship lesspipe in the less package
    apt:lesspipe | dnf:lesspipe) echo less ;;
    apt:dust | deb-get:dust) echo du-dust ;;
    apt:mtr) echo mtr-tiny ;;
    brew:7zip) echo sevenzip ;;
    dnf:7zip | pacman:7zip) echo p7zip ;;
    brew:fq) echo wader/tap/fq ;;
    *) echo "$2" ;;
  esac
}

# Whether a package manager can install a package
pkg_available() {
  case $1 in
    brew) brew info --formula "$2" >/dev/null 2>&1 ;;
    deb-get)
      # Packages for this machine's release and architecture, listed once.
      # deb-get lists only installed packages until `deb-get update` has run.
      if [ -z "${DEBGET_APPS:-}" ]; then
        [ "$(deb-get list --raw 2>/dev/null | wc -l)" -gt 10 ] || deb-get update >/dev/null 2>&1
        DEBGET_APPS=" $(deb-get list --raw 2>/dev/null | tr '\n' ' ') "
      fi
      case $DEBGET_APPS in *" $2 "*) true ;; *) false ;; esac
      ;;
    snap) snap info "$2" >/dev/null 2>&1 ;;
    apt | pkg) apt-cache show "$2" >/dev/null 2>&1 ;;
    dnf) dnf info -q "$2" >/dev/null 2>&1 ;;
    apk) apk search -e "$2" 2>/dev/null | grep -q . ;;
    pacman) pacman -Si "$2" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

pkg_install() {
  manager=$1
  shift
  case $manager in
    brew) brew install "$@" ;;
    deb-get)
      # One at a time: deb-get stops at the first package that fails. It runs
      # as us and uses sudo itself, so it keeps DEBGET_TOKEN.
      for deb in "$@"; do
        deb-get install "$deb" || warn "deb-get couldn't install $deb"
      done
      ;;
    snap)
      # One at a time: some snaps need --classic (full access to the home folder)
      for snap in "$@"; do
        case $snap in
          chezmoi | yazi) as_root snap install "$snap" --classic ;;
          *) as_root snap install "$snap" ;;
        esac
      done
      ;;
    pkg) pkg install -y "$@" ;;
    apt) as_root apt-get install -y "$@" ;;
    dnf) as_root dnf install -y "$@" ;;
    apk) as_root apk add "$@" ;;
    pacman) as_root pacman -S --needed --noconfirm "$@" ;;
  esac
}

pkg_refresh() {
  case $SYSTEM in
    apt) as_root apt-get update ;;
    pkg) pkg update -y ;;
    apk) as_root apk update ;;
    *) true ;;
  esac
}

# Whether a tool is already installed, by its command names
installed() {
  case $1 in
    bat) cmds="bat batcat" ;;
    fd) cmds="fd fdfind" ;;
    lesspipe) cmds="lesspipe.sh lesspipe" ;;
    ripgrep) cmds=rg ;;
    git-delta) cmds='delta' ;;
    difftastic) cmds=difft ;;
    smartmontools) cmds=smartctl ;;
    7zip) cmds="7z 7zz" ;;
    *) cmds=$1 ;;
  esac
  for cmd in $cmds; do
    have "$cmd" && return 0
  done
  return 1
}

# Sort the missing tools in "$@" by the first package manager that has them,
# with uv last for Python tools. Sets PLAN_SYSTEM, PLAN_DEBGET, PLAN_BREW,
# PLAN_SNAP, PLAN_UV (package names) and UNSOURCED (tools).
plan_tools() {
  PLAN_SYSTEM=
  PLAN_DEBGET=
  PLAN_BREW=
  PLAN_SNAP=
  PLAN_UV=
  UNSOURCED=
  for tool in "$@"; do
    installed "$tool" && continue
    source=
    for manager in $SYSTEM $EXTRA; do
      pkg=$(pkg_name "$manager" "$tool")
      if pkg_available "$manager" "$pkg"; then
        source=$manager
        break
      fi
    done
    if [ -z "$source" ]; then
      case " $UV_TOOLS " in
        *" $tool "*) source=uv pkg=$tool ;;
      esac
    fi
    case $source in
      "") UNSOURCED="$UNSOURCED $tool" ;;
      uv) PLAN_UV="$PLAN_UV $pkg" ;;
      "$SYSTEM") PLAN_SYSTEM="$PLAN_SYSTEM $pkg" ;;
      deb-get) PLAN_DEBGET="$PLAN_DEBGET $pkg" ;;
      brew) PLAN_BREW="$PLAN_BREW $pkg" ;;
      snap) PLAN_SNAP="$PLAN_SNAP $pkg" ;;
    esac
  done
}

# Whether Homebrew has a tool, asked of its website since brew isn't installed yet
brew_has() {
  pkg=$(pkg_name brew "$1")
  case $pkg in
    */*) return 0 ;; # from a tap, which the website doesn't list
  esac
  if have curl; then
    curl -fsS -o /dev/null "https://formulae.brew.sh/api/formula/$pkg.json" 2>/dev/null
  else
    wget -q -O /dev/null "https://formulae.brew.sh/api/formula/$pkg.json" 2>/dev/null
  fi
}

# Whether deb-get's package list has a tool, asked of its repository since
# deb-get isn't installed yet. The list doesn't say which architectures each
# package supports; deb-get's own list does, once it's installed.
debget_has() {
  if [ -z "${DEBGET_MANIFEST:-}" ]; then
    DEBGET_MANIFEST=" $(fetch https://raw.githubusercontent.com/wimpysworld/deb-get/main/01-main/manifest 2>/dev/null |
      sed -e 1d -e '/^#/d' | tr '\n' ' ') "
  fi
  case $DEBGET_MANIFEST in *" $(pkg_name deb-get "$1") "*) true ;; *) false ;; esac
}

# Offer deb-get on Debian and Ubuntu when it would install tools that apt
# doesn't have, chezmoi above all: a light way to get it, where Homebrew and
# Snap are whole frameworks. Declining is fine: Homebrew and Snap come next.
offer_debget() {
  [ "$SYSTEM" = apt ] || return 1
  have deb-get && return 1
  from_debget=
  for tool in $UNSOURCED; do
    debget_has "$tool" && from_debget="$from_debget $tool"
  done
  [ -n "$from_debget" ] || return 1
  say "deb-get has tools that apt doesn't:$from_debget"
  say "  (it installs their makers' own .deb packages; update them with: deb-get upgrade)"
  ask "Install deb-get (it asks for your password)?" || return 1
  as_root apt-get install -y curl distro-info-data lsb-release wget jq || return 1
  # deb-get installs itself, using sudo where it needs root
  fetch https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | bash -s install deb-get || return 1
  have deb-get || return 1
  # Its package list stays empty until the first update
  deb-get update >/dev/null 2>&1
  EXTRA="deb-get${EXTRA:+ $EXTRA}"
  return 0
}

# Offer Homebrew when it would install tools that nothing here has.
# Declining is fine: those tools are skipped, and chezmoi uses its own installer.
offer_brew() {
  [ "$PLATFORM" = termux ] && return 1
  have brew && return 1
  from_brew=
  for tool in $UNSOURCED; do
    brew_has "$tool" && from_brew="$from_brew $tool"
  done
  [ -n "$from_brew" ] || return 1
  say "Homebrew has tools that ${SYSTEM:-this system} doesn't:$from_brew"
  ask "Install Homebrew with its official installer (it asks for your password)?" || return 1
  if [ "${DOTFILES_YES:-}" = 1 ]; then
    NONINTERACTIVE=1
    export NONINTERACTIVE
  fi
  /bin/bash -c "$(fetch https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
  find_brew || return 1
  if [ "$PLATFORM" = macos ]; then
    SYSTEM=brew
  else
    EXTRA="brew${EXTRA:+ $EXTRA}"
  fi
  return 0
}

# Install the planned packages, asking once per package manager
install_planned() {
  if [ -n "$PLAN_SYSTEM" ]; then
    say "To install with $SYSTEM:$PLAN_SYSTEM"
    # shellcheck disable=SC2086
    ask "Install these?" && pkg_install "$SYSTEM" $PLAN_SYSTEM
  fi
  if [ -n "$PLAN_DEBGET" ]; then
    say "To install with deb-get:$PLAN_DEBGET"
    # shellcheck disable=SC2086
    ask "Install these?" && pkg_install deb-get $PLAN_DEBGET
  fi
  if [ -n "$PLAN_BREW" ]; then
    say "To install with Homebrew:$PLAN_BREW"
    # shellcheck disable=SC2086
    ask "Install these?" && pkg_install brew $PLAN_BREW
  fi
  if [ -n "$PLAN_SNAP" ]; then
    say "To install with Snap:$PLAN_SNAP"
    # shellcheck disable=SC2086
    ask "Install these?" && pkg_install snap $PLAN_SNAP
  fi
  # Last, as uv may have come from one of the managers above
  if [ -n "$PLAN_UV" ]; then
    if have uv; then
      say "To install with uv tool install:$PLAN_UV"
      if ask "Install these?"; then
        for pkg in $PLAN_UV; do
          uv tool install "$pkg"
        done
      fi
    else
      UNSOURCED="$UNSOURCED$PLAN_UV"
    fi
  fi
  return 0
}

# The tool list is split into words on purpose
# shellcheck disable=SC2086
install_tools() {
  tools="$*"
  plan_tools $tools
  # Python tools need uv itself, even in a tier that doesn't list it
  if [ -n "$PLAN_UV" ] && ! installed uv; then
    case " $tools " in
      *" uv "*) ;;
      *)
        tools="$tools uv"
        plan_tools $tools
        ;;
    esac
  fi
  if [ -n "$UNSOURCED" ] && offer_debget; then
    plan_tools $tools
  fi
  if [ -n "$UNSOURCED" ] && offer_brew; then
    plan_tools $tools
  fi
  install_planned
  # chezmoi is the one tool that can't be skipped: use its own installer
  case " $UNSOURCED " in
    *" chezmoi "*)
      installed chezmoi || install_chezmoi_direct
      UNSOURCED=$(echo "$UNSOURCED" | sed 's/ chezmoi//')
      ;;
  esac
  if [ -n "$UNSOURCED" ]; then
    say "Skipped, as nothing here can install them:$UNSOURCED"
    say "  (see README.md for other ways to install them)"
  fi
}

install_chezmoi_direct() {
  if ask "Install chezmoi into ~/.local/bin with its official installer (get.chezmoi.io)?"; then
    mkdir -p "$HOME/.local/bin"
    sh -c "$(fetch https://get.chezmoi.io)" -- -b "$HOME/.local/bin" || return 1
    PATH="$HOME/.local/bin:$PATH"
    export PATH
  fi
}

# A machine with a local graphical session, so worth giving fonts
is_desktop() {
  case $PLATFORM in
    macos) return 0 ;;
    linux) ;;
    *) return 1 ;;
  esac
  have fc-cache || return 1
  [ -n "${XDG_CURRENT_DESKTOP:-}${WAYLAND_DISPLAY:-}${DISPLAY:-}" ] && return 0
  # Run over SSH on a desktop machine: no display variables, but a graphical boot target
  have systemctl && [ "$(systemctl get-default 2>/dev/null)" = graphical.target ]
}

# Termux takes one terminal font file, so give it MesloLGS (if it has none yet)
install_termux_font() {
  font="$HOME/.termux/font.ttf"
  [ -e "$font" ] && return 0
  ask "Install MesloLGS Nerd Font as Termux's terminal font?" || return 0
  mkdir -p "$HOME/.termux"
  tmp=$(mktemp -d)
  if fetch "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz" |
    tar -xJf - -C "$tmp" MesloLGSNerdFont-Regular.ttf; then
    mv "$tmp/MesloLGSNerdFont-Regular.ttf" "$font"
    have termux-reload-settings && termux-reload-settings
  else
    warn "Couldn't install the MesloLGS Nerd Font (is xz-utils installed?)"
  fi
  rm -rf "$tmp"
}

install_fonts() {
  if [ "$PLATFORM" = termux ]; then
    install_termux_font
    return 0
  fi
  is_desktop || return 0
  missing=
  casks=
  for font in $NERD_FONTS; do
    archive=${font%%:*}
    rest=${font#*:}
    family=$(echo "${rest%%:*}" | tr _ ' ')
    cask=${rest#*:}
    if have brew; then
      brew list --cask "$cask" >/dev/null 2>&1 && continue
    elif fc-list 2>/dev/null | grep -q "$family"; then
      continue
    fi
    missing="$missing $archive"
    casks="$casks $cask"
  done
  [ -n "$missing" ] || return 0
  ask "Install Nerd Fonts for terminals and editors:$missing?" || return 0
  if have brew; then
    # On Linux, Homebrew installs font casks into ~/.local/share/fonts
    # shellcheck disable=SC2086
    brew install --cask $casks
  else
    dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts"
    mkdir -p "$dir"
    for name in $missing; do
      fetch "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$name.tar.xz" |
        tar -xJf - -C "$dir" || warn "Couldn't install the $name Nerd Font"
    done
  fi
  have fc-cache && fc-cache -f >/dev/null 2>&1
  return 0
}

choose_tier() {
  TIER=${1:-}
  if [ -z "$TIER" ]; then
    say ""
    say "Which tools? (README.md lists each tier)"
    say "  1. minimal      git, curl and chezmoi: just the dotfiles"
    say "  2. essential    a comfortable shell for servers: zsh, tmux, et, ripgrep, fzf, …"
    say "  3. recommended  everything for a personal machine"
    say "  4. toolbox      recommended, plus network and disk tools (rclone, nmap, smartctl, …)"
    if [ "${DOTFILES_YES:-}" = 1 ] || ! tty_ok; then
      choice=2
    else
      printf 'Tier [2]: ' >/dev/tty
      read -r choice </dev/tty || choice=2
    fi
    case ${choice:-2} in
      1 | minimal) TIER=minimal ;;
      3 | recommended) TIER=recommended ;;
      4 | toolbox) TIER=toolbox ;;
      *) TIER=essential ;;
    esac
  fi
  case $TIER in
    minimal) TOOLS="$TIER_MINIMAL" ;;
    essential) TOOLS="$TIER_MINIMAL $TIER_ESSENTIAL" ;;
    recommended) TOOLS="$TIER_MINIMAL $TIER_ESSENTIAL $TIER_RECOMMENDED" ;;
    toolbox) TOOLS="$TIER_MINIMAL $TIER_ESSENTIAL $TIER_RECOMMENDED $TIER_TOOLBOX" ;;
    *)
      warn "Unknown tier: $TIER (use minimal, essential, recommended or toolbox)"
      exit 2
      ;;
  esac
}

main() {
  detect_platform
  say "Platform: $PLATFORM, package managers: ${SYSTEM:-none}${EXTRA:+ then $EXTRA}"
  choose_tier "${1:-}"

  case $SYSTEM in
    apt | pkg | apk)
      if ask "Refresh the $SYSTEM package index first?"; then
        pkg_refresh
      fi
      ;;
  esac
  # shellcheck disable=SC2086
  install_tools $TOOLS

  install_fonts

  if ! have chezmoi; then
    warn "chezmoi isn't installed, so the dotfiles can't be set up. See https://www.chezmoi.io/install/"
    exit 1
  fi

  if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    say "The dotfiles are already set up in ~/.local/share/chezmoi."
    if ask "Pull the latest and apply them (chezmoi update)?"; then
      chezmoi update
    fi
  else
    chezmoi init "$REPO" || exit 1
    if ask "Show what applying the dotfiles would change in your home folder?"; then
      chezmoi diff
    fi
    if ask "Apply the dotfiles now?"; then
      chezmoi apply
    else
      say "Apply later with: chezmoi apply"
    fi
  fi

  # zsh as the login shell, where the system lets us change it
  # (where chsh isn't allowed, ~/.bashrc.local can `exec zsh -l` instead)
  if have zsh; then
    case ${SHELL:-} in
      */zsh) ;;
      *)
        if have chsh && ask "Make zsh your login shell (chsh)?"; then
          chsh -s "$(command -v zsh)"
        fi
        ;;
    esac
  fi
  say "Done. Start a new shell to pick up the changes."
}

main "$@"
