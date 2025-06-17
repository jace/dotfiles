#!/data/data/com.termux/files/usr/bin/bash
if type fastfetch &> /dev/null; then
        fastfetch
elif type neofetch &> /dev/null; then
        neofetch
fi
if [ -e /etc/os-release ]; then
        OSNAME=$(command cat /etc/os-release | command sed -ne 's/^ID=//p')
else
        OSNAME=termux
fi
if type figlet &> /dev/null; then
        if [ -x .local/bin/lolcat ]; then
                echo ${OSNAME^} | figlet | ~/.local/bin/lolcat
        else
                echo ${OSNAME^} | figlet
        fi
else
        echo ${OSNAME^}
fi
