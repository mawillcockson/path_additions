. ./in_path.sh

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
# shellcheck disable=SC2016
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path "/binn"
test_in_path "/bin"
test_in_path ":"
test_in_path ''
PATH=":/bin:/usr/bin"
# shellcheck disable=SC2016
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path ":"
test_in_path ''
PATH=":"
# shellcheck disable=SC2016
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path ":"
test_in_path ''
# shellcheck disable=SC2123
PATH=""
# shellcheck disable=SC2016
printf '$PATH -> "%s"\n' "${PATH:-""}"
test_in_path ":"
test_in_path ''
