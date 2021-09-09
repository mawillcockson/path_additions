test_parameter_expansion() {
    if [ "$#" -ne 2 ]; then
        echo "need exactly two arguments: PATH and SEARCH"
        return 1
    fi

    printf '"${PATH%%%s}"\t-> "%s"\n' "${2}" "${1%"${2}"}"
    printf '"${PATH%%*%s}"\t-> "%s"\n' "${2}" "${1%*"${2}"}"
    printf '"${PATH%%%s*}"\t-> "%s"\n' "${2}" "${1%"${2}"*}"
    printf '"${PATH%%*%s*}"\t-> "%s"\n' "${2}" "${1%*"${2}"*}"
    printf '"${PATH%%%%%s}"\t-> "%s"\n' "${2}" "${1%%"${2}"}"
    printf '"${PATH%%%%*%s}"\t-> "%s"\n' "${2}" "${1%%*"${2}"}"
    printf '"${PATH%%%%%s*}"\t-> "%s"\n' "${2}" "${1%%"${2}"*}"
    printf '"${PATH%%%%*%s*}"\t-> "%s"\n' "${2}" "${1%%*"${2}"*}"
    printf '"${PATH#%s}"\t-> "%s"\n' "${2}" "${1#"${2}"}"
    printf '"${PATH#*%s}"\t-> "%s"\n' "${2}" "${1#*"${2}"}"
    printf '"${PATH#%s*}"\t-> "%s"\n' "${2}" "${1#"${2}"*}"
    printf '"${PATH#*%s*}"\t-> "%s"\n' "${2}" "${1#*"${2}"*}"
    printf '"${PATH##%s}"\t-> "%s"\n' "${2}" "${1##"${2}"}"
    printf '"${PATH##*%s}"\t-> "%s"\n' "${2}" "${1##*"${2}"}"
    printf '"${PATH##%s*}"\t-> "%s"\n' "${2}" "${1##"${2}"*}"
    printf '"${PATH##*%s*}"\t-> "%s"\n' "${2}" "${1##*"${2}"*}"
    return 0
}

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

echo "begin"
PATH="/bin:/usr/bin"
printf '$PATH -> "%s"\n' "${PATH:-""}"
ADDITION="/bin:${HOME}/.local/bin"
printf '$ADDITION -> "%s"\n' "${ADDITION:-""}"
COMPONENT="${ADDITION%%:*}"
ADDITION_LEFT="${ADDITION#*:}:"
while [ -n "${COMPONENT:-""}" ] || [ -n "${ADDITION_LEFT:-""}" ]; do
    # # if the shortest suffix matching the pattern '/'
    # # is removed, is the string the same?
    # # -> does the string end in a / character?
    # if [ "${component%'/'}" != "$component" ]; then
    # if the longest prefix ending in / is removed, is the string empty?
    # -> does the string end in a / character?
    if [ -z "${COMPONENT##*/}" ]; then
        echo "ends with /"
        COMPONENT="${COMPONENT%/}"
    fi
    if ! [ -d "${COMPONENT}" ]; then echo "$COMPONENT is not directory"; fi
    if [ -d "${COMPONENT}" ] && ! in_path "${COMPONENT}"; then
        printf 'would add "%s"\n' "${COMPONENT}"
    else
        printf 'would not add "%s"\n' "${COMPONENT}"
    fi
    COMPONENT="${ADDITION_LEFT%%:*}"
    ADDITION_LEFT="${ADDITION_LEFT#*:}"
done
echo "done"
