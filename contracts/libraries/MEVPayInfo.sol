// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import {MEVPayInfo} from "../interfaces/IMEVBoostPaymaster.sol";

// ERC-721
library MEVPayInfoLib {
    string internal constant MEV_PAY_INFO_TYPE =
        "MEVPayInfo(address provider,bytes32 boostUserOpHash,uint256 amount)";

    function hash(
        MEVPayInfo memory mevPayInfo,
        bytes32 domainSeparator
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainSeparator,
                    keccak256(
                        abi.encode(
                            keccak256(bytes(MEV_PAY_INFO_TYPE)),
                            mevPayInfo.provider,
                            mevPayInfo.boostUserOpHash,
                            mevPayInfo.amount
                        )
                    )
                )
            );
    }

    function verify(
        MEVPayInfo memory mevPayInfo,
        bytes32 domainSeparator,
        bytes memory signature
    ) internal pure returns (bool) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (signature.length != 65) {
            return false;
        }

        /* solhint-disable no-inline-assembly */
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        /* solhint-enable no-inline-assembly */

        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return false;
        } else {
            return
                mevPayInfo.provider ==
                ecrecover(hash(mevPayInfo, domainSeparator), v, r, s);
        }
    }
}
