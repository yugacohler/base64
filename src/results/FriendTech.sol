// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// An interface to the FriendTechSharesV1 contract.
interface FriendTech {
    ////////// PUBLIC APIS //////////

    // Gets the sell price of a subject and a number of shares.
    function getSellPrice(address sharesSubject, uint256 amount) external view returns (uint256);
}
