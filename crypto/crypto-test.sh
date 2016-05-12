#!/bin/bash
#
# crypto IP test cases
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
# Author: Ricardo Salveti <rsalveti@linaro.org>
#         Alexander Sack <asac@linaro.org>
#         Nicolas Ferre <nicolas.ferre@atmel.com>
#

OUT=0
CRYPTO_IP_LIST="aes tdes sha"
CRYPTO_IPS="$*"

source include/sh-test-lib

## crypto library functions
crypto_grep_proper_version () {
    local _IP_PATTERN=$1
    local _ERROR_STRING="Unmanaged"
    local _VERSION_STRING=""

    dmesg | grep ${_IP_PATTERN} | grep ${_ERROR_STRING} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
	# Error in version
        return 1
    fi

    _VERSION_STRING=$(dmesg | grep ${_IP_PATTERN} | awk -F ': ' -e '/version/{print $3}')
    echo "${_IP_PATTERN} version: ${_VERSION_STRING}" 1>&2

    return 0
}

crypto_grep_driver () {
    local _PATTERN=$1

    cat /proc/crypto | grep ${_PATTERN} > /dev/null 2>&1
}

## Reset to known state
test_setup() {
    # sanity check
    if [ "x${CRYPTO_IPS}" == "x" ]; then
	    error_msg "usage: test hardware crypto IP is one of ${CRYPTO_IP_LIST}" 1>&2
    fi

    # print some information
    uname -a 1>&2
    dmesg | grep "AT91: Detected" 1>&2
    return 0
}

test_restore() {
    local _OUT=$1

    if [ "x$_OUT" == "x" ]; then
        $_OUT=0
    fi

    # Do things that can fail...
    # [none]

    # exit with proper code
    return $_OUT
}

## Test case definitions

# Has HW crypto IPs
test_has_aes_driver() {
    TEST="has_aes_driver"
    local _AES_PATTERN="atmel_aes"
    local _PROC_CRYPTO_AES_PATTERN="atmel-.*-aes"

    crypto_grep_driver ${_PROC_CRYPTO_AES_PATTERN}
    if [ $? -ne 0 ]; then
        fail_test "AES driver not found" && return 1
    fi

    crypto_grep_proper_version ${_AES_PATTERN}
    if [ $? -ne 0 ]; then
        fail_test "AES IP version not good" && return 1
    fi

    pass_test
}

test_has_tdes_driver() {
    TEST="has_tdes_driver"
    local _TDES_PATTERN="atmel_tdes"
    local _PROC_CRYPTO_TDES_PATTERN="atmel-.*-tdes"

    crypto_grep_driver ${_PROC_CRYPTO_TDES_PATTERN}
    if [ $? -ne 0 ]; then
        fail_test "TDES driver not found" && return 1
    fi

    crypto_grep_proper_version ${_TDES_PATTERN}
    if [ $? -ne 0 ]; then
        fail_test "TDES IP version not good" && return 1
    fi

    pass_test
}

test_has_sha_driver() {
    TEST="has_sha_driver"
    local _SHA_PATTERN="atmel_sha"
    local _PROC_CRYPTO_SHA_PATTERN="atmel-sha.*"

    crypto_grep_driver ${_PROC_CRYPTO_SHA_PATTERN}
    if [ $? -ne 0 ]; then
        fail_test "SHA driver not found" && return 1
    fi

    crypto_grep_proper_version ${_SHA_PATTERN}
    if [ $? -ne 0 ]; then
        fail_test "SHA IP version not good" && return 1
    fi

    pass_test
}


# setup the environment
test_setup

# run the tests
for ip in ${CRYPTO_IPS}; do
    case ${ip} in
        aes)
            test_has_aes_driver
            ;;
        tdes)
            test_has_tdes_driver
            ;;
        sha)
            test_has_sha_driver
            ;;
        *)
	    echo "usage: test hardware crypto IP is one of ${CRYPTO_IP_LIST}" 1>&2
            OUT=1
	    break
            ;;
   esac
done

# set back the environment to previous state
test_restore $OUT
