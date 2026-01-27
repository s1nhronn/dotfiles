set -U fish_greeting ''
set -gx PATH $HOME/.local/bin $PATH

if status is-interactive
    if type -q atuin
        atuin init fish | source
    end
end

alias cat="bat"
alias rm="rmt"
alias ls="lsd"
alias df="duf"
