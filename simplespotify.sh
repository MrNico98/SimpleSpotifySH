#!/usr/bin/env bash

buildVer="1.2.40.599.g606b7f29"

case $(uname | tr '[:upper:]' '[:lower:]') in
  darwin*) platformType='macOS' ;;
        *) platformType='Linux' ;;
esac

clr='\033[0m'
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'

show_help() {
  echo -e \
"Options:
-B, --blockupdates     : block Spotify auto-updates [macOS]
-c, --clearcache       : clear Spotify app cache
-d, --devmode          : enable developer mode
-e, --noexp            : exclude all experimental features
-f, --force            : force AIMODS-Bash to run
-h, --hide             : hide non-music on home screen
--help                 : print this help message
-i, --interactive      : enable interactive mode
--installdeb           : install latest client deb pkg on APT-based distros [Linux]
--installmac           : install latest supported client version [macOS]
-l, --lyricsbg         : set lyrics background color to black
--nocolor              : remove colors from AIMODS-Bash output
-o, --oldui            : use old home screen UI
-p, --premium          : paid premium-tier subscriber
-P <path>              : set path to Spotify
-S, --skipcodesign     : skip codesigning [macOS]
--stable               : use with '--installdeb' for stable branch [Linux]
--uninstall            : uninstall AIMODS-Bash
-v, --version          : print AIMODS-Bash version
-V <version>           : install specific client version [macOS]
"
}

while getopts ':BcdefF:hilopP:SvV:-:' flag; do
  case "${flag}" in
    -)
      case "${OPTARG}" in
        blockupdates) [[ "${platformType}" == "macOS" ]] && blockUpdates='true' ;;
        clearcache) clearCache='true' ;;
        debug) debug='true' ;;
        devmode) devMode='true' ;;
        force) forceAIMODS='true' ;;
        help) show_help; exit 0 ;;
        hide) hideNonMusic='true' ;;
        installdeb) [[ "${platformType}" == "Linux" ]] && installDeb='true' ;;
        installmac) [[ "${platformType}" == "macOS" ]] && installMac='true' ;;
        interactive) interactiveMode='true' ;;
        logo) logoVar='true' ;;
        lyricsbg) lyricsBg='true' ;;
        nocolor) unset clr green red yellow ;;
        noexp) excludeExp='true' ;;
        oldui) oldUi='true' ;;
        premium) paidPremium='true' ;;
        skipcodesign) [[ "${platformType}" == "macOS" ]] && skipCodesign='true' ;;
        stable) [[ "${platformType}" == "Linux" ]] && stableVar='true' ;;
        uninstall) uninstallAIMODS='true' ;;
        version) verPrint='true' ;;
        $(date +"%y%d%m%H:%M")) t='true' ;;
        *) echo -e "${red}Error:${clr} '--""${OPTARG}""' not supported\n\n$(show_help)\n" >&2; exit 1 ;;
      esac ;;
    B) [[ "${platformType}" == "macOS" ]] && blockUpdates='true' ;;
    c) clearCache='true' ;;
    d) devMode='true' ;;
    e) excludeExp='true' ;;
    f) forceAIMODS='true' ;;
    F) forceVer="${OPTARG}"; clientVer="${forceVer}" ;;
    h) hideNonMusic='true' ;;
    i) interactiveMode='true' ;;
    l) lyricsBg='true' ;;
    o) oldUi='true' ;;
    p) paidPremium='true' ;;
    P) p="${OPTARG}"; installPath="${p}"; installOutput=$(echo "${installPath}" | perl -pe 's|^$ENV{HOME}|~|') ;;
    S) [[ "${platformType}" == "macOS" ]] && skipCodesign='true' ;;
    v) verPrint='true' ;;
    V) [[ "${platformType}" == "macOS" ]] && { 
         [[ "${OPTARG}" =~ ^1\.[12]\.[0-9]{1,2}\.[0-9]{3,}.*$ ]] && {
           versionVar="${OPTARG}"
           installMac='true'
         } || {
           echo -e "${red}Error:${clr} Invalid or unsupported version\n" >&2
           exit 1
         }
       } || {
         echo -e "${red}Error:${clr} AIMODS-Bash does not support '-V' on Linux\n" >&2
         exit 1
       } ;;
    \?) echo -e "${red}Error:${clr} '-""${OPTARG}""' not supported\n\n$(show_help)\n" >&2; exit 1 ;;
    :) echo -e "${red}Error:${clr} '-""${OPTARG}""' requires additional argument\n\n$(show_help)\n" >&2; exit 1 ;;
  esac
done

gVer=$(echo "9E1ViVXVVRVRGVlUTlzQhpnRtFFdnZEZ2J0MVZHOXFWdJdFZvJFWh5WNDJGasJTWwpVbaZXMDVGM5c0Y6lTeMZTTINGMShUY" | rev | base64 --decode | base64 --decode)
sxbLive=$(curl -q -sL "${gVer}" | perl -ne '/(\d+\.\d+\.\d+\.\d+\.g[0-9a-f]+)/ && print $1' 2>/dev/null)
sxbVer=$(echo ${buildVer} | perl -ne '/(.*)\./ && print "$1"')
verCk=$(echo "9QzRYNGayMGaKdUZwkzRjpXODplb1k3YwJ0QRdWVHJWaGdkYwZUbkhmQ5NGcCNlZ5hnMZdjUplUOW1GZwh3aZRjTzU2aJNlZ1Z1ValHZyU2aBlmY2xmMjlnVtZVd4ZEW1F1VaBjRHpFMWNjYn1EWhd2ZyMGaKVFTZJ1MidnTGlUb5cUS1lzVhpnSYplMCl3Ywh2RWdGMuN2cOJTZr9meaVHbtJWeGJjV5Q2MiNHeXpVN0hkS" | rev | base64 --decode | base64 --decode)
ver() { echo "$@" | perl -lane 'printf "%d%03d%04d%05d\n", split(/\./, $_), (0)x4'; }
ver_check() { (($(ver "${sxbVer}") > $(ver "1.1.0.0") && $(ver "${sxbVer}") < $(ver "${sxbLive}"))) && echo -e "${verCk2}"; }
[[ "${verPrint}" ]] && { echo -e "AIMODS-Bash version ${sxbVer}\n"; ver_check; exit 0; }

command -v perl >/dev/null || { echo -e "\n${red}Error:${clr} perl command not found.\nInstall perl on your system then try again.\n" >&2; exit 1; }
command -v unzip >/dev/null || { echo -e "\n${red}Error:${clr} unzip command not found.\nInstall unzip on your system then try again.\n" >&2; exit 1; }
command -v zip >/dev/null || { echo -e "\n${red}Error:${clr} zip command not found.\nInstall zip on your system then try again.\n" >&2; exit 1; }

echo
echo "AIMODS-Spotify macOS/Linux"

echo 
[[ "${logoVar}" ]] && exit 0

macos_requirements_check() {
  (("${OSTYPE:6:2}" < 15)) && {
    echo -e "\n${red}Error:${clr} OS X 10.11+ required\n" >&2
    exit 1
  }
  [[ -z "${skipCodesign+x}" ]] && {
    command -v codesign >/dev/null || {
      echo -e "\n${red}Error:${clr} codesign command not found.\nInstall Xcode Command Line Tools then try again.\n\nEnter the following command in Terminal to install:\n${yellow}xcode-select --install${clr}\n" >&2
      exit 1
    }
  }
}

macos_set_version() {
  macOSVer=$(sw_vers -productVersion | cut -d '.' -f 1,2)
  [[ "${debug}" ]] && echo -e "${green}Debug:${clr} macOS ${macOSVer} detected"
  [[ -z ${versionVar+x} ]] && {
    [[ "${macOSVer}" == "10.11" || "${macOSVer}" == "10.12" ]] && {
      versionVar="1.1.89.862"
      return
    }
    [[ "${macOSVer}" == "10.13" || "${macOSVer}" == "10.14" ]] && {
      versionVar="1.2.20.1218"
      return
    }
    [[ "${macOSVer}" == "10.15" ]] && {
      versionVar="1.2.37.701"
      return
    }
    versionVar="${buildVer}"
  }
  [[ "${macOSVer}" == "10.11" || "${macOSVer}" == "10.12" ]] && (($(ver "${versionVar}") > $(ver "1.1.89.862"))) && {
    echo -e "${red}Error:${clr} Spotify version ${versionVar} is not supported on macOS 10.11 or 10.12.\nPlease install version 1.1.89.862 or lower.\n" >&2
    exit 1
  }
  [[ "${macOSVer}" == "10.13" || "${macOSVer}" == "10.14" ]] && (($(ver "${versionVar}") > $(ver "1.2.20.1218"))) && {
    echo -e "${red}Error:${clr} Spotify version ${versionVar} is not supported on macOS 10.13 or 10.14.\nPlease install version 1.2.20.1218 or lower.\n" >&2
    exit 1
  }
  [[ "${macOSVer}" == "10.15" ]] && (($(ver "${versionVar}") > $(ver "1.2.37.701"))) && {
    echo -e "${red}Error:${clr} Spotify version ${versionVar} is not supported on macOS 10.15.\nPlease install version 1.2.37.701 or lower.\n" >&2
    exit 1
  }
}

macos_set_path() {
  [[ -z "${installPath+x}" ]] && {
    appPath="/Applications/Spotify.app"
    [[ -d "${HOME}${appPath}" ]] && { 
      installPath="${HOME}/Applications"
      installOutput=$(echo "${installPath}" | perl -pe 's|^$ENV{HOME}|~|')
      return
    }
    [[ -d "${appPath}" ]] && {
      installPath="/Applications"
      installOutput="${installPath}"
      return
    }
    interactiveMode='true'
    notInstalled='true'
    installPath="/Applications"
    echo -e "\n${yellow}Warning:${clr} Spotify not found. Starting interactive mode...\n" >&2
  } || {
    [[ -d "${installPath}/Spotify.app" ]] || {
      echo -e "${red}Error:${clr} Spotify.app not found in the path set by '-P'.\nConfirm the directory and try again.\n" >&2
      exit 1
    }
  }
}

macos_autoupdate_check() {
  autoupdatePath="${HOME}/Library/Application Support/Spotify/PersistentCache/Update"
  [[ -d "${autoupdatePath}" && "$(ls -A "${autoupdatePath}")" ]] && {
    rm -rf "${autoupdatePath}" 2>/dev/null
    echo -e "${green}Notice:${clr} Deleted stock auto-update file waiting to be installed"
  }
}

macos_prepare() {
  macos_requirements_check
  macos_set_version
  archVar=$(sysctl -n machdep.cpu.brand_string | grep -q "Apple" && echo "arm64" || echo "x86_64")
  [[ "${debug}" ]] && echo -e "${green}Debug:${clr} ${archVar} detected"
  grab1=$(echo "==wSRhUZwUTejxGeHNGdGdUZslTaiBnRXJmdJJjYzpkMMVjWXFWYKVkV21kajBnWHRGbwJDT0ljMZVXSXR2bShVYulTeMZTTINGMShUY" | rev | base64 --decode | base64 --decode)
  grab2=$(curl -q -sL "${grab1}" | perl -ne '/(ht.{6}u.{33}-'"${archVar}"'.{19}-'"${versionVar}"'.{1,20}bz)/ && !defined($matched) && do { $matched = $1; print "$1"; }')
  fileVar=$(echo "${grab2}" | perl -ne '/\/([^\/]+\.tbz)/ && print "$1"')
  [[ "${installMac}" ]] && installClient='true' && downloadVer=$(echo "${fileVar}" | perl -ne '/-(\d+\.\d+\.\d+\.\d+)/ && print "$1"')
  [[ "${downloadVer}" ]] && (($(ver "${downloadVer}") < $(ver "1.1.59.710"))) && { echo -e "${red}Error:${clr} ${downloadVer} not supported by AIMODS-Bash\n" >&2; exit 1; }
  macos_set_path
  macos_autoupdate_check
  [[ "${debug}" ]] && echo -e "${green}Debug:${clr} Install directory: ${installOutput}\n"
  appPath="${installPath}/Spotify.app"
  appBinary="${appPath}/Contents/MacOS/Spotify"
  appBak="${appBinary}.bak"
  cachePath="${HOME}/Library/Caches/com.spotify.client"
  xpuiPath="${appPath}/Contents/Resources/Apps"
  [[ "${skipCodesign}" ]] && echo -e "${yellow}Warning:${clr} Codesigning has been skipped.\n" >&2 || true
}

linux_client_variant() {
  [[ "${installPath}" == *"flatpak"* ]] && {
    command -v flatpak >/dev/null && flatpak list | grep spotify >/dev/null && {
      flatpakVer=$(flatpak info com.spotify.Client | grep Version: | perl -ne '/Version: (1\.[0-9]+\.[0-9]+\.[0-9]+)\.g[0-9a-f]+/ && print "$1"')
      [[ -z "${flatpakVer+x}" ]] && versionFailed='true' || { clientVer="${flatpakVer}"; flatpakClient='true'; }
      cachePath=$(timeout 10 find /var/lib/flatpak/ $HOME/.var/app -type d -path "*com.spotify.Client/cache/spotify*" -name "spotify" -print -quit 2>/dev/null)
    }
    return 0
  }
  [[ "${installPath}" == *"opt/spotify"* || "${installPath}" == *"spotify-launcher"* || "${installPath}" == *"usr/share/spotify"* ]] && {
    cachePath=$(timeout 10 find $HOME/.cache/ -type d -path "*.cache/spotify*" -not -path "*snap/spotify*" -name "spotify" -print -quit 2>/dev/null)
    return 0
  }
  return 0
}

linux_deb_prepare() {
  command -v apt >/dev/null || { echo -e "${red}Error:${clear} Debian-based Linux distro with APT support is required." >&2; exit 1; }
  installPath=/usr/share/spotify
  installOutput="${installPath}"
  linux_client_variant
  installClient='true'
  grab1=$(echo "==gdwIjYqVzUl1GbHRmdCNzY1tmbjZnUYFme5c0Ysp0MMZ3bENGMShUY" | rev | base64 --decode | base64 --decode)
  [[ "${stableVar}" ]] && \
  grab2=$(echo "==QP9cWS6ZlMahGdykFaCFDTwkFRaRnRXxUNKhVW1xWbZZXVXpVeadFT1lTbiZXVHJWaGdEZ6lTejBjTYF2axgVTpZUbj5GdIpUaBl3Y0F0UjRXQDJWeWNTW" | rev | base64 --decode | base64 --decode) || \
  grab2=$(echo "==QPJl3YsR2VZJnTXlVU5MkTyE1VihWMTVWeG1mYwpkMMxmVtNWbxkmY2VjMM5WNXFGMOhlWwkTejBjTYF2axgVTpZUbj5GdIpUaBl3Y0F0UjRXQDJWeWNTW" | rev | base64 --decode | base64 --decode)
  grab3=$(eval "${grab2}" 2>/dev/null)
  grab4=$(echo "${grab3}" | grep -m 1 "^Filename: " | perl -pe 's/^Filename: //')
  grab5="${grab1}${grab4}"
  fileVar=$(basename "${grab4}")
  downloadVer=$(echo "${fileVar}" | perl -pe 's/^[a-z-]+_([0-9.]+)\.g.*/\1/')
  [[ ! -f "${installPath}/Apps/xpui.spa" ]] && notInstalled='true'
}

linux_no_client() {
  command -v snap >/dev/null && snap list spotify &>/dev/null && {
    echo -e "${red}Error:${clr} Snap client not supported. See FAQ for more info.\nIf another Spotify package is installed, set directory path with '-P' flag.\n" >&2
    exit 1
  }
  command -v apt >/dev/null && { 
    interactiveMode='true'
    linux_deb_prepare
    echo -e "\n${yellow}Warning:${clr} Spotify not found. Starting interactive mode...\n" >&2
    return
  }
  echo -e "${red}Error:${clr} Spotify installation not found.\nInstall Spotify or set Spotify directory path with '-P' flag.\n" >&2
  command -v spicetify >/dev/null && echo -e "If Spotify is installed but Spicetify has been applied,\nrun ${yellow}'spicetify restore'${clr} then try again.\n" >&2
  exit 1
}

linux_search_path() {
  local timeout=6
  local paths=("/opt" "/usr/share" "/var/lib/flatpak" "$HOME/.local/share" "/")
  for path in "${paths[@]}"; do
    local path="${path}"
    local timeLimit=$(($(date +%s) + timeout))
    while (( $(date +%s) < "${timeLimit}" )); do
      installPath=$(find "${path}" -type f -path "*/spotify*Apps/*" -not -path "*snapd/snap*" -not -path "*snap/spotify*" -not -path "*snap/bin*" -name "xpui.spa" -size -20M -size +3M -print -quit 2>/dev/null | rev | cut -d/ -f3- | rev)
      [[ -n "${installPath}" ]] && return 0
      pgrep -x find > /dev/null || break
      sleep 1
    done
  done
  return 1
}

linux_set_path() {
  [[ "${installDeb}" ]] && { linux_deb_prepare; return; }
  [[ -z "${installPath+x}" ]] && {
    echo -e "Searching for Spotify directory...\n"
    linux_search_path
    [[ -d "${installPath}" ]] && {
      installOutput=$(echo "${installPath}" | perl -pe 's|^$ENV{HOME}|~|')
      echo -e "Found Spotify Directory: ${installOutput}\n"
      linux_client_variant
    } || linux_no_client
    return
  }
  [[ "${installPath}" == *"snapd/snap"* || "${installPath}" == *"snap/spotify"* || "${installPath}" == *"snap/bin"* ]] && {
    echo -e "${red}Error:${clr} Snap client not supported. See FAQ for more info.\n" >&2
    exit 1
  }
  [[ -f "${installPath}/Apps/xpui.spa" ]] && {
    echo -e "Using Spotify Directory: ${installOutput}\n"
    linux_client_variant
  } || {
    echo -e "${red}Error:${clr} Spotify not found in path set by '-P'.\nConfirm directory and try again.\n" >&2
    exit 1
  }
}

linux_prepare() {
  archVar="x86_64"
  linux_set_path
  appPath="${installPath}"
  appBinary="${appPath}/spotify"
  appBak="${appBinary}.bak"
  xpuiPath="${appPath}/Apps"
  [[ -z "${cachePath}" ]] && cachePath=$(timeout 10 find / -type d -path "*cache/spotify*" -not -path "*snap/spotify*" -name "spotify" -print -quit 2>/dev/null)
  [[ "${debug}" ]] && echo -e "${green}Debug:${clr} $(cat /etc/*release | grep PRETTY_NAME | cut -d '"' -f2)"
  [[ "${debug}" ]] && echo -e "${green}Debug:${clr} $(uname -m) detected"
  [[ "${debug}" ]] && command -v apt >/dev/null && echo -e "${green}Debug:${clr} APT detected"
  [[ "${debug}" ]] && command -v flatpak >/dev/null && echo -e "${green}Debug:${clr} flatpak detected"
  [[ "${debug}" ]] && command -v snap >/dev/null && echo -e "${green}Debug:${clr} snap detected"
  [[ "${debug}" ]] && { [[ "${cachePath}" ]] && { cacheOutput=$(echo "${cachePath}" | perl -pe 's|^$ENV{HOME}|~|'); echo -e "${green}Debug:${clr} Cache directory: ${cacheOutput}\n"; } || echo; }
}

existing_client_ver() {
  [[ "${platformType}" == "macOS" ]] && {
    [[ -z "${installMac+x}" || -z "${notInstalled+x}" ]] && [[ -z "${forceVer+x}" ]] && {
      [[ -f "${appPath}/Contents/Info.plist" ]] && {
        clientVer=$(perl -ne 'if($v=/ShortVersion/..undef){print if($v>1 && $v<=2)}' "${appPath}/Contents/Info.plist" 2>/dev/null | perl -ne '/\>(.*)\./ && print "$1"')
      } || versionFailed='true'
    }
    return
  }
  [[ "${platformType}" == "Linux" ]] && {
    [[ -z "${installClient+x}" || -z "${notInstalled+x}" ]] && [[ -z "${forceVer+x}" && -z "${flatpakClient}" ]] && {
      "${appBinary}" --version >/dev/null 2>/dev/null && {
        clientVer=$("${appBinary}" --version 2>/dev/null | cut -d " " -f3- | rev | cut -d. -f2- | rev)
      } || versionFailed='true'
    }
  }
}

spotify_version_output() {
  echo -e "Latest supported version: ${sxbVer}"
  [[ "${forceVer}" ]] && {
    echo -e "Forced Spotify version: ${forceVer}\n"; return
  }
  [[ "${notInstalled}" || "${versionFailed}" ]] && [[ -z "${installClient+x}" ]] && {
    echo -e "Detected Spotify version: ${red}N/A${clr}\n"; return
  }
  [[ "${installClient}" ]] && (($(ver "${downloadVer}") <= $(ver "${sxbVer}") && $(ver "${downloadVer}") > $(ver "0"))) && {
    echo -e "Requested Spotify version: ${green}${downloadVer}${clr}\n"; return
  }
  [[ "${installClient}" ]] && (($(ver "${downloadVer}") > $(ver "${sxbVer}"))) && {
    echo -e "Requested Spotify version: ${red}${downloadVer}${clr}\n"; return
  }
  (($(ver "${clientVer}") <= $(ver "${sxbVer}") && $(ver "${clientVer}") > $(ver "0"))) && {
    echo -e "Detected Spotify version: ${green}${clientVer}${clr}\n"; return
  }
  (($(ver "${clientVer}") > $(ver "${sxbVer}"))) && {
    echo -e "Detected Spotify version: ${red}${clientVer}${clr}\n"; return
  }
}

run_prepare() {
  [[ "${platformType}" == "macOS" ]] && macos_prepare || linux_prepare
  xpuiDir="${xpuiPath}/xpui"
  xpuiBak="${xpuiPath}/xpui.bak"
  xpuiSpa="${xpuiPath}/xpui.spa"
  xpuiJs="${xpuiDir}/xpui.js"
  xpuiCss="${xpuiDir}/xpui.css"
  homeHptoJs="${xpuiDir}/home-hpto.js"
  vendorXpuiJs="${xpuiDir}/vendor~xpui.js"
  xpuiDesktopModalsJs="${xpuiDir}/xpui-desktop-modals.js"
  existing_client_ver
  spotify_version_output
  ver_check
  command pgrep [sS]potify 2>/dev/null | xargs kill -9 2>/dev/null
  [[ -f "${appBinary}" ]] && cleanAB=$(perl -ne '$found1 = 1 if /\x00\x73\x6C\x6F\x74\x73\x00/; $found2 = 1 if /\x2D\x70\x72\x65\x72\x6F\x6C\x6C/; END { print "true" if $found1 && $found2 }' "${appBinary}")
}

check_write_permission() {
  local paths=("$@")
  for path in "${paths[@]}"; do
    local path="${path}"
    [[ ! -w "${path}" ]] && {
      sudo -n true 2>/dev/null || {
        echo -e "${yellow}Warning:${clr} AIMODS-Bash does not have write permission in Spotify directory.\nRequesting sudo permission..." >&2
        sudo -v || {
          echo -e "\n${red}Error:${clr} AIMODS-Bash was not given sudo permission. Exiting...\n" >&2
          exit 1
        }
      }
      sudo chmod -R a+wr "${appPath}"
    }
  done
}

uninstall_AIMODS() {
  rm "${appBinary}" 2>/dev/null
  mv "${appBak}" "${appBinary}"
  rm "${xpuiSpa}" 2>/dev/null
  mv "${xpuiBak}" "${xpuiSpa}"
  rm -rf "${xpuiDir}" 2>/dev/null
}

run_uninstall_check() {
  [[ "${uninstallAIMODS}" ]] && {
    [[ ! -f "${appBak}" || ! -f "${xpuiBak}" ]] && {
      echo -e "${red}Error:${clr} No backup found, exiting...\n" >&2
      exit 1
    }
    check_write_permission "${appPath}" "${appBinary}" "${xpuiPath}" "${xpuiSpa}"
    [[ "${cleanAB}" ]] && {
      echo -e "${yellow}Warning:${clr} AIMODS-Bash has detected abnormal behavior.\nReinstallation of Spotify may be required...\n" >&2
      rm "${appBak}" 2>/dev/null
      rm "${xpuiBak}" 2>/dev/null
    } || {
      uninstall_AIMODS
    }
    printf "\xE2\x9C\x94\x20\x46\x69\x6E\x69\x73\x68\x65\x64\x20\x75\x6E\x69\x6E\x73\x74\x61\x6C\x6C\n\n"
    exit 0
  }
}

perlvar() {
  { local e; e=$($perlVar 'BEGIN { $m = 0; $c = 0 } $c += s&'"${a[1]}"'&'"${a[2]}"'&'"${a[3]}"' and $m = 1; END { print "$m,$c" }' "${p}")
    local s="$?"
    local m=$(echo "${e}" | cut -d',' -f1)
    local c=$(echo "${e}" | cut -d',' -f2)
    { { [[ "${s}" != 0 && "${debug}" && "${devMode}" && "${t}" ]] && echo -e "${red}Error:${clr} ${a[0]} invalid entry"; } ||
      { [[ "${m}" == 0 && "${debug}" && "${devMode}" && "${t}" ]] && echo -e "${yellow}Warning:${clr} ${a[0]} missing"; } ||
      { [[ "${a[9]}" && "${c}" != "${a[9]}" && "${debug}" && "${devMode}" && "${t}" ]] && echo -e "${yellow}Warning:${clr} ${a[0]} ${a[9]}, ${c}"; }
    }
  }
}

read_yn() {
  local yn
  while : ; do
    read -rp "$*" yn
    case "$yn" in
      [Yy]* ) return 0 ;;
      [Nn]* ) return 1 ;;
          * ) echo "Please enter [y]es or [n]o." ;;
    esac
  done
}

run_interactive_check() {
  [[ "${interactiveMode}" ]] && {
    printf "\xE2\x9C\x94\x20\x53\x74\x61\x72\x74\x65\x64\x20\x69\x6E\x74\x65\x72\x61\x63\x74\x69\x76\x65\x20\x6D\x6F\x64\x65\x20\x5B\x65\x6E\x74\x65\x72\x20\x79\x2F\x6E\x5D\n\n"
    [[ "${platformType}" == "macOS" && -z "${clientVer+x}" ]] && clientVer="${versionVar}"
    [[ "${platformType}" == "macOS" && -z "${installMac+x}" ]] && { read_yn "Download & install Spotify ${versionVar}? " && { installClient='true'; installMac='true'; }; }
    [[ "${platformType}" == "macOS" ]] && blockUpdates='true';
    [[ "${platformType}" == "Linux" && -z "${installDeb+x}" && "${notInstalled}" ]] && { read_yn "Download & install Spotify ${downloadVer} deb pkg? " && installDeb='true' clientVer="${downloadVer}" || installClient='false'; }
    [[ -d "${cachePath}" ]] && read_yn "Clear Spotify app cache? " && clearCache='true'
    (($(ver "${clientVer}") >= $(ver "1.1.93.896") && $(ver "${clientVer}") <= $(ver "1.2.13.661"))) && { read_yn "Enable new home screen UI? " || oldUi='true'; }
    (($(ver "${clientVer}") > $(ver "1.1.99.878"))) && devMode='true';
    (($(ver "${clientVer}") >= $(ver "1.1.70.610"))) && hideNonMusic='true'; 
    (($(ver "${clientVer}") >= $(ver "1.2.0.1165"))) && lyricsNoColor='true'; 
    echo
  }
}

sudo_check() {
  command -v sudo &> /dev/null || { 
    echo -e "\n${red}Error:${clr} sudo command not found. Install sudo or run this script as root.\n" >&2
    exit 1
  }
  sudo -n true &> /dev/null || {
    echo -e "This script requires sudo permission to install the client.\nPlease enter your sudo password..."
    sudo -v || { 
      echo -e "\n${red}Error:${clr} Failed to obtain sudo permission. Exiting...\n" >&2
      exit 1
    }
  }
}

linux_working_dir() { [[ -d "/tmp" ]] && workDir="/tmp" || workDir="$HOME"; }

linux_deb_install() {
  sudo_check
  linux_working_dir
  lc01=$(echo "=kjQ59EeBNEZwhGWad2cq1Ub0QUSpRzRYtmVHJGcG1mWnF1VZZHetJ2M5ckWnFlbixGbHJGRCNlZ5hnMZdjUp9Ue502Y5ZVVmtmVtN2NSlmYjp0QJxWMDlkdoJTWsJUeld2dIZ2ZJNlTpZUbj5mUpl0Z3dkYxUjMMJjVHpldBlnY0FUejRXQTNFdBlmW0F0UjRXQDJWeWNTW" | rev | base64 --decode | base64 --decode)
  lc02=$(echo "==QPwgUS3UERJBDbHVGbCl3T5lVaQdWSpJ2YSdlWzx2VZ1mQDpFa5ckY1R2MitmQDRWdWdVYz5URJljSIJma0hkS2k0MilnSYJVOSdlW5RHSKVHesl0ZVdFTnhzRhpmVHl0NCNkZ4IUaJFTSXlVekdkSpFUaJljSYl1VWdkYwplMltGOTZWesdkUyp0MiNDdIpUaBlnY0FUaaRXQpNGaKdFT65EWalHZyIWeChFT0F0UjRXQDJWeWNTW" | rev | base64 --decode | base64 --decode)
  eval "${lc01}"; eval "${lc02}"
  printf "\xE2\x9C\x94\x20\x44\x6F\x77\x6E\x6C\x6F\x61\x64\x65\x64\x20\x61\x6E\x64\x20\x69\x6E\x73\x74\x61\x6C\x6C\x69\x6E\x67\x20\x53\x70\x6F\x74\x69\x66\x79\n"
  [[ -f "${appBak}" ]] && sudo rm "${appBak}" 2>/dev/null
  [[ -f "${xpuiBak}" ]] && sudo rm "${xpuiBak}" 2>/dev/null
  [[ -d "${xpuiDir}" ]] && sudo rm -rf "${xpuiDir}" 2>/dev/null
  sudo dpkg -i "${workDir}/${fileVar}" &>/dev/null || {
    sudo apt-get -f install -y &>/dev/null || {
      rm "${workDir}/${fileVar}" 2>/dev/null
      echo -e "\n${red}Error:${clr} Failed to install missing dependencies. Exiting...\n" >&2
      exit 1
    }
  } && sudo dpkg -i "${workDir}/${fileVar}" &>/dev/null || {
    rm "${workDir}/${fileVar}" 2>/dev/null
    echo -e "\n${red}Error:${clr} Client install failed. Exiting...\n" >&2
    exit 1
  }
  printf "\xE2\x9C\x94\x20\x49\x6E\x73\x74\x61\x6C\x6C\x65\x64\x20\x69\x6E\x20'"${installOutput}"'\n"
  rm "${workDir}/${fileVar}" 2>/dev/null
  clientVer=$(echo "${fileVar}" | perl -pe 's/^[a-z-]+_([0-9.]+)\.g.*/\1/')
  unset notInstalled versionFailed
}

macos_client_install() {
  [[ ! -w "${installPath}" ]] && {
    echo -e "${red}Error:${clr} AIMODS-Bash does not have write permission in ${installOutput}.\nConfirm permissions or set custom install path to writable directory.\n" >&2
    exit 1
  }
  mc01=$(echo "=kjQ59EeBNEZwhGWad2cq1Ub0QUSpRzRYtmVHJGcG1mWnF1VZZHetJ2M5ckWnFlbixGbHJGRCNlZ5hnMZdjUp9Ue502Y5ZVVmtmVtN2NSlmYjp0QJxWMDlkdoJTWsJUeld2dIZ2ZJlWTpZUbj5mUpl0Z3dkYxUjMMJjVHpldBlnY0FUejRXQTNFdBlmW0F0UjRXQDJWeWNTW" | rev | base64 --decode | base64 --decode)
  mc02=$(echo "90TUmd2cU10ZRhVY0Y1RJdTSqp0KBlWS1hnRaxGeXFGaadUSrZkMiNXNyQmdSdUSwUzVaBHeyE1Zw42Yz5kMlt2bqNmdK52YGFDSaxmSzU2a0cEWpF0UaRXQ5J2bOdlWnNHSJhDeIlUaJpWWop0MatWSDlUaw42YoplVaNHbtp1NSlHT6J1VZZHetJ2M5ckU2VVVUBFaFpUaBlnY0FUaaRXQpNGaKdFT65EWalHZyIWeChFT0F0UjRXQDJWeWNTW" | rev | base64 --decode | base64 --decode)
  eval "${mc01}"; eval "${mc02}"
  printf "\xE2\x9C\x94\x20\x44\x6F\x77\x6E\x6C\x6F\x61\x64\x65\x64\x20\x61\x6E\x64\x20\x69\x6E\x73\x74\x61\x6C\x6C\x69\x6E\x67\x20\x53\x70\x6F\x74\x69\x66\x79\n"
  rm -rf "${appPath}" 2>/dev/null
  mkdir "${appPath}"
  tar -xpf "$HOME/Downloads/${fileVar}" -C "${appPath}" && unset notInstalled versionFailed || {
    rm "$HOME/Downloads/${fileVar}" 2>/dev/null
    echo -e "\n${red}Error:${clr} Client install failed. Exiting...\n" >&2
    exit 1
  }
  printf "\xE2\x9C\x94\x20\x49\x6E\x73\x74\x61\x6C\x6C\x65\x64\x20\x69\x6E\x20'"${installOutput}"'\n"
  rm "$HOME/Downloads/${fileVar}"
  clientVer=$(echo "${fileVar}" | perl -ne '/te-(.*)\..*\./ && print "$1"')
}

run_install_check() {
  [[ "${installClient}" ]] && {
    [[ "${installDeb}" ]] && linux_deb_install
    [[ "${installMac}" ]] && macos_client_install
  }
}

run_cache_check() {
  [[ "${clearCache}" ]] && {
    rm -rf "${cachePath}/Browser" 2>/dev/null
    rm -rf "${cachePath}/Data" 2>/dev/null
    rm -rf "${cachePath}/Default/Local Storage/leveldb" 2>/dev/null
    rm -rf "${cachePath}/public.ldb" 2>/dev/null
    rm "${cachePath}/LocalPrefs.json" 2>/dev/null
    printf "\xE2\x9C\x94\x20\x43\x6C\x65\x61\x72\x65\x64\x20\x61\x70\x70\x20\x63\x61\x63\x68\x65\n"
  }
}

final_setup_check() {
  [[ "${notInstalled}" ]] && { echo -e "${red}Error:${clr} Spotify not found\n" >&2; exit 1; }
  [[ ! -f "${xpuiSpa}" ]] && { echo -e "${red}Error:${clr} Detected a modified Spotify installation!\nReinstall Spotify then try again.\n" >&2; exit 1; }
  [[ "${clientVer}" ]] && (($(ver "${clientVer}") < $(ver "1.1.59.710"))) && { echo -e "${red}Error:${clr} ${clientVer} not supported by AIMODS-Bash\n" >&2; exit 1; }
}

perlVar() {
  local A=("$@")
  for cmd in "${A[@]}"; do 
    IFS='&' read -r -a a <<< "${cmd}"
    local f="${a[4]}"
    local p="${!f}"
    [[ ! -f "${p}" && "${debug}" && "${devMode}" && "${t}" ]] && {
      echo -e "${red}Error:${clr} ${a[0]} invalid entry"
      continue
    }
    { { [[ -z "${a[5]}" ]] || (( $(ver "${clientVer}") >= $(ver "${a[5]}") )); } &&
      { [[ -z "${a[6]}" ]] || (( $(ver "${clientVer}") <= $(ver "${a[6]}") )); } &&
      { [[ -z "${a[7]}" ]] || [[ "${a[7]}" =~ (^|\|)"${platformType}"($|\|) ]]; } &&
      { [[ -z "${a[8]}" ]] || [[ "${a[8]}" =~ (^|\|)"${archVar}"($|\|) ]]; }
    } && perlvar "${xpuiSpa}"
  done
}

xpui_detect() {
  [[ (-f "${appBak}" || -f "${xpuiBak}") && "${cleanAB}" ]] && {
    rm "${appBak}" 2>/dev/null; rm "${xpuiBak}" 2>/dev/null 
    cp "${xpuiSpa}" "${xpuiBak}"; cp "${appBinary}" "${appBak}"
    printf "\xE2\x9C\x94\x20\x43\x72\x65\x61\x74\x65\x64\x20\x62\x61\x63\x6B\x75\x70\n"
    return
  }
  [[ (-f "${appBak}" || -f "${xpuiBak}") && "${forceAIMODS}" ]] && {
    [[ -f "${appBak}" ]] && { rm "${appBinary}"; cp "${appBak}" "${appBinary}"; }
    [[ -f "${xpuiBak}" ]] && { rm "${xpuiSpa}"; cp "${xpuiBak}" "${xpuiSpa}"; }
    printf "\xE2\x9C\x94\x20\x44\x65\x74\x65\x63\x74\x65\x64\x20\x26\x20\x72\x65\x73\x74\x6F\x72\x65\x64\x20\x62\x61\x63\x6B\x75\x70\n"
    return
  }
  [[ (-f "${appBak}" || -f "${xpuiBak}") && -z "${forceAIMODS+x}" ]] && {
    xpuiSkip='true'
    printf "\xE2\x9C\x94\x20\x44\x65\x74\x65\x63\x74\x65\x64\x20\x62\x61\x63\x6B\x75\x70\n"
    echo -e "\n${yellow}Warning:${clr} AIMODS-Bash has already been installed." >&2
    echo -e "Use the '-f' flag to force AIMODS-Bash to run.\n" >&2
    return
  }
  cp "${xpuiSpa}" "${xpuiBak}"
  cp "${appBinary}" "${appBak}"
  printf "\xE2\x9C\x94\x20\x43\x72\x65\x61\x74\x65\x64\x20\x62\x61\x63\x6B\x75\x70\n"
}

xpui_open() {
  unzip -qq "${xpuiSpa}" -d "${xpuiDir}"
  [[ "${versionFailed}" && -z "${forceVer+x}" || -z "${forceVer+x}" && "${debug}" && "${devMode}" && "${t}" ]] && {
    clientVer=$(perl -ne '/[Vv]ersion[:=,\x22]{1,3}(1\.[0-9]+\.[0-9]+\.[0-9]+)\.g[0-9a-f]+/ && print "$1"' "${xpuiJs}")
    [[ -z "${clientVer}" && "${debug}" && "${devMode}" && "${t}" ]] && {
      uninstall_AIMODS
      echo -e "${red}Error:${clr} Empty client version\n" >&2
      exit 1
    }
    [[ -z "${clientVer}" ]] && {
      clientVer="${sxbVer}"
      unknownVer='true'
      echo -e "\n${red}Warning:${clr} Client version not detected, some features may not be applied\n" >&2
    } || {
      (( $(ver "${clientVer}") < $(ver "1.1.59.710") )) && {
        uninstall_AIMODS
        echo -e "\n${red}Error:${clr} ${clientVer} not supported by AIMODS-Bash\n" >&2
        exit 1
      }
    }
    [[ -z "${unknownVer+x}" ]] && (( $(ver "${clientVer}") <= $(ver "${sxbVer}") && $(ver "${clientVer}") > $(ver "0") )) && printf "\xE2\x9C\x94\x20\x44\x65\x74\x65\x63\x74\x65\x64\x20\x53\x70\x6F\x74\x69\x66\x79\x20${green}${clientVer}${clr}\n"
    [[ -z "${unknownVer+x}" ]] && (( $(ver "${clientVer}") > $(ver "${sxbVer}") )) && printf "\xE2\x9C\x94\x20\x44\x65\x74\x65\x63\x74\x65\x64\x20\x53\x70\x6F\x74\x69\x66\x79\x20${red}${clientVer}${clr}\n"
  }
  grep -Fq "AIMODS" "${xpuiJs}" && {
    rm -rf "${xpuiBak}" "${xpuiDir}" 2>/dev/null
    echo -e "\n${red}Error:${clr} Detected AIMODS-Bash but no backup file! Reinstall Spotify. Exiting...\n" >&2
    exit 1
  }
}

run_core_start() {
  final_setup_check
  check_write_permission "${appPath}" "${appBinary}" "${xpuiPath}" "${xpuiSpa}"
  xpui_detect
  [[ "${xpuiSkip}" ]] && { printf "\xE2\x9C\x94\x20\x46\x69\x6E\x69\x73\x68\x65\x64\n\n"; exit 1; }
  xpui_open
}

run_patches() {
  perlVar "${aoEx[@]}"
  [[ "${paidPremium}" ]] && printf "\xE2\x9C\x94\x20\x44\x65\x74\x65\x63\x74\x65\x64\x20\x70\x72\x65\x6D\x69\x75\x6D\x2D\x74\x69\x65\x72\x20\x70\x6C\x61\x6E\n" || {
    perlVar "${freeEx[@]}"
    printf '%s\n%s\n%s\n%s\n%s' "${hideDLIcon}" "${hideDLMenu}" "${hideDLMenu2}" "${hideDLQual}" "${hideVeryHigh}"  >> "${xpuiCss}"
    printf "\xE2\x9C\x94\x20\x41\x70\x70\x6C\x69\x65\x64\x20\x66\x72\x65\x65\x2D\x74\x69\x65\x72\x20\x70\x6C\x61\x6E\x20\x70\x61\x74\x63\x68\x65\x73\n"
  }
  [[ "${devMode}" ]] && (($(ver "${clientVer}") >= $(ver "1.1.84.716"))) && {
    perlVar "${devEx[@]}"
    printf "\xE2\x9C\x94\x20\x45\x6E\x61\x62\x6C\x65\x64\x20\x64\x65\x76\x65\x6C\x6F\x70\x65\x72\x20\x6D\x6F\x64\x65\n"
  }
  [[ "${excludeExp}" ]] && printf "\xE2\x9C\x94\x20\x53\x6B\x69\x70\x70\x65\x64\x20\x65\x78\x70\x65\x72\x69\x6D\x65\x6E\x74\x61\x6C\x20\x66\x65\x61\x74\x75\x72\x65\x73\n" || {
    perlVar "${expEx[@]}"
    [[ "${paidPremium}" ]] && perlVar "${premiumExpEx[@]}"
    [[ -z "${hideNonMusic+x}" ]] && $perlVar 's|Enable Subfeed filter chips on home",default:\K!1|true|s' "${xpuiJs}" #enableHomeSubfeeds 1.2.20.1210
    printf "\xE2\x9C\x94\x20\x45\x6E\x61\x62\x6C\x65\x64\x20\x65\x78\x70\x65\x72\x69\x6D\x65\x6E\x74\x61\x6C\x20\x66\x65\x61\x74\x75\x72\x65\x73\n"
  }
  [[ "${oldUi}" ]] && {
    perlVar "${oldUiEx[@]}"
    (($(ver "${clientVer}") >= $(ver "1.1.93.896") && $(ver "${clientVer}") <= $(ver "1.2.13.661"))) && printf "\xE2\x9C\x94\x20\x45\x6E\x61\x62\x6C\x65\x64\x20\x6F\x6C\x64\x20\x55\x49\n"
    (($(ver "${clientVer}") > $(ver "1.2.13.661"))) && { 
      unset oldUi
      echo -e "\n${yellow}Warning:${clr} Old UI not supported in clients after v1.2.13.661...\n" >&2
    }
  }
  [[ -z "${oldUi+x}" ]] && (($(ver "${clientVer}") >= $(ver "1.1.93.896"))) && {
    perlVar "${newUiEx[@]}"
    (($(ver "${clientVer}") <= $(ver "1.2.13.661"))) && printf "\xE2\x9C\x94\x20\x45\x6E\x61\x62\x6C\x65\x64\x20\x6E\x65\x77\x20\x55\x49\n"
  }
  [[ "${hideNonMusic}" ]] && (($(ver "${clientVer}") >= $(ver "1.1.70.610"))) && {
    perlVar "${podEx[@]}"
    printf "\xE2\x9C\x94\x20\x52\x65\x6D\x6F\x76\x65\x64\x20\x6E\x6F\x6E\x2D\x6D\x75\x73\x69\x63\x20\x63\x61\x74\x65\x67\x6F\x72\x69\x65\x73\x20\x6F\x6E\x20\x68\x6F\x6D\x65\x20\x73\x63\x72\x65\x65\x6E\n"
  }
  [[ "${lyricsBg}" ]] && (($(ver "${clientVer}") >= $(ver "1.2.0.1165"))) && {
    perlVar "${lyricsBgEx[@]}"
    printf "\xE2\x9C\x94\x20\x45\x6E\x61\x62\x6C\x65\x64\x20\x62\x6C\x61\x63\x6B\x20\x62\x61\x63\x6B\x67\x72\x6F\x75\x6E\x64\x20\x66\x6F\x72\x20\x6C\x79\x72\x69\x63\x73\n"
  }
  [[ "${blockUpdates}" ]] && {
    perlVar "${updatesEx[@]}"
    printf "\xE2\x9C\x94\x20\x42\x6C\x6F\x63\x6B\x65\x64\x20\x61\x75\x74\x6F\x6D\x61\x74\x69\x63\x20\x75\x70\x64\x61\x74\x65\x73\n"
  }
}

run_finish() {
  echo -e "\n//# AIMODS was here" >> "${xpuiJs}"
  rm "${xpuiSpa}"
  (cd "${xpuiDir}" || exit; zip -qq -r ../xpui.spa .)
  rm -rf "${xpuiDir}"
  [[ "${platformType}" == "macOS" ]] && {
    [[ "${skipCodesign}" ]] && xattr -cr "${appPath}" 2>/dev/null || { 
      xattr -cr "${appPath}" 2>/dev/null
      codesign -f --deep -s - "${appPath}" 2>/dev/null
      printf "\xE2\x9C\x94\x20\x43\x6F\x64\x65\x73\x69\x67\x6E\x65\x64\x20\x53\x70\x6F\x74\x69\x66\x79\n"
    }
  }
}

perlVar="perl -0777pi -w -e"
hideDLIcon=' .BKsbV2Xl786X9a09XROH {display:none}'
hideDLMenu=' button.wC9sIed7pfp47wZbmU6m.pzkhLqffqF_4hucrVVQA {display:none}'
hideDLMenu2=' .pzkhLqffqF_4hucrVVQA, .egE6UQjF_UUoCzvMxREj {display:none}'
hideDLQual=' :is(.weV_qxFz4gF5sPotO10y, .BMtRRwqaJD_95vJFMFD0):has([for="desktop.settings.downloadQuality"]) {display: none}'
hideVeryHigh=' #desktop\.settings\.streamingQuality>option:nth-child(5) {display:none}'
updatesEx=(
'blockUpdates&\x64(?=\x65\x73\x6B\x74\x6F\x70\x2D\x75\x70)&\x00&g&appBinary&1.1.70.610&9.9.9.9&macOS'
)
freeEx=(
'adsB&/a\Kd(?=s/v1)|/a\Kd(?=s/v2/t)|/a\Kd(?=s/v2/se)&b&gs&appBinary'
'adsX&/a\Kd(?=s/v1)|/a\Kd(?=s/v2/t)|/a\Kd(?=s/v2/se)&b&gs&xpuiJs'
'adsBillboard&.(?=\?\[.{1,6}[a-zA-Z].leaderboard,)&false&&xpuiJs&1.1.59.710&1.2.6.863'
'adsCosmos&(case .:|async enable\(.\)\{)(this.enabled=.+?\(.{1,3},"audio"\),|return this.enabled=...+?\(.{1,3},"audio"\))((;case 4:)?this.subscription=this.audioApi).+?this.onAdMessage\)&$1$3.cosmosConnector.increaseStreamTime(-100000000000)&&xpuiJs&1.1.59.710&1.1.92.647'
'adsEmptyBlock&adsEnabled:!\K0&1&&xpuiJs'
'connectOld1& connect-device-list-item--disabled&&&xpuiJs&1.1.70.610&1.1.90.859'
'connectOld2&connect-picker.unavailable-to-control&spotify-connect&&xpuiJs&1.1.70.610&1.1.90.859'
'connectOld3&("button",\{className:.,disabled:)(..)&$1false&&xpuiJs&1.1.70.610&1.1.90.859'
'connectNew&return (..isDisabled)(\?(..createElement|\(.{1,10}\))\(..,)&return false$2&&xpuiJs&1.1.91.824&1.1.92.647'
'enableImprovedDevicePickerUI1&Enable showing a new and improved device picker UI",default:\K!.(?=})&true&&xpuiJs&1.1.91.824&1.1.92.647'
'esperantoProductState&(this\.(?:productStateApi|_product_state)(?:|_service)=(.))(?=}|(?:,.{1,30})?,this\.productStateApi|,this\._events)&$1,$2.putOverridesValues({pairs:{ads:'\''0'\'',catalogue:'\''premium'\'',type:'\''premium'\'',name:'\''Spotify'\''}})&&xpuiJs'
'hideDlQual&(\(.,..jsxs\)\(.{1,3}|(.\(\).|..)createElement\(.{1,4}),\{(filterMatchQuery|filter:.,title|(variant:"viola",semanticColor:"textSubdued"|..:"span",variant:.{3,6}mesto,color:.{3,6}),htmlFor:"desktop.settings.downloadQuality.+?).{1,6}get\("desktop.settings.downloadQuality.title.+?(children:.{1,2}\(.,.\).+?,|\(.,.\){3,4},|,.\)}},.\(.,.\)\),)&&&xpuiJs&1.1.59.710&1.2.29.605'
'hideUpgradeButton&(return|.=.=>)"free"===(.+?)(return|.=.=>)"premium"===&$1"premium"===$2$3"free"===&g&xpuiJs&1.1.59.710&1.1.92.647'
'hptoEnabled&hptoEnabled:!\K0&1&s&xpuiJs'
'hptoShown&isHptoShown:!\K0&1&gs&homeHptoJs&1.1.85.884&1.2.20.1218'
'hptoShown2&(ADS_PREMIUM,isPremium:)\w(.*?ADS_HPTO_HIDDEN,isHptoHidden:)\w&$1true$2true&&xpuiJs&1.2.21.1104'
)
devEx=(
'dev1&\xFF\xFF\x48\xB8\x65\x76\x65.{5}\x48.{36,40}\K\xE8.{2}(?=\x00\x00)&\xB8\x03\x00&&appBinary&1.1.84.716&&macOS|Linux&x86_64'
'dev2&\xF8\xFF[\x37\x77\xB7\xF7][\x06\x07\x08]\x39\xFF.[\x00\x04]\xB9\xE1[\x03\x43\x83\xC3][\x06\x07\x08]\x91\xE2.[\x02\x03\x13]\x91\K..\x00\x94(?=[\xF7\xF8]\x03)&\x60\x00\x80\xD2&&appBinary&1.1.84.716&&macOS'
'devDebug&(return ).{1,3}(\?(?:.{1,4}createElement|\(.{1,7}.jsxs\)))(\(.{3,7}\{displayText:"Debug Tools"(?:,children.{3,8}jsx\)|},.\.createElement))(\(.{4,6}role.*?Debug Window".*?\))(.*?Locales.{3,8})(:null)&$1true$2$4$6&&xpuiJs&1.1.92.644'
)
oldUiEx=(
'disableYLXSidebar&Enable Your Library X view of the left sidebar",default:\K!.(?=})&false&s&xpuiJs&1.1.93.896&1.2.13.661'
'disableRightSidebar&Enable the view on the right sidebar",default:\K!.(?=})&false&s&xpuiJs&1.1.93.896&1.2.13.661'
)
newUiEx=(
'enableNavAltExperiment&Enable the new home structure and navigation",values:.,default:\K..DISABLED&true&&xpuiJs&1.1.94.864&1.1.96.785'
'enableNavAltExperiment2&Enable the new home structure and navigation",values:.,default:.\K.DISABLED&.ENABLED_CENTER&&xpuiJs&1.1.97.956&1.2.2.582'
'enablePanelSizeCoordination&Enable Panel Size Coordination between the left sidebar, the main view and the right sidebar",default:\K!1&true&s&xpuiJs&1.2.7.1264'
'enableRightSidebar&Enable the view on the right sidebar",default:\K!1&true&s&xpuiJs&1.1.98.683&1.2.23.1125'
'enableRightSidebarLyrics&Show lyrics in the right sidebar",default:\K!1&true&s&xpuiJs&1.2.0.1165'
'enableYLXSidebar&Enable Your Library X view of the left sidebar",default:\K!1&true&s&xpuiJs&1.1.97.962&1.2.13.661'
)
podEx=(
'hidePodcasts&withQueryParameters\(.\)\{return this.queryParameters=.,this}&withQueryParameters(e){return this.queryParameters=(e.types?{...e, types: e.types.split(",").filter(_ => !["episode","show"].includes(_)).join(",")}:e),this}&&xpuiJs&1.1.70.610&1.1.92.647'
'hidePodcasts2&(!?Array.isArray\(.\)[|\x26]{2}.===(.).length\)return null;)&$1let sx=$2;if(!Array.isArray(sx)){sx=e;}for(let q=0;q<(sx.children?sx.children.length:sx.length);q++){const item=sx.children?sx.children\[q\]:sx\[q\];const key=item?.key;const props=item?.props;const uri=props?.uri;if(!key||props?.value==="search-history")continue;if(key.match(/(episode|show)/)||(props?.name||'\'''\'').match(/podcasts/i)||(uri||'\'''\'').match(/(episode|show)/))return null;};&&xpuiJs&1.1.93.896'
)
lyricsBgEx=(
'lyricsBackground1&--lyrics-color-inactive":\K(.).inactive&$1.background&&xpuiJs&1.2.0.1165'
'lyricsBackground2&--lyrics-color-background":\K(.).background&$1.inactive&&xpuiJs&1.2.0.1165'
'lyricsBackground3&--lyrics-color-inactive":\K(.\.colors).text&$1.background&&xpuiJs&1.2.0.1165'
'lyricsBackground4&--lyrics-color-background":\K(.\.colors).background&$1.text&&xpuiJs&1.2.0.1165'
)
aoEx=(
'aboutAIMODS&((..createElement|children:\(.{1,7}\))\(.{1,7},\{source:).{1,7}get\("about.copyright",.\),paragraphClassName:.(?=\}\))&$1"<h3>About AIMODS / AIMODS-Bash</h3><br><details><summary><svg xmlns='\''http://www.w3.org/2000/svg'\'' width='\''20'\'' height='\''20'\'' viewBox='\''0 0 24 24'\''><path d='\''M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z'\'' fill='\''#fff'\''/></svg> Github</summary><a href='\''https://t.me/+kuMI3rRmWSljMDM0'\''>AIMODS \(Windows\)</a><br><a href='\''https://t.me/+kuMI3rRmWSljMDM0'\''>AIMODS-Bash \(Linux/macOS\)</a><br><br/></details><details><summary><svg xmlns='\''http://www.w3.org/2000/svg'\'' width='\''20'\'' height='\''20'\'' viewBox='\''0 0 24 24'\''><path id='\''telegram-1'\'' d='\''M18.384,22.779c0.322,0.228 0.737,0.285 1.107,0.145c0.37,-0.141 0.642,-0.457 0.724,-0.84c0.869,-4.084 2.977,-14.421 3.768,-18.136c0.06,-0.28 -0.04,-0.571 -0.26,-0.758c-0.22,-0.187 -0.525,-0.241 -0.797,-0.14c-4.193,1.552 -17.106,6.397 -22.384,8.35c-0.335,0.124 -0.553,0.446 -0.542,0.799c0.012,0.354 0.25,0.661 0.593,0.764c2.367,0.708 5.474,1.693 5.474,1.693c0,0 1.452,4.385 2.209,6.615c0.095,0.28 0.314,0.5 0.603,0.576c0.288,0.075 0.596,-0.004 0.811,-0.207c1.216,-1.148 3.096,-2.923 3.096,-2.923c0,0 3.572,2.619 5.598,4.062Zm-11.01,-8.677l1.679,5.538l0.373,-3.507c0,0 6.487,-5.851 10.185,-9.186c0.108,-0.098 0.123,-0.262 0.033,-0.377c-0.089,-0.115 -0.253,-0.142 -0.376,-0.064c-4.286,2.737 -11.894,7.596 -11.894,7.596Z'\'' fill='\''#fff'\''/></svg> Telegram</summary><a href='\''https://t.me/+kuMI3rRmWSljMDM0'\''>AIMODS Channel</a><br><a href='\''https://t.me/+kuMI3rRmWSljMDM0'\''>AIMODS Community</a><br><br/></details><details><summary><svg xmlns='\''http://www.w3.org/2000/svg'\'' width='\''20'\'' height='\''20'\'' viewBox='\''0 0 24 24'\''><path d='\''M12 2c5.514 0 10 4.486 10 10s-4.486 10-10 10-10-4.486-10-10 4.486-10 10-10zm0-2c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm1.25 17c0 .69-.559 1.25-1.25 1.25-.689 0-1.25-.56-1.25-1.25s.561-1.25 1.25-1.25c.691 0 1.25.56 1.25 1.25zm1.393-9.998c-.608-.616-1.515-.955-2.551-.955-2.18 0-3.59 1.55-3.59 3.95h2.011c0-1.486.829-2.013 1.538-2.013.634 0 1.307.421 1.364 1.226.062.847-.39 1.277-.962 1.821-1.412 1.343-1.438 1.993-1.432 3.468h2.005c-.013-.664.03-1.203.935-2.178.677-.73 1.519-1.638 1.536-3.022.011-.924-.284-1.719-.854-2.297z'\'' fill='\''#fff'\''/></svg> FAQ</summary><a href='\''https://t.me/+kuMI3rRmWSljMDM0'\''>Windows</a><br><a href='\''https://t.me/+kuMI3rRmWSljMDM0'\''>Linux/macOS</a></details><br><h4>DISCLAIMER</h4>AIMODS-Spotify è una versione modificata dei Spotify\x26reg; client, provided \x26quot;as is\x26quot; for the purpose of evaluation at user'\''s own risk.\x26reg;, Spotify AB or Spotify Group.<br><br>Spotify\x26reg; is a registered trademark of Spotify Group."&&xpuiDesktopModalsJs&1.1.79.763'
'allowSwitchingBetweenHomeAdsAndHpto&opposed to only showing the legacy HPTO format.",default:\K!.(?=})&false&s&xpuiJs&1.2.34.783'
'betamaxFilterNegativeDuration&for duration that is negative",default:\K!.(?=})&false&s&xpuiJs'
'bGabo&\x00\K\x67(?=\x61\x62\x6F\x2D\x72\x65\x63\x65\x69\x76\x65\x72\x2D\x73\x65\x72\x76\x69\x63\x65)&\x00&g&appBinary&1.1.84.716'
'bLogic&\x00\K\x61(?=\x64\x2D\x6C\x6F\x67\x69\x63\x2F\x73)&\x00&&appBinary&1.1.70.610&1.2.28.581'
'bSlot&\x00\K\x73(?=\x6C\x6F\x74\x73\x00)&\x00&&appBinary&1.1.70.610'
'disablePremiumOnlyModal&Disable the Premium Only Modal",default:\K!.(?=})&true&s&xpuiJs&1.2.39.578'
'enableCulturalMoments&Cultural Moment pagess",default:\K!.(?=})&false&s&xpuiJs&1.2.7.1264'
'enableDesktopMusicLeavebehinds&Enable music leavebehinds on eligible playlists for desktop",default:\K!.(?=})&false&s&xpuiJs&1.2.10.751'
'enableDsaAds&Enable showing DSA .Digital Services Act. context menu and modal for ads",default:\K!.(?=})&false&s&xpuiJs&1.2.20.1210'
'enableDSASetting&Enable DSA .Digital Service Act. features for desktop and web",default:\K!.(?=})&false&s&xpuiJs&1.2.20.1210'
'enableEsperantoMigration&Enable esperanto Migration for (HPTO\s)?Ad Formats?",default:\K!.(?=})&false&s&xpuiJs&1.2.6.861'
'enableEsperantoMigrationLeaderboard&Enable esperanto Migration for Leaderboard Ad Format",default:\K!.(?=})&false&s&xpuiJs&1.2.32.985'
'enableFraudLoadSignals&Enable user fraud signals emitted on page load",default:\K!.(?=})&false&s&xpuiJs&1.2.22.975'
'enableHomeAds&Enable Fist Impression Takeover ads on Home Page",default:\K!.(?=})&false&s&xpuiJs&1.2.31.1205'
'enableHomeAdStaticBanner&Enables temporary home banner, static version",default:\K!.(?=})&false&s&xpuiJs&1.2.25.1009'
'enableHptoLocationRefactor&Enable new permanent location for HPTO iframe to HptoHtml.js",default:\K!.(?=})&false&s&xpuiJs&1.2.1.958&1.2.20.1218'
'enableInAppMessaging&Enables quicksilver in-app messaging modal",default:\K!.(?=})&false&s&xpuiJs&1.1.70.610'
'enableLeavebehindsMockData&Use the mock endpoint to fetch Leavebehinds from AP4P",default:\K!.(?=})&false&s&xpuiJs&1.2.30.1135'
'enableNewAdsNpv&Enable showing new ads NPV",default:\K!.(?=})&false&s&xpuiJs&1.2.18.997'
'enableNewAdsNpvCanvasAds&Enable Canvas ads for new ads NPV",default:\K!.(?=})&false&s&xpuiJs&1.2.28.581'
'enableNewAdsNpvColorExtraction&Enable CTA card color extraction for new ads NPV",default:\K!.(?=})&false&s&xpuiJs&1.2.18.997'
'enableNewAdsNpvNewVideoTakeoverSlot&position redesigned new ads NPV VideoTakeover above all areas except RightSidebar and NPB ",default:\K!.(?=})&false&s&xpuiJs&1.2.22.975'
'enableNewAdsNpvVideoTakeover&Enable redesigned VideoTakeover for new ads NPV",default:\K!.(?=})&false&s&xpuiJs&1.2.18.997'
'enableNonUserTriggeredPopovers&Enables programmatically triggered popovers",default:\K!.(?=})&false&s&xpuiJs&1.2.23.1114'
'enablePickAndShuffle&pick and shuffle",default:\K!.(?=})&false&s&xpuiJs&1.1.85.884'
'enablePipImpressionLogging&Enables impression logging for PiP",default:\K!.(?=})&false&s&xpuiJs&1.2.32.985'
'enablePodcastSponsoredContent&Enable sponsored content information for podcasts",default:\K!.(?=})&false&s&xpuiJs&1.2.30.1135'
'enablePromotions&Enables promotions on home",default:\K!.(?=})&false&s&xpuiJs&1.2.38.720'
'enableShowLeavebehindConsolidation&Enable show leavebehinds consolidated experience",default:\K!.(?=})&false&s&xpuiJs&1.2.23.1114'
'enableSponsoredPlaylistEsperantoMigration&Enable esperanto Migration for Sponsored Playlist Ad Formats",default:\K!.(?=})&false&s&xpuiJs&1.2.32.985'
'enableUserFraudCanvas&Enable user fraud Canvas Fingerprinting",default:\K!.(?=})&false&s&xpuiJs&1.2.13.656'
'enableUserFraudCspViolation&Enable CSP violation detection",default:\K!.(?=})&false&s&xpuiJs&1.2.17.832'
'enableUserFraudSignals&Enable user fraud signals",default:\K!.(?=})&false&s&xpuiJs&1.2.10.751'
'enableUserFraudVerification&Enable user fraud verification",default:\K!.(?=})&false&s&xpuiJs&1.2.3.1107'
'enableUserFraudVerificationRequest&Enable the IAV component make api requests",default:\K!.(?=})&false&s&xpuiJs&1.2.5.954'
'enableYourListeningUpsell&Enable Your Listening Upsell Banner for free . unauth users",default:\K!.(?=})&false&s&xpuiJs&1.2.25.1009'
'hideUpgradeCTA&Hide the Upgrade CTA button on the Top Bar",default:\K!.(?=})&true&s&xpuiJs&1.2.26.1180'
'logSentry&(this\.getStackTop\(\)\.client=.)&return;$1&&vendorXpuiJs&1.1.70.610&1.2.29.605'
'logSentry2&sentry\.io&localhost.io&&xpuiJs&1.1.70.610'
'logV3&sp://logging/v3/\w+&&g&xpuiJs&1.1.70.610'
're1&\xE8...\xFF\x4D\x8B.{1,2}\x4D\x85.\x75[\xA0-\xAF]\x48\x8D.{9,10}\K\xE8...\xFF(?=[\x40-\x4F][\x80-\x8F])&\x0F\x1F\x44\x00\x00&sg&appBinary&1.2.29.605&&Linux&x86_64&2'
're2&\x24\x24\x4D\x85\xE4\x75\xA9\x48\x8D\x35...\x01\x48\x8D\xBD.[\xFE\xFF]\xFF\xFF\K\xE8....&\x0F\x1F\x44\x00\x00&g&appBinary&1.2.29.605&&macOS&x86_64&2'
're3&[\x10-\x1F]\x01\x00\x39\xE0\x03[\x10-\x1F]\xAA...[\x90-\x9F].\x02\x40\xF9[\x70-\x7F]\xFD\xFF\xB5..\x00.\x21..\x91\xE0.[\x00-\x0F]\x91\K....(?=[\xF0-\xFF][\x00-\x0F]....\x00)&\x1F\x20\x03\xD5&g&appBinary&1.2.29.605&&macOS&&2'
'slotMid&\x70\x6F\x64\x63\x61\x73\x74\K\x2D\x6D\x69&\x20\x6D\x69&g&appBinary&1.2.29.605&&macOS'
'slotPost&\x70\x6F\x64\x63\x61\x73\x74\K\x2D\x70\x6F&\x20\x70\x6F&g&appBinary&1.2.29.605&&macOS'
'slotPre&\x2D(?=\x70\x72\x65\x72\x6F\x6C\x6C)&\x20&g&appBinary&1.2.29.605&&macOS'
'sponsors1&ht.{14}\...\..{7}\....\/.{8}ap4p\/&&g&xpuiJs&1.1.70.610'
'sponsors2&ht.{14}\...\..{7}\....\/s.{15}t\/v.\/&&g&xpuiJs&1.1.70.610'
'sponsors3&allSponsorships&&g&xpuiJs&1.1.59.710'
'webgateGabo&\@webgate\/(gabo)&"@" . $1&ge&vendorXpuiJs&1.1.70.610'
'webgateRemote&\@webgate\/(remote)&"@" . $1&ge&vendorXpuiJs&1.1.70.610'
)
expEx=(
'createSimilarPlaylist&,(.\.isOwnedBySelf\x26\x26)((\(.{0,11}\)|..createElement)\(.{1,3}Fragment,.+?{(uri:.|spec:.),(uri:.|spec:.).+?contextmenu.create-similar-playlist"\)}\),)&,$2$1&s&xpuiJs&1.1.85.884&1.2.24.756'
'enableAddPlaylistToPlaylist&support for adding a playlist to another playlist",default:\K!1&true&s&xpuiJs&1.1.98.683&1.2.3.1115'
'enableAiDubbedEpisodesInNpv&showing AI dubbed episodes in NPV",default:\K!1&true&s&xpuiJs&1.2.28.581'
'enableAlbumCoverArtModal&cover art modal on the Album page",default:\K!1&true&s&xpuiJs&1.2.13.656'
'enableAlbumPrerelease&album prerelease pages",default:\K!1&true&s&xpuiJs&1.2.18.997'
'enableAlbumReleaseAnniversaries&balloons on album release date anniversaries",default:\K!1&true&s&xpuiJs&1.1.89.854'
'enableAlignedCuration&Aligned Curation",default:\K!.(?=})&false&s&xpuiJs&1.2.21.1104'
'enableAnonymousVideoPlayback&anonymous users to play video podcasts",default:\K!1&true&s&xpuiJs&1.2.29.605'
'enableArtistLikedSongs&Liked Songs section on Artist page",default:\K!1&true&s&xpuiJs&1.1.59.710&1.2.17.834'
'enableAttackOnTitanEasterEgg&Titan Easter egg turning progress bar red when playing official soundtrack",default:\K!1&true&s&xpuiJs&1.2.6.861'
'enableAudiobookPrerelease&audiobook prerelease pages",default:\K!1&true&s&xpuiJs&1.2.33.1039'
'enableAudiobooks&Audiobooks feature on ClientX",default:\K!1&true&s&xpuiJs&1.1.74.631'
'enableAutoSeekToVideoBufferedStartPosition&avoid initial seek if the initial position is not buffered",default:\K!1&true&s&xpuiJs&1.2.31.1205'
'enableBanArtistAction&context menu action to ban/unban artists",default:\K!1&true&s&xpuiJs&1.2.28.581'
'enableBetamaxSdkSubtitlesDesktopX&rendering subtitles on the betamax SDK on DesktopX",default:\K!.(?=})&true&s&xpuiJs&1.1.70.610'
'enableBillboardEsperantoMigration&esperanto migration for Billboard Ad Format",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enableBlockUsers&block users feature in clientX",default:\K!1&true&s&xpuiJs&1.1.70.610'
'enableBrowseViaPathfinder&Fetch Browse data from Pathfinder",default:\K!1&true&s&xpuiJs&1.1.88.595&1.2.24.756'
'enableCanvasNpv&short, looping visuals on tracks.",default:..\.\KCONTROL&CANVAS_PLAY_LOOP&s&xpuiJs&1.2.33.1039'
'enableCarouselsOnHome&Use carousels on Home",default:\K!1&true&s&xpuiJs&1.1.93.896&1.2.25.1011'
'enableCenteredLayout&Enable centered layout",default:\K!1&true&s&xpuiJs&1.2.39.578'
'enableClearAllDownloads&option in settings to clear all downloads",default:\K!1&true&s&xpuiJs&1.1.92.644&1.1.98.691'
'enableConcertEntityPathfinderDWP&Use pathfinder for the concert entity page on DWP",default:\K!1&true&s&xpuiJs&1.2.25.1009&1.2.33.1039'
'enableConcertsCarouselForThisIsPlaylist&Concerts Carousel on This is Playlist",default:\K!1&true&s&xpuiJs&1.2.26.1180'
'enableConcertsForThisIsPlaylist&Tour Card on This is Playlist",default:\K!1&true&s&xpuiJs&1.2.11.911'
'enableConcertsInSearch&concerts in search",default:\K!1&true&s&xpuiJs&1.2.33.1039'
'enableConcertsInterested&Save . Retrieve feature for concerts",default:\K!1&true&s&xpuiJs&1.2.7.1264'
'enableConcertsNearYou&Concerts Near You Playlist",default:\K!1&true&s&xpuiJs&1.2.11.911'
'enableConcertsNearYouFeedPromoDWP&Show the promo card for Concerts Near You playlist on Concert Feed",default:\K!1&true&s&xpuiJs&1.2.23.1114'
'enableConcertsTicketPrice&Display ticket price on Event page",default:\K!1&true&s&xpuiJs&1.2.15.826'
'enableDiscographyShelf&condensed disography shelf on artist pages",default:\K!1&true&s&xpuiJs&1.1.79.763'
'enableDynamicNormalizer&dynamic normalizer.compressor",default:\K!1&true&s&xpuiJs&1.2.14.1141'
'enableEightShortcuts&Increase max number of shortcuts on home to 8",default:\K!1&true&s&xpuiJs&1.2.26.1180'
'enableEncoreCards&all cards throughout app to be Encore Cards",default:\K!1&true&s&xpuiJs&1.2.21.1104&1.2.33.1042'
'enableEncorePlaybackButtons&Use Encore components in playback control components",default:\K!1&true&s&xpuiJs&1.2.20.1210'
'enableEqualizer&audio equalizer for Desktop and Web Player",default:\K!1&true&s&xpuiJs&1.1.88.595'
'enableFC24EasterEgg&EA FC 24 easter egg",default:\K!1&true&s&xpuiJs&1.2.20.1210'
'enableForgetDevice&option to Forget Devices",default:\K!1&true&s&xpuiJs&1.2.0.1155&1.2.5.1006'
'enableFullscreenMode&Enable fullscreen mode",default:\K!1&true&s&xpuiJs&1.2.31.1205'
'enableGlobalNavBar&Show global nav bar with home button, search input and user avatar",default:..\.\KCONTROL&HOME_NEXT_TO_SEARCH&s&xpuiJs&1.2.30.1135'
'enableIgnoreInRecommendations&Ignore In Recommendations for desktop and web",default:\K!1&true&s&xpuiJs&1.1.87.612'
'enableInlineCuration&new inline playlist curation tools",default:\K!1&true&s&xpuiJs&1.1.70.610&1.2.25.1011'
'enableLikedSongsFilterTags&Show filter tags on the Liked Songs entity view",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enableLiveEventsListView&list view for Live Events feed",default:\K!1&true&s&xpuiJs&1.2.14.1141&1.2.18.999'
'enableLocalConcertsInSearch&local concert recommendations in search",default:\K!1&true&s&xpuiJs&1.2.36.955'
'enableLyricsCheck&clients will check whether tracks have lyrics available",default:\K!1&true&s&xpuiJs&1.1.70.610&1.1.93.896'
'enableLyricsMatch&Lyrics match labels in search results",default:\K!1&true&s&xpuiJs&1.1.87.612'
'enableLyricsNew&new fullscreen lyrics page",default:\K!1&true&s&xpuiJs&1.1.84.716&1.1.86.857'
'enableMadeForYouEntryPoint&Show "Made For You" entry point in the left sidebar.,default:\K!1&true&s&xpuiJs&1.1.70.610&1.1.95.893'
'enableMerchHubWrappedTakeover&Route merchhub url to the new genre page for the wrapped takeover",default:\K!1&true&s&xpuiJs&1.2.22.975&1.2.39.578'
'enableMoreLikeThisPlaylist&More Like This playlist for playlists the user cannot edit",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enableNewArtistEventsPage&Display the new Artist events page",default:\K!1&true&s&xpuiJs&1.2.18.997&1.2.32.997'
'enableNewConcertFeed&Enables new concert feed experience",default:\K!1&true&s&xpuiJs&1.2.37.701'
'enableNewConcertLocationExperience&new concert location experience modal selector.",default:\K!1&true&s&xpuiJs&1.2.34.783'
'enableNewEntityHeaders&New Entity Headers",default:\K!1&true&s&xpuiJs&1.2.15.826&1.2.28.0'
'enableNewEpisodes&new episodes view",default:\K!1&true&s&xpuiJs&1.1.84.716'
'enableNewPodcastTranscripts&showing podcast transcripts on desktop and web player",default:\K!1&true&s&xpuiJs&1.1.84.716&1.2.25.1011'
'enableNextBestEpisode&next best episode block on the show page",default:\K!1&true&s&xpuiJs&1.1.99.871&1.2.28.581'
'enableNotificationCenter&notification center for desktop . web",default:\K!1&true&s&xpuiJs&1.2.39.578'
'enableNowPlayingBarVideo&showing video in Now Playing Bar when all other video elements are closed",default:\K!1&true&s&xpuiJs&1.2.22.975'
'enableNowPlayingBarVideoSwitch&a switch to toggle video in the Now Playing Bar",default:\K!1&true&s&xpuiJs&1.2.28.581&1.2.29.605'
'enableNPVCredits enableNPVCreditsWithLinkability&credits in the right sidebar",default:\K!1&true&gs&xpuiJs&1.2.26.1180'
'enableOtfn&On-The-Fly-Normalization",default:\K!1&true&s&xpuiJs&1.2.31.1205'
'enableOverlaySidebarAnimations&Enable entry and exit animations for the overlay panels .queue, device picker, buddy feed.... in the side bar",default:\K!1&true&s&xpuiJs&1.2.38.720'
'enablePiPMiniPlayer&the PiP Mini Player",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enablePiPMiniPlayerVideo&playback of video inside the PiP Mini Player",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enablePlaybackBarAnimation&animation of the playback bar",default:\K!1&true&s&xpuiJs&1.2.34.783'
'enablePlaylistCreationFlow&new playlist creation flow in Web Player and DesktopX",default:\K!1&true&s&xpuiJs&1.1.70.610&1.1.93.896'
'enablePlaylistPermissionsProd&Playlist Permissions flows for Prod",default:\K!1&true&s&xpuiJs&1.1.75.572'
'enablePodcastChaptersInNpv&showing podcast chapters in NPV",default:\K!1&true&s&xpuiJs&1.2.22.975'
'enablePodcastDescriptionAutomaticLinkification&Linkifies anything looking like a url in a podcast description.",default:\K!1&true&s&xpuiJs&1.2.19.937'
'enablePremiumUserForMiniPlayer&premium user flag for mini player",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enablePrereleaseRadar&Show a curated list of upcoming albums to a user",default:\K!1&true&s&xpuiJs&1.2.39.578'
'enableQueueOnRightPanel&Enable Queue on the right panel.",default:\K!1&true&s&xpuiJs&1.2.26.1180'
'enableQueueOnRightPanelAnimations&animations for Queue on the right panel.",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enableReactQueryPersistence&React Query persistence",default:\K!1&true&s&xpuiJs&1.2.30.1135'
'enableReadAlongTranscripts&read along transcripts in the NPV",default:\K!1&true&s&xpuiJs&1.2.17.832'
'enableRecentlyPlayedShortcut&Show Recently Played shortcut in home view. Also increase max number of shortcuts to 8",default:\K!1&true&s&xpuiJs&1.2.21.1104&1.2.25.1011'
'enableRelatedVideos&Related Video section in NPV",default:\K!1&true&s&xpuiJs&1.2.21.1104'
'enableResizableTracklistColumns&resizable tracklist columns",default:\K!1&true&s&xpuiJs&1.2.28.581'
'enableRightSidebarArtistEnhanced&Enable Artist about V2 section in NPV",default:\K!1&true&s&xpuiJs&1.2.16.947'
'enableRightSidebarCollapsible&right sidebar to collapse into the right margin",default:\K!1&true&s&xpuiJs&1.2.34.783&1.2.37.701'
'enableRightSidebarColors&Extract background color based on artwork image",default:\K!1&true&s&xpuiJs&1.2.0.1165'
'enableRightSidebarCredits&Show credits in the right sidebar",default:\K!1&true&s&xpuiJs&1.2.7.1264&1.2.25.1011'
'enableRightSidebarMerchFallback&Allow merch to fallback to artist level merch if track level does not exist",default:\K!1&true&s&xpuiJs&1.2.5.954&1.2.11.916'
'enableRightSidebarTransitionAnimations&Enable the slide-in.out transition on the right sidebar",default:\K!1&true&s&xpuiJs&1.2.7.1264&1.2.33.1042'
'enableSearchBox&filter playlists when trying to add songs to a playlist using the contextmenu",default:\K!1&true&s&xpuiJs&1.1.86.857&1.1.93.896'
'enableSearchV3&new Search experience",default:\K!1&true&s&xpuiJs&1.1.87.612&1.2.34.783'
'enableScrollDrivenAnimations&croll driven animations for cards and shelved",default:\K!1&true&s&xpuiJs&1.2.39.578'
'enableSharingButtonOnMiniPlayer&sharing button on MiniPlayer .this also moves the ... icon close to the title.",default:\K!1&true&s&xpuiJs&1.2.39.578'
'enableShortLinks&short links for sharing",default:\K!1&true&s&xpuiJs&1.2.34.783'
'enableShowFollowsSetting&control if followers and following lists are shown on profile",default:\K!1&true&s&xpuiJs&1.2.1.958'
'enableShowRating&new UI for rating books and podcasts",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enableSidebarAnimations&animations on the left and right on the sidebars and makes the right sidebar collapsible",default:\K!1&true&s&xpuiJs&1.2.34.783&1.2.37.701'
'enableSilenceTrimmer&silence trimming in podcasts",default:\K!1&true&s&xpuiJs&1.1.99.871'
'enableSocialConnectOnDesktop&the Social Connect API that powers group listening sessions for Desktop",values:.{1,3},default:.{1,4}\KDISABLED&ENABLED&s&xpuiJs&1.2.21.1104'
'enableSmallerLineHeight&line height 1.5 on the .body ..",default:\K!1&true&s&xpuiJs&1.2.18.997&1.2.23.1125'
'enableSmallPlaybackSpeedIncrements&playback speed range from 0.5-3.5 with every 0.1 increment",default:\K!1&true&s&xpuiJs&1.2.0.1155&1.2.14.1149'
'enableSmartShuffle&Enable Smart Shuffle",default:\K!1&true&s&xpuiJs&1.2.26.1180'
'enableStaticImage2Optimizer&static image2 optimizer to optimize image urls",default:\K!.(?=})&true&s&xpuiJs&1.2.20.1210'
'enableStrangerThingsEasterEgg&Stranger Things upside down Easter Egg",default:\K!1&true&s&xpuiJs&1.1.91.824'
'enableSubtitlesAutogeneratedLabel&label in the subtitle picker.,default:\K!1&true&s&xpuiJs&1.1.70.610'
'enableTogglePlaylistColumns&ability to toggle playlist column visibility",default:\K!1&true&s&xpuiJs&1.2.17.832'
'enableUserCreatedArtwork&user created artworks for playlists",default:\K!1&true&s&xpuiJs&1.2.34.783&1.2.40.599'
'enableUserProfileEdit&editing of user.s own profile in Web Player and DesktopX",default:\K!1&true&s&xpuiJs&1.1.87.612&1.2.25.1011'
'enableVenuePages&Enables venus pages",default:\K!1&true&s&xpuiJs&1.2.37.701'
'enableVideoLabelForSearchResults&video label for search results",default:\K!1&true&s&xpuiJs&1.2.23.1114&1.2.29.605'
'enableVideoPip&desktop picture-in-picture surface using betamax SDK.",default:\K!1&true&s&xpuiJs&1.2.13.656'
'enableViewMode&list . compact mode in entity pages",default:\K!1&true&s&xpuiJs&1.2.24.754'
'enableWhatsNewFeed&what.s new feed panel",default:\K!1&true&s&xpuiJs&1.2.12.902&1.2.16.947'
'enableWhatsNewFeedMainView&Whats new feed in the main view",default:\K!1&true&s&xpuiJs&1.2.17.832'
'enableYLXEnhancements&Your Library X Enhancements",default:\K!1&true&s&xpuiJs&1.2.18.997'
'enableYLXPrereleaseAlbums&album pre-releases in YLX",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enableYLXPrereleaseAudiobooks&audiobook pre-releases in YLX",default:\K!1&true&s&xpuiJs&1.2.32.985'
'enableYLXPrereleases&album pre-releases in YLX",default:\K!1&true&s&xpuiJs&1.2.31.1205&1.2.31.1205'
'enableYLXTypeaheadSearch&jump to the first matching item",default:\K!1&true&s&xpuiJs&1.2.13.656'
'saveButtonAlwaysVisible&Display save button always in whats new feed",default:\K!1&true&s&xpuiJs&1.2.20.1210&1.2.28.0'
'shareButtonPositioning&Share button positioning in NPV",values:.{1,3},default:.{1,4}NPV_\KHIDDEN&ALWAYS_VISIBLE&s&xpuiJs&1.2.39.578'
'showWrappedBanner&Show Wrapped banner on wrapped genre page",default:\K!1&true&s&xpuiJs&1.1.87.612'
)
premiumExpEx=(
'addYourDJToLibraryOnPlayback&Add Your DJ to library on playback",default:\K!1&true&s&xpuiJs&1.2.6.861'
'enableYourDJ&the .Your DJ. feature.,default:\K!1&true&s&xpuiJs&1.2.6.861'
'enableYourSoundCapsuleModal&showing a modal on desktop to users who have clicked on a Your Sound Capsule share link",default:\K!1&true&s&xpuiJs&1.2.38.720'
)

run_prepare
run_uninstall_check
run_interactive_check
run_install_check
run_cache_check
run_core_start
run_patches
run_finish

printf "\xE2\x9C\x94\x20\x46\x69\x6E\x69\x73\x68\x65\x64\n\n"
exit 0
