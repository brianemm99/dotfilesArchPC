#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"

# kubectl completion

alias k='kubectl'

source /etc/bash_completion # not needed on macos

source <(kubectl completion bash)

complete -o default -F __start_kubectl k


