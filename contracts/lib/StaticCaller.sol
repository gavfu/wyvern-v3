/*

  << Static Caller >>

*/

pragma solidity 0.7.5;

/**
 * @title StaticCaller
 * @author Wyvern Protocol Developers
 */
contract StaticCaller {

    function staticCall(address target, bytes memory data)
        internal
        view
        returns (bool result)
    {
        /**
        https://docs.soliditylang.org/en/v0.7.5/yul.html#yul
            staticcall(g, a, in, insize, out, outsize):
                identical to call(g, a, 0, in, insize, out, outsize) but do not allow state modifications
            call(g, a, v, in, insize, out, outsize)
                call contract at address a with input mem[in…(in+insize)) providing g gas and v wei and output area mem[out…(out+outsize)) returning 0 on error (eg. out of gas) and 1 on success    
         */
        assembly {
            result := staticcall(gas(), target, add(data, 0x20), mload(data), mload(0x40), 0)
        }
        return result;
    }

    /**
    `staticCallUint` 和 `staticCall` 的区别，是可以返回 0x20 大小的返回值；而 `staticCall` 只返回调用是否成功  
     */
    function staticCallUint(address target, bytes memory data)
        internal
        view
        returns (uint ret)
    {
        bool result;
        assembly {
            let size := 0x20
            let free := mload(0x40)
            result := staticcall(gas(), target, add(data, 0x20), mload(data), free, size)
            ret := mload(free)
        }
        require(result, "Static call failed");
        return ret;
    }

}
