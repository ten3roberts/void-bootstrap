#!/bin/sh
div() {
    printf %`tput cols`s |tr " " "-"
}

usage() {
    div
    echo "Bootstraps a void linux installation with specified categories of packages" 
    echo ""
    echo "By default clone and installs my dotfiles, but can be customized with --dotfiles='repo', leave empty to not clone"
    echo "Changes the default shell to zsh"
    echo "Specify categories to install or use --all to install everything"
    echo "--all to install all categories"
    echo "--invert to install all but specified packages"
    div
    echo "available packages"
    div
    get_categories
    exit
}

format_category() {
    echo $1 | tr "[:upper:]" "[:lower:]" | cut -d '-' -f 2-
}

get_categories() {
    for LINE in `grep -v "^;;" void-packages.md | sed 's| |-|g'`
    do
        [[ "$LINE" == \#\#\#* ]] && format_category $LINE
    done
}

get_packages() {
    for LINE in `grep -v "^;;" void-packages.md | sed 's| |-|g'`
    do
        [[ "$LINE" == \#* ]] && CATEGORY=`format_category $LINE` || ([[ -n `contains "$@" $CATEGORY` ]] && echo -n "$LINE " )
        # echo "Cat: $CATEGORY"
    done
}

contains() {
    echo "$1" | egrep "(^| )$2($| )" 
}

# Normalize workdir
cd `dirname "$0"`

# Download package list if it doesn't exist
cat void-packages.md > /dev/null 2> /dev/null || echo "Downloading package list" && curl -LO "https://raw.githubusercontent.com/ten3roberts/void-bootstrap/master/void-packages.md"

[[ $# == 0 ]] && usage;


ALL=`contains "$*" "--all"`
INVERT=`contains "$*" "--invert"`
DOTFILES=`echo "$*" | sed -n 's/.*dotfiles=//p'`
[[ -z "$DOTFILES" ]] && [[ -z `echo "$*" | grep -- "--dotfiles="` ]] && echo "Using my dotfiles" && DOTFILES="https://github.com/ten3roberts/dotfiles"
CATEGORIES=`get_categories`
WANTED_CATEGORIES=`[[ -z "$ALL" ]] && echo "$@" || get_categories`
WANTED_PRUNED=""

# Make sure only valid categories are entered
for CATEGORY in $WANTED_CATEGORIES
do
    [[ $CATEGORY == "--*" ]] && continue
    [[ -n `contains "$CATEGORIES" "$CATEGORY"` ]] && WANTED_PRUNED+="$CATEGORY " || echo "Unknown category '$CATEGORY'" >&2
done

WANTED_CATEGORIES=$WANTED_PRUNED

# Invert if necessary
if [[ -n "$INVERT" ]]
then
    CATEGORIES_PRUNED=""
    echo "Inverting"
    for CATEGORY in $CATEGORIES
    do
        [[ -z `contains "$WANTED_CATEGORIES" "$CATEGORY"` ]] && CATEGORIES_PRUNED+="$CATEGORY "
    done
    WANTED_CATEGORIES="$CATEGORIES_PRUNED"
fi


echo "Installing categories: $WANTED_CATEGORIES"

div
PACKAGES=`get_packages "$WANTED_CATEGORIES"`

echo -e "Packages to install: \n$PACKAGES"
[[ -n `contains "$WANTED_CATEGORIES" "nonfree"` ]] && echo "Enabling nonfree void-repo" && xbps-install void-repo-nonfree

sudo xbps-install -S

sudo xbps-install -S "$WANTED_CATEGORIES"

# Change the default shell
sudo chsh -s /bin/zsh

# Clone the dotfiles
[[ -n "$DOTFILES" ]] && echo "Cloning dotfiles '$DOTFILES'" && git clone "$DOTFILES" "$HOME" && git config core.workdir="$HOME" && mv "$HOME/.git" "$HOME/.config/.git" || echo "Home directory is not empty, cloning into dotfiles" && git clone "$DOTFILES"

echo "Bootstrapping finished, it is recommended to reboot"
