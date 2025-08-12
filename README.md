## Dotfiles managed with Chezmoi

Getting started:

1. [Install Chezmoi](https://www.chezmoi.io/install) and [GitHub CLI](https://github.com/cli/cli#installation)
2. Authenticate gh: `gh auth login`, then copy the token from `gh auth token`
3. Apply Chezmoi config with `chezmoi init https://github.com/$GITHUB_USERNAME/dotfiles.git`

### Dependencies

This config depends on [Nerd Fonts](https://www.nerdfonts.com/) – I like Fira Code and [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) – and these manually installed CLI tools (\* for required):

- [zsh](https://www.zsh.org/) (change shell with `chsh`)
- [7zip](https://www.7-zip.org/) - file archiver
- [bat](https://github.com/sharkdp/bat) - cat with wings
- [broot](https://github.com/Canop/broot) - cd+ls+find+tree (also see yazi)
- [chafa](https://github.com/hpjansson/chafa) - terminal image viewer
- [difftastic](https://github.com/Wilfred/difftastic) - better diff
- [direnv](https://direnv.net/)\* - manage environment per folder
- [dust](https://github.com/bootandy/dust) - better disk usage visualisation
- [et](https://eternalterminal.dev/) - ssh without disconnects from flaky internet
- [eza](https://github.com/eza-community/eza)\* - better ls (also see lsd)
- [fd](https://github.com/sharkdp/fd) - better find
- [ffmpeg](https://www.ffmpeg.org/) - multimedia multitool
- [fq](https://github.com/wader/fq) - binary file processor
- [fzf](https://github.com/junegunn/fzf)\* - nicer tab autocompletion
- [gh](https://github.com/cli/cli) - GitHub CLI (for auth)
- [git-delta](https://github.com/dandavison/delta) - nicer git deltas
- [glow](https://github.com/charmbracelet/glow) - render markdown in the terminal
- [grc](https://github.com/garabik/grc) - generic colouriser
- [gron](https://github.com/tomnomnom/gron) - greppable JSON
- [hexyl](https://github.com/sharkdp/hexyl) - hex viewer
- [jc](https://github.com/kellyjonbrazil/jc) - convert CLI tool output into JSON
- [jless](https://jless.io/) - JSON viewer with folding
- [jq](https://jqlang.org/) - JSON processor
- [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI
- [lsd](https://github.com/lsd-rs/lsd) - better ls (also see eza)
- [mcfly](https://github.com/cantino/mcfly) - better ^R command history
- [numbat](https://github.com/sharkdp/numbat) - better bc (expression calculator)
- [pandoc](https://pandoc.org/) - convert between markup formats for terminal viewers
- [procs](https://github.com/dalance/procs) - better ps
- [resvg](https://github.com/linebender/resvg) - terminal SVG viewer
- [ripgrep](https://github.com/BurntSushi/ripgrep) - better grep
- [timg](https://github.com/hzeller/timg/) - terminal image viewer
- [uv](https://docs.astral.sh/uv/) - Python tool and dependency installer
- [yazi](https://yazi-rs.github.io/docs/installation) - three-pane file manager + cd (also see broot)
- [zoxide](https://github.com/ajeetdsouza/zoxide)\* - better cd

Most of these can be installed with `brew|apt|pkg install name…` but some distros need additional package repositories.

### macOS

```shell
brew install 7zip bat broot chafa difftastic direnv dust et eza fd ffmpeg wader/tap/fq fzf gh git-delta glow grc gron hexyl jc jless jq lsd pandoc procs resvg ripgrep timg uv yazi zoxide
```

Sync iTerm2 config:

1. Go to Settings… -> General -> Settings
2. Enable "External settings"
3. Set folder to `~/.config/iterm2`
4. Set "Save changes" to "Automatically"

### Ubuntu

```shell
# Add the apt.cli.rs repository for Rust-based tools
curl -fsSL https://apt.cli.rs/pubkey.asc | sudo tee -a /usr/share/keyrings/rust-tools.asc
curl -fsSL https://apt.cli.rs/rust-tools.list | sudo tee /etc/apt/sources.list.d/rust-tools.list
# Add the GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
# Add the Eternal Terminal repository
sudo add-apt-repository ppa:jgmath2000/et
# add-apt-repository will invoke `apt update`
# Install deb-packaged tools
sudo apt install 7zip bat broot chafa direnv et eza fd-musl ffmpeg fq fzf git-delta glow gron hexyl jc jq lsd pandoc procs resvg ripgrep timg zoxide
# Install snap-packaged tools
sudo snap install difftastic dust gh
sudo snap install yazi --classic
```

Missing: grc, jless, mcfly, lazygit (available via Linux Homebrew)

### Raspberry Pi OS

Refer to Ubuntu instructions for now.

### Termux

```shell
pkg install 7zip bat broot chafa difftastic direnv dust et eza fd ffmpeg fq fzf gh git-delta glow gron hexyl jc jless jq lsd pandoc procs resvg ripgrep timg uv yazi zoxide
```

Missing: grc, numbat (build is currently failing on a dependency)
