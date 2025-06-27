 One-page Remix deployment & test checklist
#	Action	Details
1	Get test assets         	Grab Sepolia ETH and LINK from faucets.chain.link. LINK token contract on Sepolia: 0x779877A7B0D9E8603169DdbD7836e478b4624789 
docs.chain.link

2	Create a VRF subscription	Go to https://vrf.chain.link/sepolia, click “Create Subscription”, copy the new subscription ID.

3	Fund the subscription	    Click “Add Funds” → fund with e.g. 2 LINK.

4	Compile contract	        In Remix → File SepoliaVRFConsumer.sol → compiler 0.8.20 or newer → Compile.

5	Deploy	                  “Deploy & Run” → Environment Injected Provider – MetaMask (Sepolia) → paste your subscriptionId in the constructor field → Deploy.

6	Add consumer	            In the VRF UI, open your subscription → “Add consumer” → paste your newly deployed contract address, confirm.

7	Request randomness	      In Remix, expand the contract → click requestRandomNumber(). One TX is sent.

8	Wait for fulfilment     	After ~2-3 blocks, the coordinator calls fulfillRandomWords. Click randomWord to read the fresh random value.

9	Troubleshoot	            • Make sure the contract is a consumer on the subscription.
                            • Ensure the subscription has enough LINK.
                            • Check Etherscan logs for RandomWordsRequested / RandomWordsFulfilled events.
