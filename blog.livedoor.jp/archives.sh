#!/bin/sh

# $0 url [url2 [url3 [...]]]
if [ -z "$1" ]; then
    exit;
fi


# external commands
AWK="/usr/bin/awk"
CUT="/usr/bin/cut"


while [ ! -z "$1" ]; do
    # avoid double-typed command
    if [ "$0" = "$1" ]; then
        shift
        continue
    fi

    URL=`echo -n "$1"`

    # check if $1's prefix is '//'
    CHECKSLASHSLASH=`echo "$1" | ${CUT} -c 1-2`
    if [ "//" = "${CHECKSLASHSLASH}" ]; then
        URL=`echo -n "http:$1"`
    fi

    # parse url
    USERNAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$4);}'`

    cd ~

    # call script
    while [ 1 -eq 1 ]; do
        SCRIPT_NAME=`echo -n "work/mirror_script/blog.livedoor.jp/archives_${USERNAME}.sh"`
        if [ -f "${SCRIPT_NAME}" ]; then
            ${SCRIPT_NAME} ${URL}
        else
            echo "no script for: ${URL}"
        fi

        break
    done

    shift
done
