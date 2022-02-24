/*

  << Wyvern Atomicizer >>

  Execute multiple transactions, in order, atomically (if any fails, all revert).

*/

pragma solidity 0.7.5;

/**
 * @title WyvernAtomicizer
 * @author Wyvern Protocol Developers
 */

 /**
  介绍 `library`: 
    https://docs.soliditylang.org/en/v0.7.5/contracts.html?highlight=library#libraries
  */
library WyvernAtomicizer {

    /**
    `calldata` is non-modifiable & non-persistent:
        https://docs.soliditylang.org/en/v0.7.5/types.html#data-location
     */
    function atomicize (address[] calldata addrs, uint[] calldata values, uint[] calldata calldataLengths, bytes calldata calldatas)
        external
    {
        require(addrs.length == values.length && addrs.length == calldataLengths.length, "Addresses, calldata lengths, and values must match in quantity");

        uint j = 0;
        for (uint i = 0; i < addrs.length; i++) {
            bytes memory cd = new bytes(calldataLengths[i]);
            for (uint k = 0; k < calldataLengths[i]; k++) {
                cd[k] = calldatas[j];
                j++;
            }
            /**
            1. A library’s code is executed using a CALL instead of a DELEGATECALL or CALLCODE, it will revert unless a view or pure function is called
            2. <address>.call(bytes memory) returns (bool, bytes memory)
                issue low-level CALL with the given payload, returns success condition and return data, forwards all available gas, adjustable
                Question: What is `{calue: xx}`? Is it `gas` fee?
             */
            (bool success,) = addrs[i].call{value: values[i]}(cd);
            require(success, "Atomicizer subcall failed");
        }
    }

}

/**
About `delegatecall`
    https://docs.soliditylang.org/en/v0.7.5/introduction-to-smart-contracts.html?highlight=calldata#delegatecall-callcode-and-libraries
    There exists a special variant of a message call, named delegatecall which is identical to a message call apart from the fact that the code at the target address is executed in the context of the calling contract and msg.sender and msg.value do not change their values.

 */
