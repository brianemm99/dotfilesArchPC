#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# nvim as default EDITOR
export EDITOR="nvim"
export VISUAL="nvim"

eval "$(starship init bash)"

# kubectl completion

alias k='kubectl'

[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

source <(kubectl completion bash)

complete -o default -F __start_kubectl k

# k3s kubeconfig
export KUBECONFIG=~/.kube/k3s.yaml

# devsy dev containers
alias dws="devsy workspace"
source <(devsy completion bash)
