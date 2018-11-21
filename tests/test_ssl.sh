#!/bin/bash
set -e;

if [ return `test "200" != $(echo $(curl -k -s -o /dev/null -w "%{http_code}" "https://localhost:7777"))` ]
then
    exit 1
fi

if [ return `test "301" == $(echo $(curl -k -s -o /dev/null -w "%{http_code}" "http://localhost")) || "302" == $(echo $(curl -k -s -o /dev/null -w "%{http_code}" "http://localhost"))` ]
then
    exit 1
fi
exit 0
