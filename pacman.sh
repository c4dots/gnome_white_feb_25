#!/bin/bash

# Clone repo
git clone https://github.com/c4dots/gnome_white_feb_25
cd gnome_white_feb_25

# Args
DO_UPDATE=true
DO_REBOOT=false
IGNORE_WRONG_ATTR=false
PACKAGES=("nautilus" "git" "python3" "ttf-ubuntu-font-family" "gnome-shell-extensions" "gnome-text-editor" "gnome-tweaks" "gnome-shell-extension-desktop-icons-ng" "gnome-shell-extension-arc-menu" "zsh" "powerline" "powerline-fonts" )
for ARG in "$@"; do
  case $ARG in
    --no-update)
      DO_UPDATE=false
      ;;
    --reboot)
      DO_REBOOT=true
      ;;
    --ignore-wrong-attr)
      IGNORE_WRONG_ATTR=true
      ;;
    *)
      if [[ "$IGNORE_WRONG_ATTR" == false ]]; then
          echo ">> Usage: $0 [--no-update] [--reboot] [--ignore-wrong-attr]"
          exit 1
      fi
      ;;
  esac
done

#################### THEMES ####################
# Shell Theme
if [ ! -d "$HOME/.themes/Colloid-Light-Nord" ]; then
    echo ">> Installing theme..."
    git clone https://github.com/vinceliuice/Colloid-gtk-theme
    cd Graphite-gtk-theme
    sh install.sh --tweaks rimless normal -n Colloid-Light-Nord
else
    echo ">> Theme already installed, skipping."
fi

# Icon Theme
if [ ! -d "$HOME/.icons/Futura" ]; then
    echo ">> Installing icon theme..."
    git clone https://github.com/coderhisham/Futura-Icon-Pack
    cp -R Futura-Icon-Pack ~/.icons/Futura
else
    echo ">> Icon theme already installed, skipping."
fi

# Background
echo ">> Changing Background"
cp background.png ~/.config/background
#################### THEMES ####################


#################### PACKAGES ####################
# Update
if [ "$DO_UPDATE" = true ]; then
    echo ">> Updating system..."
    sudo pacman -Syu --noconfirm
fi

# Install packages
for PACKAGE in "${PACKAGES[@]}"; do
    if pacman -Qi "$PACKAGE" &> /dev/null; then
        echo ">> $PACKAGE is already installed."
    else
        sudo pacman -S "$PACKAGE" --noconfirm
        echo ">> $PACKAGE has been installed."
    fi
done

if ! command -v diodon &> /dev/null; then
  echo ">> Installing Diodon..."
  yay -S diodon --noconfirm
else
  echo ">> Diodon is already installed. Skipping installation."
fi

if ! gnome-extensions list | grep -q "search-light"; then
    echo ">> Installing Search Light extension..."
    git clone https://github.com/icedman/search-light
    cd search-light
    make
    cd ..
else
    echo ">> Search Light extension is already installed. Skipping installation."
fi

if ! gnome-extensions list | grep -q "dash-to-dock"; then
    echo ">> Installing Dash to dock extension..."
    yay -S gnome-shell-extension-dash-to-dock --noconfirm
else
    echo ">> Dash to dock extension is already installed. Skipping installation."
fi

if ! gnome-extensions list | grep -q "openbar"; then
    echo ">> Installing OpenBar extension..."
    git clone https://github.com/neuromorph/openbar.git
    cp -R openbar/openbar@neuromorph/ ~/.local/share/gnome-shell/extensions/
else
    echo ">> OpenBar extension is already installed. Skipping installation."
fi

if ! gnome-extensions list | grep -q "top-bar-organizer"; then
    echo ">> Installing top bar organizer extension..."
    yay -S gnome-shell-extension-top-bar-organizer --noconfirm
else
    echo ">> Top bar organizer extension is already installed. Skipping installation."
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo ">> Oh my ZShell is already installed. Skipping installation."
else
    echo ">> Installing Oh my ZShell..."
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/binding "'<Super>t'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/command "'gnome-terminal -- zsh'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/name "'terminal'"
fi
echo ">> Changing ZSH Theme!"
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="jonathan"/' ~/.zshrc
source ~/.zshrc
#################### PACKAGES ####################


#################### CONFIG ####################
# Enable extensions
echo ">> Enabling extensions..."
gnome-extensions enable search-light@icedman.github.com
gnome-extensions enable ding@rastersoft.com
gnome-extensions enable arcmenu@arcmenu.com
gnome-extensions enable openbar@neuromorph
gnome-extensions enable top-bar-organizer@julian.gse.jsts.xyz
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable dash-to-panel@jderose9.github.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com

echo ">> Loading configs..."
dconf load / < ./conf/apps/gedit
dconf load / < ./conf/apps/nautilus
dconf load / < ./conf/extensions/arcmenu
dconf load / < ./conf/extensions/ding
dconf load / < ./conf/extensions/diodon
dconf load / < ./conf/extensions/dtd
dconf load / < ./conf/extensions/searchlight
dconf load / < ./conf/extensions/topbar
dconf load / < ./conf/desktop
#################### CONFIG ####################

echo ">> Done."

if [ "$DO_REBOOT" = true ]; then
    sudo reboot now
fi
