# OBLinux default .zshrc for newly created users (installed systems only —
# the live session's liveuser has its own separate config, see
# airootfs/home/liveuser/.zshrc).
#
# `useradd -m` populates a new user's home directory from /etc/skel, not
# from liveuser's home — without a file here, a new user's login shell
# being zsh (users.conf: user.shell) would trigger zsh's interactive
# first-run configuration wizard instead of a working shell.

autoload -Uz compinit
compinit

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history hist_ignore_dups hist_reduce_blanks
setopt auto_cd interactive_comments

bindkey -e
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# THEMING.md item 7: Debian-aligned OBLinux prompt. $STARSHIP_CONFIG
# points at the one shared, system-wide config
# (airootfs/etc/xdg/starship.toml) rather than a per-user copy — see
# that file's own comment for why (Starship has no XDG system-config
# fallback of its own, unlike fastfetch).
export STARSHIP_CONFIG=/etc/xdg/starship.toml
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# THEMING.md item 6: branded system-info banner on new interactive shells.
# Guarded so non-interactive invocations (scripts, command substitution)
# don't get it. Config/logo: /etc/xdg/fastfetch/ (system-wide, see that
# directory's config.jsonc for why no per-user copy is needed).
if [[ -o interactive && -t 1 && ${SHLVL:-1} -eq 1 \
    && ${OBLINUX_FASTFETCH:-1} != 0 ]] \
    && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# Syntax highlighting must be sourced after prompt and widget setup.
if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
