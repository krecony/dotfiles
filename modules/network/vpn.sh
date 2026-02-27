usage="usage: $0 [ connect | disconnect | interfaces ]"

if [[ $# -lt 1 ]]; then
  echo "$usage"
  exit 1
fi

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

current_interface=$(wg | grep interface | awk -F: '{ print $2 }')
current_interface="${current_interface:1}"

get_servers() {
  systemctl list-unit-files | grep "wg-quick-*" | awk -F'wg-quick-' '{ print $2 }' | awk -F'.' '{ print $1 }'
}

check_if_exists() {
  get_servers | grep "$1" &>/dev/null
}

case "$1" in
  connect)
    if [[ $# -ne 2 ]]; then
      echo "usage: vpn connect <interface>"
      exit 1
    fi

    if [[ $current_interface != "" ]]; then
      systemctl stop wg-quick-"${current_interface}"
    fi

    check_if_exists "$2"
    if [[ "$?" -ne 1 ]]; then
      systemctl start wg-quick-"$2"
    else
      echo "interface $2 doesn't exist"
    fi
    ;;
  disconnect)
    if [[ $current_interface == "" ]]; then
      echo "vpn is not connected"
    else
      systemctl stop wg-quick-"${current_interface}"
    fi
    ;;
  interfaces)
    get_servers
    ;;
  *)
    echo "unknown command $1"
    echo "$usage"
    ;;
esac

