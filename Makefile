# Makefile for OpenValley DevOps environment
# Maintainer Michael Vilain <michael.vilain@theonevalley.com>

.PHONY : test clean install

BREW_URL := https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
PYTHON3_URL := https://www.python.org/ftp/python/3.9.10/python-3.9.10-macosx10.9.pkg
PYTHON3_DEST = ~/Downloads/python-3.9.10-macosx10.9.pkg

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

TARGETS :=  help

all: $(TARGETS)

test:
	@echo "/Applications exists? " $(APP)
	@echo "OS=<$(OS)>   VER=<$(VER)>"
	@echo 'ID=<$(ID)>'
	@echo "IP="$(IP)
	@echo "Homebrew: "$(BREW_URL)
	@echo "logname:" $(LOGNAME) " sudo_user:" $(SUDO_USER)
	@echo "python3_url: "$(PYTHON3_URL)
	@echo "python3_dest:"$(PYTHON3_DEST)
# ------------------------------------------------------------------------ RHEL distros
ifeq ($(ID),macos)
	@echo "packages= "$(MAC_PKGS)
else ifeq ($(OS),Linux)
	@echo "packages= "$(RHEL_PKGS)
else
	@echo "packages="
endif

help:
	@echo This Makefile has the following targets:
	@echo
	@echo sudo make sudo -- run this first on MacOS to add the user to the /etc/sudoers.d/ directory
	@echo make macos     -- run this target to install DevOps tools on a MacOS system needed for automation
	@echo terraform plan -- configure an EC2 instance in a region, VPC, and subnet
	@echo terraform apply-- create a configured EC2 instance in a region, VPC, and subnet
	@echo make automat   -- run this target on an existing EC2 instance to install DevOps tools needed for automation


clean:
ifeq ($(SUDO_USER),)
	sudo rm -vf /etc/sudoers.d/$(LOGNAME)
endif

macos: python3 ansible sudo brew

sudo:
ifeq ($(SUDO_USER),)
	@echo "Please rerun 'make sudo' to add your account to /etc/sudoers.d/$(LOGNAME)"
else
	echo "$(SUDO_USER) ALL = NOPASSWD: ALL" > /etc/sudoers.d/$(SUDO_USER)
endif

# install brew package manager...must run make sudo as root first
# https://brew.sh/
# only installed on MacOS...does nothing on other OS
brew:
ifeq ($(ID),macos)
	if [ ! -e /usr/local/bin/brew ]; then \
		curl -fsSL $(BREW_URL) -o homebrew.sh; \
		chmod 755 homebrew.sh; \
		./homebrew.sh; \
	else \
		echo "*** brew already installed ***"; \
	fi
	brew install awscli azure-cli jq terraform terragrunt vagrant virtualbox wget yamllint
endif

python3:
ifeq ($(ID),macos)
	@echo "python3 local: "'<$(OS)>'
	@curl -s $(PYTHON3_URL) -o $(PYTHON3_DEST)
	@sudo installer -pkg $(PYTHON3_DEST) -target /
	@curl -O https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
	@python3.9 /tmp/get-pip.py
	# Apple's Xcode defines their own versions of these
	@for f in pycodestyle pyflakes pylint pyreverse pip pip3; do \
	  cd /usr/local/bin; \
	  rm $f; \
	  ln -s ../../../Library/Frameworks/Python.framework/Versions/3.9/bin/$f; \
	  done
	@echo "/Library/Frameworks/Python.framework/Versions/3.9/bin" > /tmp/python
	@sudo mv -v /tmp/python /etc/paths.d/
else ifeq ($(ID),amzn)
	echo "python3 local: "'<$(OS)>'
	sudo amazon-linux-extras install python3.8
endif


ansible: python3
ifeq ($(ID),macos)
	@echo "ansible local: "'<$(OS)>'
	@sudo launchctl limit maxfiles unlimited
	pip3 install ansible
else ifeq ($(ID),amzn)
	echo "ansible local: "'<$(OS)>'
	sudo amazon-linux-extras install ansible2
endif

# fedora 27 and centos8 already has git 2.x installed
git : git-install git-config

git-install:
ifeq ($(ID),amzn)
	echo "git-install local: "'<$(OS)>'
	if [[ ! -e /usr/bin/git ]]; then sudo yum install -y git; fi
else ifeq ($(ID),macos)
	echo "git-install local: "'<$(OS)>'
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
