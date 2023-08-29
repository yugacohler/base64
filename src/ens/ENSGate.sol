// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// A contract that ensures that the given address is an ENS name.
abstract contract ENSGate {
    ////////// MEMBER VARIABLES //////////
    ENSRegistrar _ens;
    ReverseRegistrar _reverseRegistrar;

    ////////// CONSTRUCTOR //////////

    constructor(ENSRegistrar ens, ReverseRegistrar reverseRegistrar) {
        _ens = ens;
        _reverseRegistrar = reverseRegistrar;
    }

    // Returns true if the given address has an ENS name.
    function hasENS(address addr) internal view returns (bool) {
        bytes32 node = _reverseRegistrar.node(addr);
        return _ens.recordExists(node);
    }
}

// The interface to the ENS registrar.
abstract contract ENSRegistrar {
    function recordExists(bytes32 node) external view virtual returns (bool);
}

// The interface to the ENS reverse registrar.
abstract contract ReverseRegistrar {
    function node(address addr) external view virtual returns (bytes32);
}
