set -U fish_greeting ''

if status is-interactive
    if type -q atuin
        atuin init fish | source
    end
end

alias cat="bat"
alias rm="rmt"
alias ls="lsd"
