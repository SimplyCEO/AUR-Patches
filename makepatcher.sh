#!/hint/bash
#
# /etc/makepkg.conf.d/makepatcher.conf
#

# From: https://github.com/SimplyCEO/AUR-Patches

# --> Retrieve the package name from array.
PKGARRAY=""
pkgarray()
{
  local L1COUNT=0
  local STRING=""
  local LSTART=$1
  local FILE="$2"
  local PKGKEY="$3"

  while IFS= read -r LINE; do
    if [ $L1COUNT -ge $LSTART ]; then
      STRING="${STRING}${LINE}"
      if [ "${LINE}" = ")" ]; then break; fi
    fi
    L1COUNT=$((L1COUNT + 1))
  done < "${FILE}"

  STRING=${STRING#${PKGKEY}=(}
  STRING=${STRING%)*}

  local ARRAY=($STRING)

  PKGARRAY="${ARRAY[0]//\'/}"
}

# --> Retrieve the package name based on key.
PKGNAME=""
get_package_name()
{
  local FILETMP=$(mktemp)
  local PACKAGE=""

  # --> Read package until key value.
  local LCOUNT=0
  local FILE="$1"
  local KEY="$2"

  if [ -f "${FILE}" ]; then
    while IFS= read -r LINE; do
      if printf "${LINE}" | grep -q "^${KEY}="; then
        PACKAGE="${LINE#${KEY}=}"
        if [ "${PACKAGE}" = "(" ]; then
          pkgarray $LCOUNT "${FILE}" "${KEY}"
          PACKAGE="${PKGARRAY}"
        fi
        printf "PATCHER_RETURN=${PACKAGE}\n" >> "${FILETMP}"
        break
      fi

      LCOUNT=$((LCOUNT + 1))
      if [ $LCOUNT -gt 20 ]; then break; fi

      printf "${LINE}\n" >> "${FILETMP}"
    done < "${FILE}"
  fi

  # --> Source the key and retrieve the value
  . "${FILETMP}"
  PACKAGE="${PATCHER_RETURN}"
  rm "${FILETMP}"

  # --> Return error if no package was found.
  if [ -z "${PACKAGE}" ]; then return 1; fi

  # --> Assign to variable.
  PKGNAME="${PACKAGE}"

  return 0
}

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

# --> Fetch existing patch file for PKGBUILD.
get_package_name "PKGBUILD" "_pkgbase"
if [ $? -ne 0 ]; then
  get_package_name "PKGBUILD" "_pkgname"
  if [ $? -ne 0 ]; then
    get_package_name "PKGBUILD" "pkgname"
    if [ $? -ne 0 ]; then get_package_name "PKGBUILD" "pkgbase"; fi
  fi
fi
if [ $? -eq 0 ]; then fetch_patch "PKGBUILD"; fi

# --> Patch the PKGBUILD file if there is one for it.
if [ -f PKGBUILD.patch ]; then
  if [ ! -z "$(grep -i "Patched PKGBUILD" PKGBUILD)" ] || \
     [ ! -z "$(grep -i "Patched AUR PKGBUILD" PKGBUILD)" ]; then printf ""; else
    printf "\033[1;34m::\033[0m \033[1mPatch file exists for PKGBUILD. Patching...\033[0m\n"
    patch -N PKGBUILD < PKGBUILD.patch > /dev/null 2>&1
    makepkg -g >> PKGBUILD
  fi
fi

