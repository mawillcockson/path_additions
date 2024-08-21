in_path() {
    if [ -z "${2:-""}" ]; then
        CURRENT_PATH="${PATH:-""}"
    else
        CURRENT_PATH="${2}"
    fi
    PATH_COMPONENT="${CURRENT_PATH%%:*}"
    # Adding a : to the end of the path left is critical, since parameter
    # expansion can't trim a path with a character that isn't in the path, and
    # it'd be harder to tell if there are any more PATH components left:
    #
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
    PATH_LEFT="${CURRENT_PATH#*:}:"
    while [ -n "${PATH_COMPONENT:-""}" ] || [ -n "${PATH_LEFT:-""}" ]; do
        if [ "${1:-""}" = "${PATH_COMPONENT}" ]; then
            return 0
        fi
        PATH_COMPONENT="${PATH_LEFT%%:*}"
        PATH_LEFT="${PATH_LEFT#*:}"
    done
    unset -v PATH_COMPONENT > /dev/null 2>&1 || true
    unset -v PATH_LEFT > /dev/null 2>&1 || true
    return 1
}
export in_path
