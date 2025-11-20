#!/usr/bin/env bash
# Common Aliases

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# List operations
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G'
alias lsa='ls -lah'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Quick edits
alias v='vim'
alias vi='vim'
alias e='$EDITOR'
alias n='nano'

# Git shortcuts (in addition to functions)
alias g='git'
alias gst='git status'
alias gd='git diff'
alias ga='git add'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gb='git branch'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Kubernetes shortcuts
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'

# Python
alias py='python3'
alias python='python3'
alias pip='pip3'

# Node
alias ni='npm install'
alias nid='npm install --save-dev'
alias nu='npm uninstall'
alias ns='npm start'
alias nt='npm test'
alias nr='npm run'
alias nrb='npm run build'

# System
alias c='clear'
alias h='history'
alias j='jobs'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%Y-%m-%d"'
alias week='date +%V'

# Disk usage
alias du='du -h'
alias df='df -h'

# Make and build
alias m='make'
alias mc='make clean'
alias mi='make install'

# Grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Network
alias ping='ping -c 5'
alias fastping='ping -c 100 -i 0.2'
alias ports='netstat -tulanp'

# Get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

# Get top process eating cpu
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

# Clipboard (macOS/Linux)
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# Quick config edits
alias bashrc='$EDITOR ~/.bashrc'
alias zshrc='$EDITOR ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias sshconfig='$EDITOR ~/.ssh/config'

# Reload shells
alias rebash='source ~/.bashrc'
alias rezsh='source ~/.zshrc'

# Package managers
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'

# Homebrew (macOS)
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewls='brew list'
alias brewin='brew install'
alias brewun='brew uninstall'

# System monitoring
alias cpu='top -o cpu'
alias mem='top -o mem'

# Quick servers
alias serve='python3 -m http.server'
alias pyserver='python3 -m http.server'

# Date and time
alias timestamp='date "+%Y%m%d%H%M%S"'
alias datestamp='date "+%Y%m%d"'

# Sudo
alias sudo='sudo '
alias s='sudo'
alias please='sudo'

# Quick navigation
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias doc='cd ~/Documents'
alias dev='cd ~/Development'
alias proj='cd ~/Projects'

# Misc
alias x='exit'
alias q='exit'
alias :q='exit'
alias clr='clear'
alias cls='clear'

# Weather
alias weather='curl wttr.in'

# Chmod shortcuts
alias 000='chmod 000'
alias 644='chmod 644'
alias 755='chmod 755'
alias 777='chmod 777'
alias mx='chmod +x'

# Tar operations
alias tarc='tar -czvf'
alias tarx='tar -xzvf'
alias tart='tar -tzvf'

# Show open ports
alias openports='netstat -nape --inet'

# Flush DNS
alias flushdns='sudo systemd-resolve --flush-caches'

# Get local IP
alias localip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

# Get public IP
alias publicip='curl ifconfig.me'

# Show all listening ports
alias listening='lsof -i -P -n | grep LISTEN'

# SSH without host key checking (use carefully)
alias ssh-insecure='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# JSON pretty print
alias jsonpp='python3 -m json.tool'

# URL encode/decode
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'

# Base64
alias b64e='base64'
alias b64d='base64 -d'

# Quick find
alias f='find . -name'

# Process management
alias ka='killall'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# Show listening ports
alias lports='sudo lsof -i -P -n | grep LISTEN'

# Start/stop services (systemd)
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'
alias sstatus='sudo systemctl status'
alias senable='sudo systemctl enable'
alias sdisable='sudo systemctl disable'

# Docker compose shortcuts
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcrestart='docker-compose restart'
alias dclogs='docker-compose logs -f'
alias dcps='docker-compose ps'
alias dcbuild='docker-compose build'

# Maven shortcuts
alias mci='mvn clean install'
alias mcp='mvn clean package'
alias mct='mvn clean test'
alias mvnci='mvn clean install -DskipTests'

# Gradle shortcuts
alias gcb='./gradlew clean build'
alias gct='./gradlew clean test'
alias grw='./gradlew'

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'

# Ansible
alias ap='ansible-playbook'
alias av='ansible-vault'
alias ai='ansible-inventory'

# Show file permissions in octal
alias perms='stat -c "%a %n"'

# Count files in directory
alias count='find . -type f | wc -l'

# Create parent directories on demand
alias mkdir='mkdir -pv'

# Show directory size
alias dirsize='du -sh'

# Sort by size
alias sortsize='du -h | sort -h'

# Tree with colors
alias tree='tree -C'

# Pretty mount
alias mnt='mount | column -t'

# Show PATH in readable format
alias showpath='echo $PATH | tr ":" "\n"'

# Reload DNS (macOS)
alias flushdns-mac='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Show hidden files in Finder (macOS)
alias showhidden='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# Lock screen (macOS)
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Empty trash (macOS)
alias emptytrash='sudo rm -rf ~/.Trash/*'

# Update and cleanup
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'

# SSH without host key checking
alias sshi='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

# Quick HTTP methods
alias GET='curl -X GET'
alias POST='curl -X POST'
alias PUT='curl -X PUT'
alias DELETE='curl -X DELETE'

# Copy working directory
alias cwd='pwd | tr -d "\n" | pbcopy'

# Show disk usage of current directory
alias usage='du -h -d 1'

# Show open files
alias openfiles='lsof | wc -l'

# Show system info
alias sysinfo='uname -a'

# Restart network (Linux)
alias netrestart='sudo systemctl restart NetworkManager'

# Show battery status (Linux)
alias battery='upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to\ full|percentage"'

# Show USB devices
alias usb='lsusb'

# Show PCI devices
alias pci='lspci'

# Show kernel version
alias kernel='uname -r'

# Quick calculator
alias calc='bc -l'

# Generate random password
alias genpass='openssl rand -base64 20'

# Show temperature
alias temp='sensors'

# Show fan speed
alias fan='sensors | grep fan'

# Copy with progress
alias cpv='rsync -ah --info=progress2'

# Backup files
alias backup='rsync -avz --progress'
