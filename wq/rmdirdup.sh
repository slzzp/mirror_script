#!/bin/sh

# external commands
. ~/work/mirror_script/cmd.sh


if [ -z "$1" -o "." = "$1" -o "./" = "$1" ]; then
    exit
fi


for F in `${FIND} . -type f`; do
    FILENAME=`${BASENAME} ${F}`
    PATHFILE=`echo $1/${FILENAME} | ${SED} 's/\/\/*/\//g'`

    if [ ! -f "${PATHFILE}" ]; then
        continue
    fi

    MD5A=`${MD5} ${F} | ${CUT} -c 1-32`
    MD5B=`${MD5} ${PATHFILE} | ${CUT} -c 1-32`

    if [ "${MD5A}" = "${MD5B}" ]; then
        echo "rm ${PATHFILE}"

        ${RM} "${PATHFILE}"
    else
        echo "keep ${PATHFILE}"
    fi
done
