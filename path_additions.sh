#!/bin/sh
# shellcheck enable=all
## PATH modification ##
# This expects a directory ~/.profile.d/add-to-path/ to be present.
# Each .sh file in this directory should, upon being run, print out the content
# to be added to the $PATH. Each directory should be separated with : and not
# newlines.
#
# For example:
#
# echo "$HOME/apps/custom_app/bin:$HOME/.custom_app/bin"
#
# Each component in the string will be checked to see if it points to a
# directory, and if it's already defined in $PATH.
#
# help from:
# https://stackoverflow.com/a/15155077
# https://stackoverflow.com/a/29949759
# https://stackoverflow.com/a/11655875

if ! command -v in_path >/dev/null 2>&1; then
    . ./in_path.sh
fi
if ! command -v log >/dev/null 2>&1; then
    . ./log.sh
fi

path_additions () {
    # zsh does not follow POSIX field splitting by default:
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_05
    # https://zsh.sourceforge.io/FAQ/zshfaq03.html#l18
    # https://stackoverflow.com/a/6715447
    # https://stackoverflow.com/a/49628419
    ADD_TO_PATH_DIR="${HOME:?""}/.profile.d/add-to-path"
    # log DEBUG "\$PATH -> \"${PATH:-""}\"" # debug

    if ! [ -d "${ADD_TO_PATH_DIR}" ]; then
        log WARNING "no directory found at \"${ADD_TO_PATH_DIR}\""
    fi

    for file in "${ADD_TO_PATH_DIR}"/*.sh ; do
        # log DEBUG "\$file -> \"${file}\""
        # shellcheck disable=SC1090
        if ! ADDITION="$(. "${file}")"; then
            log WARNING "there was a problem with the file \"${file}\""
            continue
        fi
        # ADDITION="/bin:${HOME}/.local/bin" # debug
        # log DEBUG "\$ADDITION -> \"${ADDITION:-""}\""
        COMPONENT="${ADDITION%%:*}"
        # log DEBUG "starting \$COMPONENT -> \"${COMPONENT:-""}\""
        # If ADDITION has only one subpath
        if [ "${COMPONENT:-""}" = "${ADDITION}" ]; then
            ADDITION_REMAINING=""
        else
            ADDITION_REMAINING="${ADDITION#*:}:"
        fi
        # log DEBUG "starting \$ADDITION_REMAINING -> \"${ADDITION_REMAINING:-""}\""
        while [ -n "${COMPONENT:-""}" ] || [ -n "${ADDITION_REMAINING:-""}" ]; do
            # if the longest prefix ending in / is removed, is the string empty?
            # -> does the string end in a / character?
            if [ -z "${COMPONENT##*/}" ]; then
                # log DEBUG "\$COMPONENT ends with /"
                # trim a single trailing slash
                COMPONENT="${COMPONENT%/}"
            fi
            if [ -z "${COMPONENT##*/}" ]; then
                log WARNING "\$COMPONENT had its last / removed, and it still has a trailing slash! -> \"${COMPONENT}\""
            fi
            # ! [ -d "${COMPONENT}" ] && log DEBUG "\"${COMPONENT}\" is not directory"
            if [ -d "${COMPONENT}" ] && ! in_path "${COMPONENT}"; then
                # log DEBUG "adding \"${COMPONENT}\""
                if [ -z "${ALL_ADDITIONS:-""}" ]; then
                    ALL_ADDITIONS="${COMPONENT}"
                else
                    ALL_ADDITIONS="${COMPONENT}:${ALL_ADDITIONS}"
                fi
            else
                log WARNING "\"${COMPONENT}\" doesn't exist, so not adding to \$PATH"
            fi
            COMPONENT="${ADDITION_REMAINING%%:*}"
            # log DEBUG "new \$COMPONENT -> \"${COMPONENT:-""}\""
            ADDITION_REMAINING="${ADDITION_REMAINING#*:}"
            # log DEBUG "new \$ADDITION_REMAINING -> \"${ADDITION_REMAINING:-""}\""
        done
    done

    if [ -n "${ALL_ADDITIONS:-""}" ]; then
        # log DEBUG "\$ALL_ADDITIONS -> \"${ALL_ADDITIONS}\""
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
        unset -v "${name}" > /dev/null 2>&1 || true
    done
    # log DEBUG "\$PATH -> \"${PATH:-""}\""
    return 0
}
export path_additions
