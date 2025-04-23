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

# --> Retrieve the package name based on key.
PKGNAME=""
get_package_value()
{
  local FILETMP=$(mktemp)
  local PACKAGE=""

  # --> Read package until key value.
  local LCOUNT=0
  local KEY="$1"
  while IFS= read -r LINE; do
    if echo "${LINE}" | grep -q "^${KEY}="; then
      PACKAGE="${LINE#${KEY}=}"
      echo "PATCHER_RETURN=${PACKAGE}" >> "${FILETMP}"
      break
    fi

    LCOUNT=$((LCOUNT + 1))
    if [ "${LCOUNT}" -gt 20 ]; then break; fi

    echo "${LINE}" >> "${FILETMP}"
  done < PKGBUILD

  # --> Source the key and retrieve the value
  . "${FILETMP}"
  PACKAGE="${PATCHER_RETURN}"
  rm "${FILETMP}"

  # --> Return error if no package was found.
  if [ -z "${PACKAGE}" ]; then return 1; fi

  # --> Remove git type.
  if [ "${PACKAGE: -4}" = "-git" ]; then
    PACKAGELEN=${#PACKAGE}
    PACKAGE="${PACKAGE:0:$((PACKAGELEN - 4))}"
  fi

  # --> Assign to variable.
  PKGNAME="${PACKAGE}"
}

# --> Retrieve package file from repository, if exist.
get_patch()
{
  curl -s -o PKGBUILD.patch "https://raw.githubusercontent.com/SimplyCEO/AUR-Patches/refs/heads/master/${PKGNAME}/PKGBUILD.patch"
  if [ $? -ne 0 ] || grep -iq "NOT FOUND" PKGBUILD.patch || grep -iq "Moved Permanently" PKGBUILD.patch; then
    rm --force PKGBUILD.patch
    return 1
  fi
}

# --> Fetch existing patch file for PKGBUILD.
get_package_value "pkgname"
if [ $? -ne 0 ]; then get_package_value "pkgbase"; fi
get_patch

# --> Patch the PKGBUILD file if there is one for it.
if [ -f PKGBUILD.patch ]; then
  if ! grep -iq "Patched AUR PKGBUILD" PKGBUILD; then
    printf "\033[1;34m::\033[0m \033[1mPatch file exists for PKGBUILD. Patching...\033[0m\n"
    patch -N PKGBUILD < PKGBUILD.patch > /dev/null 2>&1
  fi
fi
```

This script need to be placed somewhere in `makepkg.conf`.

