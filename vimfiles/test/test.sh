#!/bin/bash - 
#===============================================================================
#
#          FILE: test.sh
# 
#         USAGE: ./test.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: tenfyzhong (tenfy), tenfyzhong@tencent.com
#  ORGANIZATION: 
#       CREATED: 2016年06月14日 19:35
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
vim '+Vader!*' && echo Success || echo Failure

