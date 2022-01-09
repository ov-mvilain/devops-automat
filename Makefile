# Makefile for OpenValley DevOps environment
# Maintainer Michael Vilain <michael.vilain@theonevalley.com>

.PHONY : test clean install

BREW_URL := https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

# test returns blank if running on AWS
# ifconfig will run on AWS and MacOS
IP := $(shell test -e /usr/bin/curl && curl -m 2 -s -f http://169.254.169.254/latest/meta-data/public-ipv4)
ifeq ($(strip $(IP)),)
AWS := "n"
else
AZ := $(shell curl -m 2 -s -f http://169.254.169.254/latest/meta-data/placement/availability-zone)
endif

# make 3.81 only tests for empty/non-empty string
APP := $(shell test -e /Applications && echo "Y")
# Amazon Linux has a /etc/os-release file ID=amzn
ifeq ($(strip $(APP)),)
ID := $(shell awk '/^ID=/{print $1}' /etc/os-release | sed -e "s/ID=//" -e 's/"//g')
VER = $(shell grep "VERSION_ID" /etc/os-release | sed -e 's/VERSION_ID=//' -e 's/"//g')
OS := $(ID)$(VER)
IP := $(shell ifconfig | grep -i "UP,BROADCAST" -A6 | grep 'inet ' | sed -e 's/.*netmask.* //')

else ifeq ($(APP),Y)
OS=$(shell uname)
ID := macos
VER := $(shell uname -r)
IP := $(shell /sbin/ifconfig | grep -i "UP,BROADCAST" -A7 | grep "\tinet "| sed -e "s/ netmask.*//")
endif

RHEL_PKGS := bind-utils curl epel-release lsof net-tools yum-utils vim wget
MAC_PKGS := $(RHEL_PKGS)

TARGETS :=  install

all: $(TARGETS)

test:
	@echo "/Applications exists? " $(APP)
	@echo "OS=<$(OS)>   VER=<$(VER)>"
	@echo 'ID=<$(ID)>'
	@echo "IP="$(IP)
	@echo "Homebrew: "$(BREW_URL)
	@echo "logname:" $(LOGNAME) " sudo_user:" $(SUDO_USER)
# ------------------------------------------------------------------------ RHEL distros
ifeq ($(ID),macos)
	@echo "packages= "$(MAC_PKGS)
else ifeq ($(OS),Linux)
	@echo "packages= "$(RHEL_PKGS)
else
	@echo "packages="
endif


clean:
ifeq ($(SUDO_USER),)
	sudo rm -vf /etc/sudoers.d/$(LOGNAME)
endif

sudo:
ifeq ($(SUDO_USER),)
	@echo "Please rerun 'make sudo' to add your account to /etc/sudoers.d/$(LOGNAME)"
else
	echo "$(SUDO_USER) ALL = NOPASSWD: ALL" > /etc/sudoers.d/$(SUDO_USER)
endif


install: brew ansible

# install brew package manager...must run make sudo as root first
# https://brew.sh/
brew: sudo
	if [ ! -e /usr/local/bin/brew ]; then \
		curl -fsSL $(BREW_URL) -o homebrew.sh; \
		chmod 755 homebrew.sh; \
		./homebrew.sh; \
	else \
		echo "*** brew already installed ***"; \
	fi


ansible:
ifeq ($(ID),macos)
	@echo "ansible local: "'<$(OS)>'
	brew install ansible
else ifeq ($(ID),amzn)
	echo "ansible local: "'<$(OS)>'
endif

# fedora 27 and centos8 already has git 2.x installed
git : git-install git-config

git-install:
ifeq ($(ID),amzn)
	@echo "amazon git install"
else ifeq ($(ID),macos)
	if [[ ! -e /usr/bin/git ]]; then brew install git; fi
endif

git-config: git-install
	@echo "-----------------------------------------------"
	@echo "*************** be sure to set ***************"
	@echo "   git config --global user.name <YOUR NAME>'"
	@echo "   git config --global user.email <YOUR EMAIL>'"
	@echo "------------------------------------------------"

	git config --global color.ui true
	git config --global core.pager ''
	git config --global push.default simple
	git config --global alias.st status
	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.cl commit
	git config --global alias.origin "remote show origin"
	git config --global alias.mylog "log --pretty = format:'%h %s [%an]' --graph"
	git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit --all"
