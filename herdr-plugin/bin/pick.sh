#!/bin/sh
# Overlay entrypoint: show the list written by recent.sh and open the chosen
# file next to the pane the user came from.

list=${GMD_RECENT_LIST:-}
root=${GMD_RECENT_ROOT:-}

printf '\n  Recently written Markdown'
[ -n "$root" ] && printf ' in %s' "$root"
printf '\n\n'

if [ ! -s "$list" ]; then
  printf '  Nothing changed in the last %s days.\n\n  Press Enter to close.' "${GMD_RECENT_DAYS:-3}"
  read -r _
  exit 0
fi

i=0
while IFS= read -r file; do
  i=$((i + 1))
  case $file in "$root"/*) shown=${file#"$root"/} ;; "$HOME"/*) shown="~/${file#"$HOME"/}" ;; *) shown=$file ;; esac
  printf '  %2d  %s\n' "$i" "$shown"
done < "$list"

printf '\n  Open which file? [1-%s, Enter = 1, q = cancel] ' "$i"
read -r answer
case $answer in
  q|Q) exit 0 ;;
  '') answer=1 ;;
esac
case $answer in
  *[!0-9]*) exit 0 ;;
esac
[ "$answer" -ge 1 ] && [ "$answer" -le "$i" ] || exit 0

file=$(sed -n "${answer}p" "$list")
HERDR_PANE_ID=$GMD_ORIGIN_PANE exec sh bin/open.sh "$file"
