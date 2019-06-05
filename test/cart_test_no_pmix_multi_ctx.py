#!/usr/bin/env python3
# Copyright (C) 2018-2019 Intel Corporation
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted for any purpose (including commercial purposes)
# provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions, and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions, and the following disclaimer in the
#    documentation and/or materials provided with the distribution.
#
# 3. In addition, redistributions of modified forms of the source or binary
#    code must carry prominent notices stating that the original code was
#    changed and the date of the change.
#
#  4. All publications or advertising materials mentioning features or use of
#     this software are asked, but not required, to acknowledge that it was
#     developed by Intel Corporation and credit the contributors.
#
# 5. Neither the name of Intel Corporation, nor the name of any Contributor
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# -*- coding: utf-8 -*-

"""

cart test when running with no pmix

Usage:

Execute from the install/$arch/TESTING directory.

python3 test_runner scripts/cart_test_no_pmix_multi_ctx.yml

To use valgrind memory checking
set TR_USE_VALGRIND in cart_test_no_pmix_multi_ctx.yml to memcheck

To use valgrind call (callgrind) profiling
set TR_USE_VALGRIND in cart_test_no_pmix_multi_ctx.yml to callgrind

"""
# pylint: disable=fixme
import os
import subprocess
import commontestsuite

class TestNoPmix(commontestsuite.CommonTestSuite):
    """ Execute non-pmix tests """

    def setUp(self):
        """setup the test"""
        self.get_test_info()
        # TODO: disable log_mask for now, as debug mask produces
        # too much data during node addition.

        # log_mask = os.getenv("D_LOG_MASK", "INFO")
        log_file = self.get_cart_long_log_name()
        print("LOG file is {}".format(log_file))
        crt_phy_addr = os.getenv("CRT_PHY_ADDR_STR", "ofi+sockets")
        ofi_interface = os.getenv("OFI_INTERFACE", "eth0")
        ofi_share_addr = os.getenv("CRT_CTX_SHARE_ADDR", "0")
        ofi_ctx_num = os.getenv("CRT_CTX_NUM", "8")

        # TODO: Wrong log file name is generated. need to investigate
        self.pass_env = {"CRT_PHY_ADDR_STR": crt_phy_addr,
                         "OFI_INTERFACE": ofi_interface,
                         "CRT_CTX_SHARE_ADDR": ofi_share_addr,
                         "CRT_CTX_NUM": ofi_ctx_num}

    def tearDown(self):
        """tear down the test"""
        self.logger.info("tearDown begin")
        self.logger.info("tearDown end")

    def test_no_pmix(self):
        """test_no_pmix test case"""

        test_bin = 'tests/no_pmix_multi_ctx'

        test_env = self.pass_env
        p = subprocess.Popen([test_bin], env=test_env,
                             stdout=subprocess.PIPE)

        rc = p.wait(timeout=10)


        if rc != 0:
            print("Error waiting for process. returning {}".format(rc))
            return rc

        print("Finished waiting for {}".format(p))

        return 0
