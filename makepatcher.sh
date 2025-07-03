#!/hint/bash
#
# /etc/makepkg.conf.d/makepatcher.conf
#

# From: https://github.com/SimplyCEO/AUR-Patches

PKGNAME=""

# --> Retrieve package file from repository, if exist.
fetch_patch()
{
  local PATCHFILE="$1"

  curl -s -o "${PATCHFILE}.patch" "https://raw.githubusercontent.com/SimplyCEO/AUR-Patches/refs/heads/master/${PKGNAME}/${PATCHFILE}.patch"
  if [ $? -ne 0 ] || \
     grep -iq "NOT FOUND" "${PATCHFILE}.patch" || \
     grep -iq "MOVED PERMANENTLY" "${PATCHFILE}.patch"; then
    rm -f "${PATCHFILE}.patch"
    return 1
  fi
  return 0
}

# --> If PKGBUILD is already modified then skip.
if git diff --quiet PKGBUILD; then
  PKGNAME=$(cat .SRCINFO | grep "pkgname" | head -n 1 | cut -d " " -f 3)
  if [ ! -z ${PKGNAME} ]; then fetch_patch "PKGBUILD"; fi

  # --> Patch the PKGBUILD file if there is one for it.
  if [ -f PKGBUILD.patch ]; then
    if [ ! -z "$(grep -i "Patched PKGBUILD" PKGBUILD)" ] || \
       [ ! -z "$(grep -i "Patched AUR PKGBUILD" PKGBUILD)" ]; then printf "" >&2; else
      printf "\033[1;34m::\033[0m \033[1mPatch file exists for PKGBUILD. Patching...\033[0m\n" >&2
      patch -N PKGBUILD < PKGBUILD.patch > /dev/null 2>&1
      makepkg -g >> PKGBUILD
    fi
  fi
else
  printf "\033[1;34m::\033[0m \033[1mPKGBUILD has already been patched before. Continuning...\033[0m\n" >&2
fi

