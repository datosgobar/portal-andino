#!/bin/bash
set -e;

return `test "200" == $(echo $(curl -k -s -o /dev/null -w "%{http_code}" "https://localhost:7777"))`
return `test "301" == $(echo $(curl -k -s -o /dev/null -w "%{http_code}" "http://localhost")) || "302" == $(echo $(curl -k -s -o /dev/null -w "%{http_code}" "http://localhost"))`
