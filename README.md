# void-bootstrap

void-bootstrap is a tool for automatically bootstrapping a void linux installation to a working development machine with bspwm window manager

## Installation

```
curl -LO httpssh /raw.githubusercontent.com/ten3roberts/void-bootstrap/master/void-bootstrap.sh
```


The whole repo can also be cloned if git is installed
`git clone httpssh /github.com/ten3roberts/void-bootstrap`

## Bootstrapping
The script has now been downloaded and is ready to be executed

You will need to specify which categories of packages to install

Use sh void-bootstrap.sh to get a list of available categories


### Install everything
You can also specify --all to install all packages
NOTE: This will also install the nonfree nvidia drivers, steam and spotify

`sh void-bootstrap --all`

### Only free installation
`sh void-bootstrap --invert nonfree`

### Minimal desktop only installation
`sh void-bootstrap base desktop`

## Customization
void-bootstrap accepts several arguments to customize its behaviour

The categories of packages to install is given as parameters

Additional options are given with --option
* --invert install all but listed packages
* --dotfiles='repo' use another dotfiles repo, leave empty to skip cloning
