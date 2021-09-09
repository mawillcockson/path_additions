in_path() {
    PATH_COMPONENT="${PATH%%:*}"
    # Adding a : to the end of the path left is critical, since:
    # test_parameter_expansion '/bin' ':'
    # "${PATH%:}"     -> "/bin"
    # "${PATH%*:}"    -> "/bin"
    # "${PATH%:*}"    -> "/bin"
    # "${PATH%*:*}"   -> "/bin"
    # "${PATH%%:}"    -> "/bin"
    # "${PATH%%*:}"   -> "/bin"
    # "${PATH%%:*}"   -> "/bin"
    # "${PATH%%*:*}"  -> "/bin"
    # "${PATH#:}"     -> "/bin"
    # "${PATH#*:}"    -> "/bin"
    # "${PATH#:*}"    -> "/bin"
    # "${PATH#*:*}"   -> "/bin"
    # "${PATH##:}"    -> "/bin"
    # "${PATH##*:}"   -> "/bin"
    # "${PATH##:*}"   -> "/bin"
    # "${PATH##*:*}"  -> "/bin"
    PATH_LEFT="${PATH#*:}:"
    while [ -n "${PATH_COMPONENT:-""}" ] || [ -n "${PATH_LEFT:-""}" ]; do
        if [ "${1:-""}" = "${PATH_COMPONENT}" ]; then
            return 0
        fi
        PATH_COMPONENT="${PATH_LEFT%%:*}"
        PATH_LEFT="${PATH_LEFT#*:}"
    done
    for var in  PATH_COMPONENT PATH_LEFT; do
        unset -v "${var}" > /dev/null 2>&1 || true
    done
    return 1
}

test_in_path() {
    if [ "$#" -ne 1 ]; then
        echo "1 arg required: DIR"
        return 1
    fi
    if in_path "${1:-""}"; then
        printf '"%s" yes\n' "${1:-""}"
    else
        printf '"%s" no\n' "${1:-""}"
    fi
    return 0
}
PATH="/bin:/usr/bin"
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path "/binn"
test_in_path "/bin"
test_in_path ":"
test_in_path ''
PATH=":/bin:/usr/bin"
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path ":"
test_in_path ''
PATH=":"
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path ":"
test_in_path ''
PATH=""
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path ":"
test_in_path ''
