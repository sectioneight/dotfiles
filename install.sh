#!/usr/bin/env bash

set -eu
set -o pipefail

# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd "$(dirname "${0}")" > /dev/null
THISDIR="$(pwd -P)"

RESET="\033[0m"
BLUE_BG="\033[44m"
GRAY_BG="\033[100m"
RED_FG="\033[91m"
BOLD="\033[1m"

_die() {
  echo -e "${RED_FG}${BOLD}${1}"
  exit "${2:-1}"
}

_skip() {
  [[ -n "${1}" ]] || _die "Skip called without argument"
  echo -e -n "Skipping ${GRAY_BG}$(basename "${1}")${RESET}"
  shift
  set +u
  ([[ -n "${*}" ]] && echo " (${*})") || echo
  set -u
}

UNINTERESTING=". .. .git .gitignore .gitmodules .vim.configure"

_scanAndLink () {
  for file in "${1}"/.* ; do
    realfile="$(basename "${file}")"
    for boring in ${UNINTERESTING} ; do
      if [[ "${realfile}" == "${boring}" ]] ; then
        _skip "${boring}" "support file"
        continue 2
      fi
    done

    source="${file}"
    dest="${HOME}/$(basename "${file}")"

    if [[ -h "${dest}" ]] ; then
      realdest="$(readlink "${dest}")"
      if [[ ! "${realdest}" =~ ${THISDIR}.* ]] ; then
        if [[ ! -e "${source}" ]] ; then
          echo -e "Removing bad link: ${BOLD}${BLUE_BG}${dest}${RESET}"
          unlink "${dest}"
        fi
      fi

      if [[ "${realdest}" == "${source}" || "${HOME}/${realdest}" == "${source}" ]] ; then
        _skip "${dest}"
        continue
      fi
    fi

    if [[ -f "${dest}"  || -h "${dest}" || -d "${dest}" ]]; then
      # Only try to diff files
      if [[ ! -d "${dest}" ]] ; then
        if diff "${dest}" "${source}" ; then
          _skip "${dest}"
          # extremely same
          continue
        fi
      fi

      echo -e -n "${BOLD}${RED_FG}${dest}${RESET} already exists and is not a symlink. Overwrite it? y/N: "
      read -r answer
      answer="${answer:-N}"
      if [[ "${answer}" == "y" ]]  ; then
        backup="${dest}.bak"
        echo "Overwriting previous file. Saved to ${backup}"
        mv "${dest}" "${backup}"
        ln -sf "${source}" "${dest}"
      fi
    else
      echo -e "Linking  ${GRAY_BG}${source}${RESET} -> ${BLUE_BG}${dest}${RESET}"
      ln -s "${source}" "${dest}"
    fi
  done
}

# TODO break out macOS and Linux into their own dirs
_scanAndLink "${THISDIR}"

mkdir -p "${HOME}/bin"
mkdir -p "${HOME}/src/go"

maybelink () {
  local _from="${1}"
  local _to="${2}"
  [ -e "${_to}" ] && return
  ln -s "${_from}" "${_to}"
}

mkdir -p "${HOME}/.config"
maybelink "${HOME}/.vim" "${HOME}/.config/nvim"

if [[ $(command -v i3 > /dev/null) && ! -d "${HOME}/.config/i3" ]] ; then
  maybelink "${THISDIR}/linux/.i3" "${HOME}/.config/i3"
fi

for file in "${THISDIR}"/bin/* ; do
  maybelink "${file}" "${HOME}/bin"
done

FZF_INSTALL="${HOME}/.fzf/install"
FZF_BIN="${HOME}/.fzf/bin/fzf"
if [[ ! -x "${FZF_BIN}" && -x "${FZF_INSTALL}" ]] ; then
  echo -e "Auto-installing${RESET} ${BLUE_BG}fzf${RESET}"
  "${FZF_INSTALL}" --no-update-rc --completion --key-bindings
fi

# TODO OS-XX specific hooks
if command -v defaults > /dev/null ; then
  # do stuff from here: https://github.com/herrbischoff/awesome-osx-command-line
  # remove some siulator crap
  xcrun simctl delete unavailable

  # add a stack of recent apps!!
  if ! grep -q "recents-tile" <(defaults read com.apple.dock persistent-others) ; then
    defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'
    killall Dock
  fi

  # enable quit finder
  defaults write com.apple.finder QuitMenuItem -bool true
  killall Finder
fi
popd > /dev/null
