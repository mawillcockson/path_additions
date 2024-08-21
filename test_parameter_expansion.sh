# shellcheck disable=SC2016
test_parameter_expansion() {
    set -eu
    if [ "$#" -ne 2 ]; then
        echo "need exactly two arguments: PATH and SEARCH"
        return 1
    fi

    printf '$PATH -> '\''%s'\''\n' "${1}"
    printf '$SEARCH -> '\''%s'\''\n' "${2}"

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
test_parameter_expansion '/bin:/usr/bin:/home/user/.local/bin' ':'
printf '\n'
test_parameter_expansion '/bin:' ':'
printf '\n'
test_parameter_expansion ':' ':'
printf '\n'
test_parameter_expansion '' ':'
printf '\n'
test_parameter_expansion '/home/user/.local/bin/' '/'
printf '\n'
test_parameter_expansion '/home/user//.local/bin//' '/'
