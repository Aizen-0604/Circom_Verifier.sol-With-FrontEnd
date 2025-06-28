// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Chainlink VRF contracts
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title SepoliaVRFConsumer
 * @notice A Chainlink VRFv2 consumer that requests a single random number from the VRF coordinator.
 */
contract SepoliaVRFConsumer is VRFConsumerBaseV2 {
    // ───────── Immutable / Constant Configuration ─────────
    VRFCoordinatorV2Interface private immutable COORDINATOR;

    // Sepolia VRF v2 coordinator address
    address private constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;

    // Sepolia key hash (750 gwei gas lane)
    bytes32 private constant KEY_HASH = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    // ───────── Configurable Parameters ─────────
    uint32 public callbackGasLimit = 100000;         // Safe limit for most cases
    uint16 public requestConfirmations = 3;          // Minimum on Sepolia
    uint32 public numWords = 1;                      // How many random words to request

    // ───────── State Variables ─────────
    uint64 public subscriptionId;                    // Chainlink VRF Subscription ID
    uint256 public lastRequestId;                    // Last request ID
    uint256 public randomWord;                       // Latest random number

    // ───────── Constructor ─────────
    constructor(uint64 _subscriptionId) VRFConsumerBaseV2(VRF_COORDINATOR) {
        subscriptionId = _subscriptionId;
        COORDINATOR = VRFCoordinatorV2Interface(VRF_COORDINATOR);
    }

    // ───────── External Function to Request Randomness ─────────
    function requestRandomNumber() external returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        lastRequestId = requestId;
    }

    // ───────── Callback Function ─────────
    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        randomWord = randomWords[0]; // Only storing 1 word
    }
}
