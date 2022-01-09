# Makefile for OpenValley DevOps environment
# Maintainer Michael Vilain <michael.vilain@theonevalley.com>

.PHONY : test clean install

DOCKER_COMPOSE_URL = "https://github.com/docker/compose/releases/tag/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose"

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
ID := "macos"
VER := $(shell uname -r)
IP := $(shell /sbin/ifconfig | grep -i "UP,BROADCAST" -A7 | grep "\tinet "| sed -e "s/ netmask.*//")
endif


AM_PKGS := bind-utils curl epel-release lsof net-tools yum-utils vim wget

PKGS := $(RHEL_PKGS)
C7_PKGS := $(RHEL_PKGS) bash-completion
C8_PKGS := $(RHEL_PKGS) bash-completion tar python38
F_PKGS := $(RHEL_PKGS) dnf-utils
U_PKGS := curl vim lsof bash-completion dnsutils
D_PKGS := $(U_PKGS) sudo rsync net-tools open-vm-tools
S_PKGS := wget vim lsof bash-completion bind-utils net-tools
GIT_DEV_RPM_PKGS := automake curl-devel gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel wget
GIT_DEV_DEB_PKGS := build-essential autoconf libghc-zlib-dev libssl-dev libcurl4-gnutls-dev lib-expat1-dev gettext

TARGETS :=  install

all: $(TARGETS)

test:
	@echo "/Applications exists? " $(APP)
	@echo "ID=<$(ID)>   VER=<$(VER)>"
	@echo 'OS=<$(OS)>'
	@echo "IP="$(IP)
	@echo "docker-compose: "$(DOCKER_COMPOSE_URL)
	@echo "logname:" $(LOGNAME) " sudo_user:" $(SUDO_USER)
# ------------------------------------------------------------------------ RHEL distros
ifeq ($(ID),almalinux)
	@echo "packages= "$(C8_PKGS)
else ifeq ($(ID),amazon)
	@echo "packages= "$(A2_PKGS)
else ifeq ($(OS),centos6)
	@echo "packages= "$(C6_PKGS)
else ifeq ($(OS),centos7)
	@echo "packages= "$(C7_PKGS)
else ifeq ($(OS),centos8)
	@echo "packages= "$(C8_PKGS)
else ifeq ($(ID),fedora)
	@echo "packages= "$(F_PKGS)
else ifeq ($(ID),rocky)
	@echo "packages= "$(C8_PKGS)
# ------------------------------------------------------------------------ DEBIAN distros
else ifeq ($(ID),ubuntu)
	@echo "packages= "$(U_PKGS)
else ifeq ($(ID),debian)
	@echo "packages= "$(D_PKGS)
else ifeq ($(ID),"suse")
	@echo "packages= "$(S_PKGS)
else
	@echo "packages="
endif


clean:

sudo:
ifneq ($(SUDO_USER),)
	echo "$(SUDO_USER) ALL = NOPASSWD: ALL" > /etc/sudoers.d/$(SUDO_USER)
else
	@echo "Please rerun 'make sudo' to add your account to /etc/sudoers.d/$(LOGNAME)"
endif


install: brew ansible_local

# install brew package manager...must run make sudo as root first
# https://brew.sh/
brew: sudo
	if [ ! -e /usr/local/bin/brew ]; then \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh; \
	fi


ansible_local:
	@echo '<$(OS)>'


# fedora 27 and centos8 already has git 2.x installed
git : git-install git-config

git-install:
# ------------------------------------------------------------------------ RHEL distros
ifeq ($(OS),centos8)
	-yum install -y git
else ifeq ($(OS),centos6)
	-yum install  -y git
else ifeq ($(OS),centos7)
	-yum install -y git
else ifeq ($(OS),centos8)
	-yum install -y git
else ifeq ($(ID),fedora)
	-dnf install -y git
# 	-git --version
# 	-echo "git 2.x already installed"
else ifeq ($(ID),rocky)
	-yum install -y git
# ------------------------------------------------------------------------ DEBIAN distros
else ifeq ($(ID),ubuntu)
	-apt-get install -y git
else ifeq ($(ID),debian)
	-apt-get install -y git
else ifeq ($(ID),suse)
	-zypper --non-interactive install git
else ifeq ($(ID),zorin)
	-apt-get install -y git
endif



git-config: git-install
	echo "be sure to 'set git config --global user.name <YOUR NAME>'"
	echo "and 'git config --global user.email <YOUR EMAIL>'"

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


# must be run as root or it won't install
# don't use recommended repository because that's OS-dependent...use script
docker:
	if [ ! -e /bin/docker ]; then \
		curl -fsSL https://get.docker.com/ | sh; \
		curl -L $(DOCKER_COMPOSE_URL) > /usr/local/bin/docker-compose; \
		chmod +x /usr/local/bin/docker-compose; \
		sed -i -e "/^MountFlags/d" /lib/systemd/system/docker.service; \
		systemctl enable docker; \
		systemctl daemon-reload; \
		systemctl start docker; \
		docker run hello-world; \
	fi
ifneq ($(SUDO_USER),)
	usermod -aG docker $(SUDO_USER)
endif
