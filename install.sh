#backports
"deb http://deb.debian.org/debian/ trixie-backports main non-free-firmware"
"deb-src http://deb.debian.org/debian/ trixie-backports main non-free-firmware"
#installing the packages 
sudo apt update
sudo apt upgrade -yy
sudo apt install vlc micro thunar feh libreoffice icewm fastfetch alsa-utils pulseaudio pavucontrol unzip cargo p7zip ntfs-3g eza zoxide vlc gimp imagemagick fzf ffmpeg fonts-firacode fonts-jetbrains-mono fonts-croscore fonts-crosextra-carlito fonts-crosextra-caladea fonts-noto fonts-noto-cjk git falkon -yy
#micro plugins
micro -plugin install filemanager  
micro -plugin install fzf           
micro -plugin install quoter        
micro -plugin install autoclose     
micro -plugin install detectindent  
micro -plugin install linter        
micro -plugin install go            
micro -plugin install fish
