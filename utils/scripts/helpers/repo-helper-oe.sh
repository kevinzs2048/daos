#!/bin/bash
set -uex

# This script is used by dockerfiles to optionally use
# a local repository instead of a distro provided repository.
# It will also optionally allow running a /tmp/install script
# for custom packages if present.

: "${REPO_FILE_URL:=}"
: "${BASE_DISTRO:=openeuler:$MAJOR_VER}"
: "${JENKINS_URL:=}"
: "${REPOS:=}"

# shellcheck disable=SC2120
disable_repos () {
    local repos_dir="$1"
    shift
    local save_repos
    IFS=" " read -r -a save_repos <<< "${*:-} daos_ci-oe$MAJOR_VER-artifactory"
    if [ -n "$REPO_FILE_URL" ]; then
        pushd "$repos_dir"
        local repo
        for repo in "${save_repos[@]}"; do
            mv "$repo".repo{,.tmp}
        done
        for file in *.repo; do
            true > "$file"
        done
        for repo in "${save_repos[@]}"; do
            mv "$repo".repo{.tmp,}
        done
        popd
    fi
}

# Use local repo server if present
install_curl() {
    :
}

# installs/upgrades of epel-release add repos
# Disable mirrorlist check when using local repos.
DISTRO="openeuler"
# Use local repo server if present
# if a local repo server is present and the distro repo server can not
# be reached, have to bootstrap in an environment to get curl installed
# to then install the pre-built repo file.

MAJOR_VER="${BASE_DISTRO##*:}"
MAJOR_VER="${MAJOR_VER%%.*}"
if [ -n "$REPO_FILE_URL" ]; then
    install_curl
    mkdir -p /etc/yum.repos.d
    pushd /etc/yum.repos.d/
    curl -k -f -o daos_ci-oe"$MAJOR_VER"-artifactory.repo        \
         "$REPO_FILE_URL"daos_ci-oe"$MAJOR_VER"-artifactory.repo
    disable_repos /etc/yum.repos.d/
    popd
fi
dnf -y install dnf-plugins-core
dnf -y config-manager --save --setopt=assumeyes=True
dnf config-manager --save --setopt=install_weak_deps=False
dnf clean all

daos_base="job/daos-stack/job/"
artifacts="/artifact/artifacts/oe$MAJOR_VER/"
save_repos=()
for repo in $REPOS; do
    # don't install daos@ repos since we are building daos
    if [[ $repo = daos@* ]]; then
        continue
    fi
    branch="master"
    build_number="lastSuccessfulBuild"
    if [[ $repo = *@* ]]; then
        branch="${repo#*@}"
        repo="${repo%@*}"
        if [[ $branch = *:* ]]; then
            build_number="${branch#*:}"
            branch="${branch%:*}"
        fi
    fi
    echo -e "[$repo:$branch:$build_number]\n\
name=$repo:$branch:$build_number\n\
baseurl=${JENKINS_URL}$daos_base$repo/job/$branch/$build_number$artifacts\n\
enabled=1\n\
gpgcheck=False\n
module_hotfixes=true\n" >> /etc/yum.repos.d/"$repo:$branch:$build_number".repo
    cat /etc/yum.repos.d/"$repo:$branch:$build_number".repo
    save_repos+=("$repo:$branch:$build_number")
done

disable_repos /etc/yum.repos.d/ "${save_repos[@]}"
