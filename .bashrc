# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Added alaises

alias la='ls -al'
alias laingo='cd /var/www/public_html'
#alias lock='update_vlock_message && clear && /home/stlain/.vlockrc && vlock'
alias lock='clear && lockscreen && vlock && clear && motd'
alias wip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias motd="/etc/motd.tcl"
alias motdw="watch -n 0.1 --color '/etc/motd.tcl'"
alias lockscreen="/home/stlain/lock.tcl"
alias errorlog="sudo nano -w /var/log/httpd/error_log"

alias wwwgo="cd /var/www/public_html/"
alias irpggo="cd /var/www/public_html/irpg/"
alias idlego="cd /srv/idlerpg/"
alias irpg_git="sudo -u irpg_git git pull"

alias vi="vim"
alias irssi="screen irssi"

# For vlock message variable
update_vlock_message() {
    date=`date +%H:%M:%S %p`
    msg="`lockscreen` `echo -e '\n\nComputer locked at $date'`"
    echo -e "date=$date\nVLOCK_MESSAGE=\"$msg\"" > /home/stlain/.vlockrc   
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Allow passphrase entry in term for GPG
export GPG_TTY=$(tty)
if [[ -n "$SSH_CONNECTION" ]] ;then
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi
