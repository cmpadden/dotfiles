# Dependencies
* [GNU Stow](https://www.gnu.org/software/stow/)

# Usage
1) Clone and Initialize the Repository
```shell
$ git clone https://github.com/cmpadden/dotfiles.git ~/dotfiles
$ cd ~/dotfiles
$ git submodule init
$ git submodule update
```

2) Restore Desired Configuration Files
```shell
$ chmod +x .local/bin/bootstrap.sh
$ .local/bin/bootstrap.sh
```
