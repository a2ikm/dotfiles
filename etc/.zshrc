export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export EDITOR=vim

if type tspin >/dev/null 2>&1; then
  export PAGER=tspin
else
  export PAGER=less
fi

export AWS_REGION=ap-northeast-1
export BUNDLE_JOBS=4
export DISABLE_SPRING=1
export GHQ_ROOT=$HOME/src
export JLESSCHARSET=utf-8
export LESS="-R --tabs=2 --line-numbers -X"

# === HISTORY
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # ignore duplication command history list
setopt hist_ignore_space
setopt share_history        # share command history data

setopt auto_param_slash
setopt autopushd
setopt NO_beep
setopt magic_equal_subst
setopt NO_flow_control
setopt noflowcontrol
setopt auto_menu            # show completion menu on succesive tab press

autoload -U compinit
compinit -u

unset zle_bracketed_paste # https://github.com/peco/peco/issues/417#issuecomment-289080269
# bindkey "^?" vi-backward-kill-word


# === prompt

_set_env_git_current_branch() {
  GIT_CURRENT_BRANCH=$( git branch &>/dev/null | grep '^\*' | cut -b 3- )
}

_update_prompt () {
  if [ "`git ls-files 2>/dev/null`" ]; then
    PROMPT="%F{blue}%n@%m%f %B%F{064}%2~%f%b %f%F{038}${GIT_CURRENT_BRANCH}%f%F{064}%f%b %F{yellow}$%f "
  else
    PROMPT="%F{blue}%n@%m%f %B%F{064}%2~%f%b %F{yellow}$%f "
  fi
}

precmd()
{
  _set_env_git_current_branch
  _update_prompt
}

chpwd()
{
  _set_env_git_current_branch
  _update_prompt
}


# === alias

alias be="bundle exec"
alias c="dirs -c; clear"
alias curl="curl --globoff --silent"
alias dc="docker-compose"
alias g="git"
alias gg="git grep -In"
alias ll="ls -la"
alias ls="ls -v"
alias p=popd
alias r="ghq get"
alias rg="rg --no-heading"
alias screen="screen -U"
alias t=tig
alias v=vim
alias cgrep="grep --color=always"
alias k=kubectl

case "$(uname)" in
  Darwin)
    export PATH=/Applications/CotEditor.app/Contents/SharedSupport/bin/:$PATH
    export PATH=/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:$PATH

    export MAKEFLAGS="--jobs $(sysctl -n hw.ncpu)"

    if [ -x /usr/libexec/java_home ]; then
      export JAVA_HOME=$(/usr/libexec/java_home)
      export PATH=$JAVA_HOME/bin:$PATH
    fi

    if [ -d /opt/homebrew ]; then
      brew_prefix=/opt/homebrew
      export PATH=$brew_prefix/bin:$PATH
      export MANPATH=$brew_prefix/share/man:$MANPATH
      export CFLAGS="-I$brew_prefix/include $CFLAGS"
      export LDFLAGS="-L$brew_prefix/lib $LDFLAGS"
      export RUBY_CONFIGURE_OPTS="--with-openssl-dir=${brew_prefix}/opt/openssl@3"

      alias diff=colordiff
      alias grep=ggrep
      alias zcat=gzcat

      # for Ruby 3.2+
      # https://koic.hatenablog.com/entry/ruby32-requires-bison3
      if [ -d "$brew_prefix/opt/bison" ]; then
        export PATH="$brew_prefix/opt/bison/bin:$PATH"
      fi

      if [ -d "$brew_prefix/opt/go" ]; then
        export PATH="$brew_prefix/opt/go/bin:$PATH"
      fi

      if [ -d "$brew_prefix/opt/libpq" ]; then
        export PATH=$brew_prefix/opt/libpq/bin:$PATH
      fi
    fi
    ;;
  Linux)
    ;;
  *)
    ;;
esac

if [ -d "$HOME/.local/bin" ]; then
  export PATH=$HOME/.local/bin:$PATH
fi

# === Rust

if [ -d "$HOME/.cargo" ]; then
  source $HOME/.cargo/env
fi


# === Go

if type go >/dev/null 2>&1; then
  export GOROOT=$(env GOROOT="" go env GOROOT)
  export GOPATH=$HOME
fi

# === anyenv

if [ -d $HOME/.anyenv ]; then
  export PATH="$HOME/.anyenv/bin:$PATH"
  eval "$(anyenv init -)"
fi


# === rbenv

if [ -d $HOME/.rbenv ] && [ $HOME != /home/quipper ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - zsh)"
  export RUBY_CONFIGURE_OPTS="--enable-shared $RUBY_CONFIGURE_OPTS"
fi


# === nvm

if [ -d $HOME/.nvm ] && [ -d /opt/homebrew/opt/nvm/ ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

# === erlenv

if [ -d $HOME/.anyenv/envs/erlenv ]; then
  export PATH="$HOME/.anyenv/envs/erlenv/bin:$PATH"
  eval "$(erlenv init -)"
fi


# === exenv

if [ -d $HOME/.anyenv/envs/exenv ]; then
  export PATH="$HOME/.anyenv/envs/exenv/bin:$PATH"
  eval "$(exenv init -)"
fi


# === Kubernetes

if type kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi


# === Haskell

test -r $HOME/.opam/opam-init/init.zsh && . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true


# === 便利

bindkey -d
bindkey -e

tcsh-backward-delete-word() {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N tcsh-backward-delete-word
bindkey "^W" tcsh-backward-delete-word

# 自動で~/.zshrcをコンパイル
# http://blog.n-z.jp/blog/2013-12-10-auto-zshrc-recompile.html
if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
   zcompile ~/.zshrc
fi

# 最後にサスペンドしたジョブに Ctrl-Z で復帰する
# http://qiita.com/uasi/items/93846fb0a671c0f1cc05
function run-fglast {
    zle push-input
    BUFFER="fg %"
    zle accept-line
}

zle -N run-fglast
bindkey "^z" run-fglast

# C-qでコマンドラインスタック
# http://scrawlpad.blogspot.jp/2008/11/zshvi.html
# http://d.hatena.ne.jp/kei_q/20110308/1299594629
show_buffer_stack() {
  POSTDISPLAY="
stack: $LBUFFER"
  zle push-line-or-edit
}
zle -N show_buffer_stack
bindkey '^Q' show_buffer_stack

function peco-select-file() {
  local selected=$(find . -not -path "./.git*" -a -not -path "./.yarn*" -a -not -path "*/node_modules/*"-a -not -name "*.swp" -a -not -name ".DS_Store"| peco)
  BUFFER="$LBUFFER$selected"
  CURSOR=$#BUFFER
}
zle -N peco-select-file
bindkey '^f' peco-select-file

function peco-select-git-branch() {
  local selected=$(git branch | sed 's/^. //' | peco)
  BUFFER="$LBUFFER$selected"
  CURSOR=$#BUFFER
}
zle -N peco-select-git-branch
bindkey '^b' peco-select-git-branch

# http://blog.kenjiskywalker.org/blog/2014/06/12/peco/
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        uniq | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    #zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# http://r7kamura.github.io/2014/06/21/ghq.html
function pecot() {
  peco | while read LINE; do $@ $LINE; done
}

function peco-select-ghq-list() {
  ghq list -p
}

function peco-select-ghq() {
  peco-select-ghq-list | pecot cd
  zle reset-prompt
}

zle -N peco-select-ghq
bindkey '^]' peco-select-ghq

if [ -e "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ]; then
  source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
  source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
fi

if [ -d ~/.zshrc.d ]; then
  for rc in $(ls -1 ~/.zshrc.d/*.zsh); do
    source $rc
  done
fi

export PATH=$HOME/bin:$HOME/local/bin:$PATH
