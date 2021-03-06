#!/bin/sh
# shellcheck enable=all
## PATH modification ##
# This expects a directory ~/.profile.d/add-to-path/ to be present.
# Each file in this directory should have an add_to_path() function defined
# that, when called, prints out the string to add to the PATH environment
# variable.
#
# For example:
#
# add_to_path() {
#     echo "$HOME/apps/custom_app/bin:$HOME/.custom_app/bin"
#     return 0
# }
#
# Each component in the string will be checked to see if it points to a
# directory, and if it's already defined in PATH.
#
# help from:
# https://stackoverflow.com/a/15155077
# https://stackoverflow.com/a/29949759
# https://stackoverflow.com/a/11655875
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

path_additions () {
    # zsh does not follow POSIX field splitting by default:
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_05
    # https://zsh.sourceforge.io/FAQ/zshfaq03.html#l18
    # https://stackoverflow.com/a/6715447
    # https://stackoverflow.com/a/49628419
    ADD_TO_PATH_DIR="${HOME:?""}/.profile.d/add-to-path"
    # printf '$PATH -> "%s"\n' "${PATH:-""}" # debug

    if [ -d "${ADD_TO_PATH_DIR}" ]; then
        for file in "${ADD_TO_PATH_DIR}"/*.sh ; do
            # printf 'file -> "%s"\n' "${file}" # debug
            unset -f add_to_path > /dev/null 2>&1 || true
            if ! ADDITION="$(. "${file}")"; then
                echo "there was a problem with the file \"${file}\""
                continue
            fi
            # ADDITION="/bin:${HOME}/.local/bin" # debug
            # printf '$ADDITION -> "%s"\n' "${ADDITION:-""}" # debug
            COMPONENT="${ADDITION%%:*}"
            # printf 'starting $COMPONENT -> "%s"\n' "${COMPONENT:-""}" # debug
            # If ADDITION has only one subpath
            if [ "${COMPONENT:-""}" = "${ADDITION}" ]; then
                ADDITION_REMAINING=""
            else
                ADDITION_REMAINING="${ADDITION#*:}:"
            fi
            # printf 'starting $ADDITION_REMAINING -> "%s"\n' "${ADDITION_REMAINING:-""}" # debug
            while [ -n "${COMPONENT:-""}" ] || [ -n "${ADDITION_REMAINING:-""}" ]; do
                # printf '$COMPONENT -> "%s"\n' "${COMPONENT:-""}" # debug
                # # if the shortest suffix matching the pattern '/'
                # # is removed, is the string the same?
                # # -> does the string end in a / character?
                # if [ "${component%'/'}" != "$component" ]; then
                # if the longest prefix ending in / is removed, is the string empty?
                # -> does the string end in a / character?
                if [ -z "${COMPONENT##*/}" ]; then
                    # echo "ends with /" # debug
                    COMPONENT="${COMPONENT%/}"
                fi
                # if ! [ -d "${COMPONENT}" ]; then echo "$COMPONENT is not directory"; fi # debug
                if [ -d "${COMPONENT}" ] && ! in_path "${COMPONENT}"; then
                    # printf 'would add "%s"\n' "${COMPONENT}" # debug
                    if [ -z "${ALL_ADDITIONS:-""}" ]; then
                        ALL_ADDITIONS="${COMPONENT}"
                    else
                        ALL_ADDITIONS="${COMPONENT}:${ALL_ADDITIONS:-""}"
                    fi
                # else printf 'would not add "%s"\n' "${COMPONENT}" # debug
                fi
                COMPONENT="${ADDITION_REMAINING%%:*}"
                # printf 'new $COMPONENT -> "%s"\n' "${COMPONENT:-""}" # debug
                ADDITION_REMAINING="${ADDITION_REMAINING#*:}"
                # printf 'new $ADDITION_REMAINING -> "%s"\n' "${ADDITION_REMAINING:-""}" # debug
            done
        done
    fi
    if [ -n "${ALL_ADDITIONS:-""}" ]; then
        # printf '$ALL_ADDITIONS -> "%s"\n' "${ALL_ADDITIONS}" # debug
        PATH="${ALL_ADDITIONS}:${PATH}"
    fi
    # NOTE:BUG Why does zsh close immediately after startup without this???
    # because zsh's "local" is completely different from POSIX "local"
    # From:
    # https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html
    #
    # local [ {+|-}AHUahlprtux ] [ {+|-}EFLRZi [ n ] ] [ name[=value] ... ]
    #
    # Same as typeset, except that the options -g, and -f are not permitted. In
    # this case the -x option does not force the use of -g, i.e. exported
    # variables will be local to functions.
    # set +e
    for name in ADD_TO_PATH_DIR file ADDITION COMPONENT ADDITION_REMAINING ALL_ADDITIONS; do
        unset -f "${name}" > /dev/null 2>&1 || true
    done
    # printf '$PATH -> "%s"\n' "${PATH:-""}" # debug
    return 0
}
path_additions
