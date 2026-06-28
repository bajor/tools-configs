################################################################## git 
alias main='git checkout main && git status'

alias iter='git add . && git status && git diff --cached && git commit -m "update" && git push'

alias amend='git add . && git status && git diff --cached && git commit --amend --no-edit && git push --force


################################################################## dev
alias current="cd /Users/m/repos/current"

alias vps="mosh <user>@<ip>  -- tmux new-session -A -s main"


################################################################## diagrams
mermaid() { mmdc -i "$1" -o /tmp/mermaid-out.svg && open /tmp/mermaid-out.svg; }


################################################################## ai
alias claudeskip="claude --dangerously-skip-permissions"

alias codexskip="codex --dangerously-bypass-approvals-and-sandbox"
