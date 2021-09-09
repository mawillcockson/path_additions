test_parameter_expansion() {
    set -eu
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
}
test_parameter_expansion '/bin:' ':'
