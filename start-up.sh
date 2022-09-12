#!/bin/bash
GIT_ARCADE_MACHINE_REPO=https://github.com/thoth-tech/arcade-machine

SKM_DEPENDENCIES="clang libsdl2-dev libsdl2-gfx-dev libsdl2-mixer-dev libsdl2-ttf-dev libsdl2-net-dev libsdl2-image-dev libncurses-dev libpng-dev libcurl4-openssl-dev libbz2-dev libflac-dev libvorbis-dev libmikmod-dev libwebp-dev libfreetype6-dev cmake"

HOME_PATH=~
INSTALL_PATH="${HOME_PATH}/arcade-machine"
GAMES_DIRECTORY="${HOME_PATH}/arcade-machine/games"

#Update package lists, install curl and git and skm dependencies using distro specific package manager
if [ -f /etc/debian_version ]; then
    sudo apt-get update --assume-yes
    sudo apt-get install curl git $SKM_DEPENDENCIES --assume-yes
elif [ -f /etc/redhat-release ]; then
    sudo yum check-update
    sudo yum install curl git $SKM_DEPENDENCIES
elif [ -f /etc/arch-release ]; then
    sudo pacman -Sy
    sudo pacman -S curl git $SKM_DEPENDENCIES
else
    echo "Unsupported distro"
    exit 1
fi

#Check if SplashKit is installed
if ! [ -x "command -v skm" ]; then
    echo "Splashkit is already Installed"
else
    echo "Splashkit is not Installed"
    #Install SplashKit
    bash <(curl -s https://raw.githubusercontent.com/splashkit/skm/master/install-scripts/skm-install.sh)
    #Add to path
    export PATH=$PATH:$HOME/.splashkit
    skm linux install
fi

# Update the environment variable LD_LIBRARY_PATH to source the object file.
export LD_LIBRARY_PATH=$HOME/.splashkit/source



# Clone arcade machine repo if it doesn't exist, pull the code if it does
if [ ! -d "${INSTALL_PATH}" ]; then
    git clone --depth 1 --branch master $GIT_ARCADE_MACHINE_REPO "${INSTALL_PATH}"
    exit 1
elif [ -d "${INSTALL_PATH}" ]; then
    cd $INSTALL_PATH
    git pull $GIT_ARCADE_MACHINE_REPO
fi

(
    cd $INSTALL_PATH
    #Check if directory games exists:
    if [ -d "games" ]; then
        echo "Directory exists"
        if [ -d "games" ]; then
            git -C games pull
        else
            echo "Directoy exists, but doesn't contain games"
            git clone https://github.com/thoth-tech/arcade-games.git games
        fi
        
    else
        echo "Directory does not exist"
        git clone https://github.com/thoth-tech/arcade-games.git games
    fi
)

# Compile the arcade machine
(
    echo "Build the Arcade Machine"
    cd $INSTALL_PATH
    # Build the Arcade Machine
    make 
    # OR
    #skm g++ src/* -Iinclude -lstdc++fs -o test

    # skm clang++ Program.cpp -Iinclude -lstdc++fs -o arcade-machine
)

# Run the arcade machine
(
    echo "Run the Arcade Machine"
    cd $INSTALL_PATH
    #Launch the Arcade Machine
    ./ArcadeMachine*
)
