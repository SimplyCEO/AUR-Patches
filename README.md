AUR Patches
===========

Personal patches for some packages.
SystemD-free, minimalistic, and bleeding-edge.

To use it, search for the package name and fetch the repository:

```shell
#####################
# PKGBUILD PATCHING #
#####################
# From: https://github.com/SimplyCEO/AUR-Patches

# Why do I need to do this? Why can not developers do a good job?
get_shit_package_name_definition()
{
  eval "$(grep -E '^(_projectname|_mainpkgname)=' PKGBUILD)"
  PKGNAME="${_mainpkgname}"
}

get_patch()
{
  curl -s -o PKGBUILD.patch "https://raw.githubusercontent.com/SimplyCEO/AUR-Patches/refs/heads/master/${PKGNAME}/PKGBUILD.patch"
  if [ $? -ne 0 ] || grep -iq "NOT FOUND" PKGBUILD.patch; then
    rm --force PKGBUILD.patch
    return 1
  fi
}

# --> Ignore patching during key generation.
if [ ! -f .doNotPatchAgain ]; then
  # --> Fetch existing patch file for PKGBUILD.
  PKGNAME="$(awk -F '=' '/^pkgname=/ {print $2}' PKGBUILD)"
  get_patch
  if [ $? -eq 1 ]; then
    PKGNAME="$(awk -F '=' '/^pkgbase=/ {print $2}' PKGBUILD)"
    get_patch
    if [ $? -eq 1 ]; then
      get_shit_package_name_definition
      get_patch
    fi
  fi

  # --> Patch the PKGBUILD file if there is one for it.
  if [ -f PKGBUILD.patch ]; then
    printf "\033[1;34m::\033[0m Patch file exists for PKGBUILD. Patching...\n"
    patch -N PKGBUILD < PKGBUILD.patch > /dev/null 2>&1
    touch .doNotPatchAgain
    makepkg -g >> PKGBUILD
    rm .doNotPatchAgain
  fi
fi
```

This script need to be placed somewhere in `makepkg.conf`.

