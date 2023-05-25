// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "libraries/chainlink.sol";

contract RandomNumberGenerator is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    mapping(bytes32 => address) public requestIdToCaller;
    mapping(bytes32 => uint256) public requestIdToResult;

    constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee)
        VRFConsumerBase(_vrfCoordinator, _linkToken)
    {
        keyHash = _keyHash;
        fee = _fee;
    }

    function requestRandomNumber() external returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK tokens");

        requestId = requestRandomness(keyHash, fee);
        requestIdToCaller[requestId] = msg.sender;

        return requestId;
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        address caller = requestIdToCaller[_requestId];
        uint256 additionalResult = (_randomness % 100)  * 1373123981412094781;

        requestIdToResult[_requestId] = additionalResult;
        requestIdToCaller[_requestId] = caller;

        delete requestIdToCaller[_requestId];
    }
}
