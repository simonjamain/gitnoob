echo "
#START gitnoob aliases

alias gc='gitnoob -c'
alias gf='gitnoob -f'
alias gp='gitnoob -p'
alias gu='gitnoob -u'
alias gh='gitnoob -h'
alias gr='gitnoob -r'
alias gv='gitnoob -v'
alias fix='git add -A;git commit --amend --no-edit'

#END gitnoob aliases
" >> ~/.bash_aliases && source ~/.bash_aliases