#!/bin/sh

# external commands
. ~/work/mirror_script/cmd.sh

for I in 9 8 7 6 5 4 3 2 1; do
    FILECOUNT=`${LS} *.${I} | ${WC} -l | ${TR} -d ' '`
    if [ ${FILECOUNT} -gt 0 ]; then
        for F in `${LS} *.${I}`; do
            FILENAME=`${BASENAME} ${F} .${I}`

            if [ ! -f "${F}" ]; then
                continue
            fi

            if [ ! -f "${FILENAME}" ]; then
                echo "${FILENAME} not found."
                continue
            fi

            MD5A=`${MD5} ${F} | ${CUT} -c 1-32`
            MD5B=`${MD5} ${FILENAME} | ${CUT} -c 1-32`

            if [ "${MD5A}" = "${MD5B}" ]; then
                echo "rm ${F}"

                ${RM} "${F}"
            else
                echo "keep ${F}"
            fi
        done
    fi
done
