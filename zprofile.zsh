#!/usr/bin/env zsh

[[ -d "$XDG_RUNTIME_DIR" ]] && SKOGAI_RUNTIME_DIR="${XDG_RUNTIME_DIR}/skogai"

if [[ ! -d "${SKOGAI_RUNTIME_DIR}" ]]; then
    git -C "${XDG_RUNTIME_DIR}" clone "https://github.com/skogai/runtime.git" "skogai"
else
    git -C "${SKOGAI_RUNTIME_DIR}" pull
fi

[[ ! -f "${ZDOTDIR}/.zprofile" ]] && cat "${SKOGAI_RUNTIME_DIR}/zprofile.zsh" > "${ZDOTDIR}/.zprofile"
[[ -d $XDG_CACHE_DIR  ]] && SKOGAI_CACHE_DIR="${XDG_CACHE_DIR}/skogai"
mkdir -p "$SKOGAI_CACHE_DIR"

source "${SKOGAI_RUNTIME_DIR}/user-dirs.dirs"

rm -f "${SKOGAI_CACHE_DIR}/test.env"
export >"${SKOGAI_CACHE_DIR}/test.env"

rm -f "$HOME/.zprofile"

echo '[[ -f "$XDG_RUNTIME_DIR/skogai/zprofile.zsh" ]] && source "$XDG_RUNTIME_DIR/skogai/zprofile.zsh"' >"$HOME/.zprofile"

cat "$SKOGAI_RUNTIME_DIR/zprofile.zsh" > "$ZDOTDIR/.zprofile"
export SKOGAI_CACHE_DIR=$SKOGAI_CACHE_DIR
export SKOGAI_RUNTIME_DIR=$SKOGAI_RUNTIME_DIR


# source "${SKOGAI_RUNTIME_DIR}/config/zsh/zprofile"
# eval "${SKOGAI_RUNTIME_DIR}/

# SKOGAI_HOME_DIR="${SKOGAI_RUNTIME_DIR}/init.zsh"
# eval "$($SKOGAI_INIT)"
#
# if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
#   export BROWSER='open'
# else 
#   export BROWSER='google-chrome-stable'
# fi
#
# #
# # Editors
# #
#
# if [[ -z "$EDITOR" ]]; then
#   export EDITOR='nvim'
# fi
# if [[ -z "$VISUAL" ]]; then
#   export VISUAL='nvim'
# fi
# if [[ -z "$PAGER" ]]; then
#   export PAGER='less'
# fi
# if [[ -z "$SKOGAI" ]]; then
#   export SKOGAI="${XDG_RUNTIME_DIR}/skogai/"
#   export SKOGAI_RUNTIME_DIR="${XDG_RUNTIME_DIR}/skogai/"
#   export SKOGAI_CACHE_DIR="${XDG_CACHE_DIR}/skogai/"
# fi
#
# #
# # Language
# #
#
# if [[ -z "$LANG" ]]; then
#   export LANG='en_US.UTF-8'
# fi
#
# #
# # Paths
# #
#
# # Ensure path arrays do not contain duplicates.
# typeset -gU cdpath fpath mailpath path
#
# # Set the list of directories that cd searches.
# # cdpath=(
# #   $cdpath
# # )
#
# # Set the list of directories that Zsh searches for programs.
# path=(
#   $HOME/{,s}bin(N)
#   /opt/{homebrew,local}/{,s}bin(N)
#   /usr/local/{,s}bin(N)
#   $path
# )
#
# #
# # Less
# #
#
# # Set the default Less options.
# # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# # Remove -X to enable it.
# if [[ -z "$LESS" ]]; then
#   export LESS='-g -i -M -R -S -w -X -z-4'
# fi
#
# # Set the Less input preprocessor.
# # Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
# if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
#   export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
# fi
