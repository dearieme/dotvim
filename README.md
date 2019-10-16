## My vim configuration

Originally forked from https://github.com/tempire/dotvim but bears little
resemblance now. Uses pathogen to load plugins.

## Install

    git clone git://github.com/dearieme/dotvim.git .vim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    cd .vim
    ln -s ~/.vim/vimrc ~/.vimrc

    # Call :PlugInstall inside neovim to install all the plugins


