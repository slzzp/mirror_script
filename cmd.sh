#!/bin/sh

if [ "${MACHTYPE}" = "arm64-apple-darwin24" ]; then
  # MAC
  OSNAME=ios

  AWK="/usr/bin/awk"
  BASENAME="/usr/bin/basename"
  CURL="/usr/bin/curl"
  CUT="/usr/bin/cut"
  DATE="/bin/date"
  ECHO="/bin/echo"
  EXPR="/bin/expr"
  FILE="/usr/bin/file"
  FIND="/usr/bin/find"
  GREP="/usr/bin/grep"
  LS="/bin/ls"
  MD5="/sbin/md5sum"
  MKDIR="/bin/mkdir"
  MV="/bin/mv"
  RM="/bin/rm"
  RMDIR="/bin/rmdir"
  SED="/usr/bin/sed"
  TR="/usr/bin/tr"
  WC="/usr/bin/wc"
  WGET="/opt/homebrew/bin/wget"
else
  # Linux
  OSNAME=linux

  AWK="/usr/bin/awk"
  BASENAME="/usr/bin/basename"
  CURL="/usr/bin/curl"
  CUT="/usr/bin/cut"
  DATE="/bin/date"
  ECHO="/bin/echo"
  EXPR="/usr/bin/expr"
  FILE="/usr/bin/file"
  FIND="/usr/bin/find"
  GREP="/bin/grep"
  LS="/bin/ls"
  MD5="/usr/bin/md5sum"
  MKDIR="/bin/mkdir"
  MV="/bin/mv"
  RM="/bin/rm"
  RMDIR="/bin/rmdir"
  SED="/bin/sed"
  TR="/usr/bin/tr"
  WC="/usr/bin/wc"
  WGET="/usr/bin/wget"
fi
