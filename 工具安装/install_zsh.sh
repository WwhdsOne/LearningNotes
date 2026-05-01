#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check the operating system
OS=$(uname -s)

# 1. Install Zsh
echo "Installing Zsh..."
if command_exists zsh; then
    echo "Zsh is already installed"
else
    if [[ "$OS" == "Darwin" ]]; then
        # macOS: Using brew to install zsh
        echo "macOS detected. Installing Zsh using Homebrew..."
        if ! command_exists brew; then
            echo "Homebrew not found, installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install zsh
    elif [[ "$OS" == "Linux" ]]; then
        # Ubuntu/Debian: Using apt to install zsh
        echo "Ubuntu/Debian detected. Installing Zsh using apt..."
        sudo apt update
        sudo apt install zsh -y
    else
        echo "Unsupported OS detected. Please install Zsh manually."
        exit 1
    fi
fi

# Set Zsh as default shell
echo "Setting Zsh as the default shell..."
chsh -s "$(which zsh)"

# 2. Install Oh My Zsh
echo "Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed"
fi

# 3. Install Oh My Zsh plugins
echo "Installing Oh My Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

# Enable plugins in .zshrc
echo "Enabling plugins in .zshrc..."
sed -i '' 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete /' ~/.zshrc

# 4. Install Starship
echo "Installing Starship..."
if command_exists starship; then
    echo "Starship is already installed"
else
    if [[ "$OS" == "Darwin" ]]; then
        brew install starship
    elif [[ "$OS" == "Linux" ]]; then
        curl -sS https://starship.rs/install.sh | sh
    else
        echo "Unsupported OS detected. Please install Starship manually."
        exit 1
    fi
fi

# Add Starship initialization to .zshrc
echo "Adding Starship to .zshrc..."
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# 5. Install Nerd Font (Hack Nerd Font)
echo "Installing Hack Nerd Font..."
if [[ "$OS" == "Darwin" ]]; then
    brew tap homebrew/cask-fonts
    brew install --cask font-hack-nerd-font
elif [[ "$OS" == "Linux" ]]; then
    echo "Please manually install a Nerd Font on Linux."
else
    echo "Unsupported OS for font installation."
fi

# 6. Install Catppuccin Powerline theme for Starship
echo "Configuring Catppuccin Powerline theme..."
starship preset catppuccin-powerline -o ~/.config/starship.toml

# Provide instructions to change the palette in starship.toml
echo "You can change the Starship theme palette by editing ~/.config/starship.toml and setting 'palette' to one of the following:"
echo "- catppuccin_mocha (default, dark)"
echo "- catppuccin_frappe"
echo "- catppuccin_macchiato"
echo "- catppuccin_latte (light)"

# 7. Install tools: bat, glow, poppler-utils, eza, hexyl, mediainfo, exiftool
echo "Installing tools: bat, glow, poppler-utils, eza, hexyl, mediainfo, exiftool..."
if [[ "$OS" == "Darwin" ]]; then
    brew install bat glow poppler-utils eza hexyl mediainfo exiftool chafa
elif [[ "$OS" == "Linux" ]]; then
    if command_exists apt; then
        sudo apt update
        sudo apt install -y bat glow poppler-utils eza hexyl mediainfo exiftool chafa
    else
        echo "Unsupported Linux package manager. Please install these tools manually."
        exit 1
    fi
else
    echo "Unsupported OS detected. Please install these tools manually."
    exit 1
fi

# 8. Create yazi.toml configuration file
echo "Creating yazi.toml configuration file..."
cat <<EOL > ~/.config/yazi/yazi.toml
[mgr]
# 窗口布局比例 [父目录:当前目录:预览窗口]
ratio = [1, 2, 8]

# 文件排序方式
sort_by = "alphabetical"  # alphabetical | created | modified | natural | size | extension

# 是否优先显示目录
sort_dir_first = true

# 是否显示隐藏文件
show_hidden = false

[preview]
# 预览窗口最大尺寸
image = true
max_width = 900
max_height = 1350
# 图片预览质量 (1-100)
image_quality = 80

# 图片缩放滤镜
image_filter = "triangle"  # nearest | triangle | catmull-rom | gaussian | lanczos3
EOL

# 9. Source .zshrc to apply changes
echo "Applying changes..."
source ~/.zshrc

echo "Installation completed successfully!"