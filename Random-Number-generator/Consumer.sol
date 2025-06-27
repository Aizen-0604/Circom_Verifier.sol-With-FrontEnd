// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract SepoliaVRFConsumer is VRFConsumerBaseV2 {
    /* ──────────── immutable/constant config ──────────── */
    VRFCoordinatorV2Interface private immutable COORDINATOR;

    // Sepolia VRF-v2 coordinator & keyHash (750 gwei) 
    address private constant VRF_COORDINATOR =
        0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;          // :contentReference[oaicite:0]{index=0}
    bytes32 private constant KEY_HASH =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c; // :contentReference[oaicite:1]{index=1}

    /* ──────────── user-tunable params ──────────── */
    uint32  public  callbackGasLimit   = 100_000; // enough for a simple store
    uint16  public  requestConfirmations = 3;     // Sepolia minimum
    uint32  public  numWords           = 1;       // we only need one random uint

    /* ──────────── state ──────────── */
    uint64  public  subscriptionId;   // passed in at deployment
    uint256 public  lastRequestId;
    uint256 public  randomWord;       // latest random value

    /* ──────────── constructor ──────────── */
    constructor(uint64 _subscriptionId)
        VRFConsumerBaseV2(VRF_COORDINATOR)
    {
        subscriptionId = _subscriptionId;
        COORDINATOR    = VRFCoordinatorV2Interface(VRF_COORDINATOR);
    }

    /* ──────────── external API ──────────── */
    /// @notice Requests one random uint256.  Emits standard VRF events.
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

    /* ──────────── callback (called by coordinator) ──────────── */
    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        randomWord = randomWords[0];
    }
}

