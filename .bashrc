# Exit if not running interactively
[[ $- != *i* ]] && return

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(< /etc/debian_chroot)
fi

# Git branch helper
git_branch() {
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ -n "$branch" ] && echo "[$branch]"
}

# ROOT prompt (red root)
PS1='\[\033[01;31m\]\u@\h \[\033[01;34m\]\w \[\033[01;33m\]$(git_branch)\[\033[00m\]# '

case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

# Colors
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Storage
alias storage="df -B G | grep -v '/var/lib/docker'"
alias duu="du -kB M -d 0"

# rcon
alias mcconsole="mcrcon -H 192.168.4.229 -P 20026 -p '***'"
alias mcconsole2="mcrcon -H 192.168.4.229 -P 20034 -p '***'"

# SSH
alias ss="ssh r1f2l@192.168.4.229 -p 25570"
alias sss="ssh r1f2l@47.197.233.180 -p 25570"

# neofetch has been deprecated
alias neofetch="fastfetch"

# Support clearing in kitty
alias clear="reset"

# Reload grub
alias update-grub="grub2-mkconfig -o /boot/grub2/grub.cfg"

# Open downloads
alias dl="cd ~/Downloads/"

# Open nautilus
alias n="nemo . &"

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

if ! shopt -oq posix; then
    [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
    [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

# CUDA
export PATH=/usr/local/cuda-12.5/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
