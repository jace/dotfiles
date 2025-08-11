## Dotfiles managed with Chezmoi

Getting started:

1. [Install Chezmoi](https://www.chezmoi.io/install) and [GitHub CLI](https://github.com/cli/cli#installation)
2. Authenticate gh: `gh auth login`, then copy the token from `gh auth token`
3. Apply Chezmoi config with `chezmoi init https://github.com/$GITHUB_USERNAME/dotfiles.git`

This config depends on [Nerd Fonts](https://www.nerdfonts.com/) and several manually installed CLI tools:

- [zsh](https://www.zsh.org/) (change shell with `chsh`)
- [7zip](https://www.7-zip.org/)
- [bat](https://github.com/sharkdp/bat)
- [broot](https://github.com/Canop/broot)
- [difftastic](https://github.com/Wilfred/difftastic)
- [dust](https://github.com/bootandy/dust)
- [et](https://eternalterminal.dev/)
- [eza](https://github.com/eza-community/eza)
- [fd](https://github.com/sharkdp/fd)
- [ffmpeg](https://www.ffmpeg.org/)
- [fzf](https://github.com/junegunn/fzf)
- [git-delta](https://github.com/dandavison/delta)
- [glow](https://github.com/charmbracelet/glow)
- [gron](https://github.com/tomnomnom/gron)
- [hexyl](https://github.com/sharkdp/hexyl)
- [hexyl](https://github.com/sharkdp/hexyl)
- [jc](https://github.com/kellyjonbrazil/jc)
- [jless](https://jless.io/)
- [jq](https://jqlang.org/)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lsd](https://github.com/lsd-rs/lsd)
- [mcfly](https://github.com/cantino/mcfly)
- [procs](https://github.com/dalance/procs)
- [resvg](https://github.com/linebender/resvg)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [yazi](https://yazi-rs.github.io/docs/installation)
- [zoxide](https://github.com/ajeetdsouza/zoxide)

Most of these can be installed with `brew|apt|pkg install name…`. For Debian/Ubuntu: use the [`apt.cli.rs` apt repo](https://github.com/emmatyping/apt.cli.rs).

Sync iTerm2 config (macOS):

1. Go to Settings… -> General -> Settings
2. Enable "External settings"
3. Set folder to `~/.config/iterm2`
4. Set "Save changes" to "Automatically"
