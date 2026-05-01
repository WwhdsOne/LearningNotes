#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if a directory exists
dir_exists() {
    [[ -d "$1" ]]
}

# Check the operating system
OS=$(uname -s)

# Check if sudo is available
if command_exists sudo; then
    sudo_prefix="sudo"
else
    sudo_prefix=""
fi

# 1. Install Zsh
echo "1. Installing Zsh..."
if command_exists zsh; then
    echo "Zsh is already installed"
else
    if [[ "$OS" == "Darwin" ]]; then
        echo "macOS detected. Installing Zsh using Homebrew..."
        if ! command_exists brew; then
            echo "Homebrew not found, installing Homebrew..."
            $sudo_prefix /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        $sudo_prefix brew install zsh
    elif [[ "$OS" == "Linux" ]]; then
        echo "Ubuntu/Debian detected. Installing Zsh using apt..."
        $sudo_prefix apt update
        $sudo_prefix apt install -y zsh git gpg
    else
        echo "Unsupported OS detected. Please install Zsh manually."
        exit 1
    fi
fi

# Set Zsh as default shell
echo "2. Setting Zsh as the default shell..."
if [ ! -f ~/.zshrc ]; then
    touch ~/.zshrc
fi

# 2. Install Oh My Zsh
echo "3. Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed"
fi

# 3. Install Oh My Zsh plugins
echo "4. Installing Oh My Zsh plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Install zsh-autosuggestions plugin
if ! dir_exists "$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting plugin
if ! dir_exists "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Enable plugins in .zshrc (cross-platform fix)
echo "5. Enabling plugins in .zshrc..."
if [[ "$OS" == "Darwin" ]]; then
    sed -i '' 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
else
    sed -i 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
fi

# 4. Install Starship
echo "6. Installing Starship..."
if command_exists starship; then
    echo "Starship is already installed"
else
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Add Starship initialization to .zshrc
echo "7. Adding Starship initialization to .zshrc..."
if ! grep -q 'eval "$(starship init zsh)"' ~/.zshrc; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# 5. Install Nerd Font (Hack Nerd Font)
echo "8. Installing Hack Nerd Font..."
if [[ "$OS" == "Darwin" ]]; then
    brew tap homebrew/cask-fonts
    brew install --cask font-hack-nerd-font
elif [[ "$OS" == "Linux" ]]; then
    echo "Please manually install a Nerd Font on Linux."
fi

# 6. Install Catppuccin Powerline theme for Starship
echo "9. Configuring Catppuccin Powerline theme..."
mkdir -p ~/.config
starship preset catppuccin-powerline -o ~/.config/starship.toml

echo -e "\nYou can change the Starship theme palette by editing ~/.config/starship.toml"
echo "Options: catppuccin_mocha, frappe, macchiato, latte"

# 7. Install tools（已修复：poppler-utils → poppler）
echo "10. Installing tools: bat, glow, poppler, eza, hexyl, mediainfo, exiftool, chafa..."
if [[ "$OS" == "Darwin" ]]; then
    brew install bat glow poppler eza hexyl mediainfo exiftool chafa
elif [[ "$OS" == "Linux" ]]; then
    if command_exists apt; then
        apt update
        apt install -y bat poppler-utils eza hexyl mediainfo exiftool chafa
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | $sudo_prefix gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | $sudo_prefix tee /etc/apt/sources.list.d/charm.list
        $sudo_prefix apt update && $sudo_prefix apt install glow
    else
        echo "Unsupported Linux package manager."
        exit 1
    fi
fi

# 10. Create yazi.toml configuration file
echo "11. Creating yazi.toml configuration file..."
mkdir -p ~/.config/yazi
cat <<EOL > ~/.config/yazi/yazi.toml
[mgr]
ratio = [1, 2, 8]
sort_by = "alphabetical"
sort_dir_first = true
show_hidden = false

[preview]
image = true
max_width = 900
max_height = 1350
image_quality = 80
image_filter = "lanczos3"
EOL

# 11. Source .zshrc
echo "12. Applying changes..."
echo -e "\n✅ Installation completed successfully!"
echo -e "⚠️ 请重启终端生效所有配置\n"