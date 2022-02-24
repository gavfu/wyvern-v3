/*

  << Wyvern Proxy Registry >>

*/

pragma solidity 0.7.5;

import "./registry/ProxyRegistry.sol";
import "./registry/AuthenticatedProxy.sol";

/**
 * @title WyvernRegistry
 * @author Wyvern Protocol Developers
 */

 /**
`WyvernRegistry` 的两大作用:
    1. 维护一个 mapping (`proxies`)，记录每个用户的 AuthenticatedProxy。`proxy` 的类型由 `delegateProxyImplementation` 变量表示。
       实际存储在 mapping 时，每个 AuthenticatedProxy 会包装成一个 OwnableDelegateProxy，方便升级
    2. 维护一个可以访问该 mapping 的合约列表，存储在 `mapping(address => bool) public contracts` 中。 
       在初始化时，WyvernExchange 即被授权。
  */
contract WyvernRegistry is ProxyRegistry {

    string public constant name = "Wyvern Protocol Proxy Registry";

    /* Whether the initial auth address has been set. */
    bool public initialAddressSet = false;

    constructor ()
        public
    {   
        AuthenticatedProxy impl = new AuthenticatedProxy();
        impl.initialize(address(this), this);
        impl.setRevoke(true);
        delegateProxyImplementation = address(impl);
    }   

    /** 
     * Grant authentication to the initial Exchange protocol contract
     *
     * @dev No delay, can only be called once - after that the standard registry process with a delay must be used
     * @param authAddress Address of the contract to grant authentication
     */
    function grantInitialAuthentication (address authAddress)
        onlyOwner
        public
    {   
        require(!initialAddressSet, "Wyvern Protocol Proxy Registry initial address already set");
        initialAddressSet = true;
        contracts[authAddress] = true;
    }   

}
