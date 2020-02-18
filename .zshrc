# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# if you do a 'rm *', Zsh will give you a sanity check!
setopt RM_STAR_WAIT

# allows you to type Bash style comments on your command line
# good 'ol Bash
setopt interactivecomments

# disable autocorrect suggestions
unsetopt correct_all

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ -f /usr/share/fzf/key-bindings.zsh ]; then
	source /usr/share/fzf/key-bindings.zsh
fi
if [ -f /usr/share/fzf/completion.zsh ]; then
	source /usr/share/fzf/completion.zsh
fi

if [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
  source ~/notifyosd.zsh
fi

if [ -f ~/.zshlocal ]; then
	source ~/.zshlocal
fi

source ~/.aliases

#Go
go() {
  export GOPATH="$HOME/dev/go"
  export PATH=$PATH:$(go env GOPATH)/bin # go
  go "$@"
}

#Android
# export ANDROID_HOME=${HOME}/Library/Android/sdk
# export PATH=${PATH}:${ANDROID_HOME}/tools
# export PATH=${PATH}:${ANDROID_HOME}/platform-tools

#ruby
if [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH" # ruby
fi

PATH="$HOME/.yarn/bin:$PATH:$HOME/.config/yarn/global/node_modules/.bin/" #yarn

PATH="$PATH:$HOME/.local/bin"

export PATH
##################################################################

export VISUAL=nvim
export EDITOR="$VISUAL"
export TERMINAL=alacritty

# prevent security pin in flask
export WERKZEUG_DEBUG_PIN=off

# react native expo
export REACT_NATIVE_PACKAGER_HOSTNAME="192.168.0.61"

#fzf ripgrep
export FZF_DEFAULT_COMMAND='rg --files --hidden --no-messages --glob "!.git/*"'
export TERMINAL=alacritty

# export BROWSER=google-chrome-stable

#
export REVIEW_BASE=master

#jira autocomplete
eval "$(jira --completion-script-zsh)"

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
