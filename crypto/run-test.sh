#!/bin/sh
#
# Copyright (C) 2012, Linaro Limited.
# Copyright (C) 2012, Atmel.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# First argument is type of crypto IPs to test (as a list)
#

CRYPTO_IPS="$*"

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ ! -f $SCRIPTPATH/sh-test-lib ]; then
    echo "ERROR: No sh test library" >&2
    exit 1
fi

source $SCRIPTPATH/sh-test-lib

# check we're root
if ! check_root; then
    error_msg "Please run the test case as root"
fi

# check proper parameters
for ip in ${CRYPTO_IPS}; do
    case ${ip} in
        aes|tdes|sha)
            ;;
        *)
            error_msg "Not proper test string passed to script ${ip}"
            ;;
   esac
done

# run the tests
/bin/sh -x ./crypto-test.sh ${CRYPTO_IPS}
