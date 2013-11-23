#!/bin/sh

# external commands
AWK="/usr/bin/awk"
BASENAME="/usr/bin/basename"
CUT="/usr/bin/cut"
LS="/bin/ls"
MD5="/usr/bin/md5sum"
RM="/bin/rm"
TR="/usr/bin/tr"
WC="/usr/bin/wc"

for i in 9 8 7 6 5 4 3 2 1
do
    FILECOUNT=`${LS} *.$i | ${WC} -l | ${TR} -d ' '`
    if [ ${FILECOUNT} -gt 0 ]; then
        for f in `${LS} *.$i`
        do
            FILENAME=`${BASENAME} $f .$i`

            MD5A=`${MD5} $f | ${CUT} -c 1-32`
            MD5B=`${MD5} ${FILENAME} | ${CUT} -c 1-32`

            if [ "${MD5A}" = "${MD5B}" ]; then
                echo "rm $f"
                # ${RM} $f
            fi
        done
    fi
done

