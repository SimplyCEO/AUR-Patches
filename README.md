AUR Patches
===========

Personal patches for some packages.
SystemD-free, minimalistic, and bleeding-edge.

To use it, search for the package name and fetch the repository:

```shell
# --> Fetch existing patch file for PKGBUILD.
PATCHER_PKGNAME="$(awk -F '=' '/^pkgname=/ {print $2}')"
PATCHER_PKGBASE="$(awk -F '=' '/^pkgbase=/ {print $2}')"
curl -o "PKGBUILD.patch" "https://raw.githubusercontent.com/SimplyCEO/AUR-Patches/refs/heads/master/${PATCHER_PKGNAME}/PKGBUILD.patch"
if grep -iq "NOT FOUND" "PKGBUILD.patch"; then
  rm -f "PKGBUILD.patch"
  curl -o "PKGBUILD.patch" "https://raw.githubusercontent.com/SimplyCEO/AUR-Patches/refs/heads/master/${PATCHER_PKGBASE}/PKGBUILD.patch"
  if grep -iq "NOT FOUND" "PKGBUILD.patch"; then
    rm -f "PKGBUILD.patch"
  fi
fi

# --> Patch the PKGBUILD file if there is one for it.
if [ -f "PKGBUILD.patch" ]; then
  printf "\033[1;32m==>\033[0m Patch file exists for PKGBUILD. Patching...\n"
  patch PKGBUILD < PKGBUILD.patch
  makepkg -g >> PKGBUILD
  printf "\n"
fi
```

This script need to be placed somewhere in `makepkg.conf`.

