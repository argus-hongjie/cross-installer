import_shell_lib() {
  local prefix="${1:-/usr/local}"; test $# -gt 0 && shift
  test "$(ls -A "$prefix"/shell-lib/lib/* 2>/dev/null)" || return 1
  for f in "$prefix"/shell-lib/lib/*; do . "$f"; done
}

install_shell_lib() {
  test "$1" = '--help' && {
    echo "Usage: $0 install shell-lib <version> <sha1> [<prefix>=/usr/local]"
    return 1
  }
  local version="$1"; test $# -gt 0 && shift
  set -- "${version:-master}" "$@"
  untar_url 'https://github.com/elifarley/shell-lib/archive/%s.tar.gz' "$@" && \
  import_shell_lib
}

remove_shell_lib() {
  remove_prefix_aliases /usr/local/shell-lib
}

remove_prefix_aliases() {
  local installation_root="$1"

  echo "Removing '$installation_root' and its aliases from '$(readlink -f "$installation_root"/../bin)'..."
  for f in "$installation_root"/bin/*; do
    test -f "$f" || continue
    rm -fv "$installation_root"/../bin/"$(basename "$f")"
  done
  rm -rfv "$installation_root" "$installation_root"-*
  echo "OK - Removed '$installation_root'."
}

check_hash() {
  local filepath="$1" hashid="$2" hashbase="${3:-$CMD_BASE/../hashes}"
  local expected; for hashfile in "$hashbase"/hashes.*; do
    expected="$(grep "^$hashid\b" "$hashfile")" && expected="${expected##* }" || continue
    echo "$expected  $filepath" | sha1sum -swc - && return
    local actual="$(sha1sum "$filepath")"; echo "FAILED: '$filepath' $hashid ($hashfile)"
    echo "Expected: $expected"; echo "Actual  : ${actual% *}"; return 1
  done; test "$expected" && return
  echo "Id '$hashid' not found in " "$hashbase"/hashes.*; return 1
}

check_sha1() {
  local filepath="$1"; local expected="$2"
  test "$expected" || return 0
  echo "$expected  $filepath" | sha1sum -wc - && return
  local actual="$(sha1sum "$filepath")"; echo "Actual: ${actual% *}"
  return 1
}

untar_url() {
  getopt --test >/dev/null; test $? -eq 4 || { echo "getopt is too old"; return 1 ;}
  local opts=fp: longopts=force,prefix:,hash-id:
  local parsed; parsed="$(getopt --options $opts --longoptions $longopts --name "$0" -- "$@")" || return
  eval set -- "$parsed"

  local _force prefix hashid; while true; do case "$1" in
    -f|--force) _force=f; shift ;;
    -p|--prefix) prefix="$2"; shift 2 ;;
    --hash-id) hashid="$2"; shift 2 ;;
    --) shift; break ;; *) echo "Error"; return 3 ;;
  esac; done

  local url="$1"; test $# -gt 0 && shift
  local version="$1"; test $# -gt 0 && shift
  local sha="$1"; test $# -gt 0 && shift
  test "$prefix" || prefix="${1:-/usr/local}"
  test "$FORCE" && _force=f

  local url="$(printf "$url" "$version")"

  local archive_path="/tmp/archive"
  curl -fsSL "$url" -o "$archive_path" || return

  test "$hashid" && { check_hash "$archive_path" "$hashid" || return ;}
  test "$sha" && { check_sha1 "$archive_path" "$sha" || return ;}

  local archive_root; archive_root="$(tar -tzf "$archive_path" | egrep -m1 -o '^[^/]*')" || return

  test "$_force" && test -d "$prefix/$archive_root" && { rm -rf "$prefix/$archive_root" || return ;}

  tar -xzf "$archive_path" -C "$prefix" && rm "$archive_path" || return
  archive_root="${archive_root%-$version}"

  test "$_force" && test -d "$prefix/$archive_root" && { rm -rf "$prefix/$archive_root" || return ;}

  ln -s "$archive_root-$version" "$prefix/$archive_root" || return

  for f in "$prefix/$archive_root"/bin/*; do
    test -f "$f" && test "${f%%*.jar}" && test "${f%%*.cmd}" && test "${f%%*.bat}" && test "${f%%*.conf}" || continue
    chmod +x "$f" && \
    ln -${_force}s ../"$archive_root"/bin/"$(basename "$f")" "$prefix"/bin || return
  done

  printf "$prefix/$archive_root\n"
}
