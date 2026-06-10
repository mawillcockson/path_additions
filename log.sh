log() {
    case "$#" in
        1)
            LOG_LEVEL="INFO"
            MSG="${1:?"message cannot be empty"}"
            ;;
        2)
            LOG_LEVEL="${1:?"if a log level is given, it cannot be empty"}"
            MSG="${2:?"message cannot be empty"}"
            ;;
        *)
            printf 'wrong number of arguments: %s\nexpected 1 or 2' "$#"
            return 1
    esac

    LOG_PREFIX="${LOG_PREFIX-"--${LOG_LEVEL}--"}"
    printf '%s%s%s\n' "${LOG_PREFIX-}" "${LOG_PREFIX:+" "}" "${MSG}"
}

error() {
    log ERROR "$@"
    return 1
}

# it's probably not a good idea to use this function in log(), as it could be
# confusing to try to log something and nothing happens because it's in a
# script, so I think this is good to provide as a function so that, in areas
# using log whose output might disrupt for instance scp by returning a bunch of
# text upon logging in, this function can test if the shell is interactive
shell_is_interactive() {
    if test -n "${SHELL_IS_INTERACTIVE:+"set"}"; then
        # this is my shell variable, probably set in ENV=/etc/profile.interactive
        # itself probably set in /etc/profile.d/ENV.sh
        #
        # $ENV is a special environment variable that points to a file that the
        # shell will only source when it's in an interactive mode:
        # https://pubs.opengroup.org/onlinepubs/9799919799/utilities/sh.html#tag_20_110_08
        return 0
    fi

    # bash sets $- with some letters that indicate info about the shell
    # environment, and `i` indicates it's an interactive shell:
    # https://www.gnu.org/software/bash/manual/bash.html#index-_002d
    # Looks like it's POSIX!
    # https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#:~:text=%28Hyphen%2E%29%20Expands%20to%20the
    # The odd construct `${-:-}` is using parameter expansion to ensure an
    # error isn't thrown if the variable is not set.
    case "${-:-}" in
        *i*)
            return 0
            ;;
        *)
            ;;
    esac

    # probably not interactive
    return 1
}

export log
export error
