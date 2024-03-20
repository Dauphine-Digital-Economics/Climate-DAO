### General Issues
**[Interaction] [Warning]** Mismatch of rewardAmount - Token contract takes 1 input. Governance Contract has an unused second.

**[Interaction] [Bug] [Major]** Different implementation of token and voting power definition in token and governance contracts. Voting power is not the same as token balance, especially since delegation does not physically transfer on the token contract. The deduct token function has been changed into a deduct voting power function.

**[Interaction] [Design]** The claim function is only applicable if delegation was based on token transfer. Currently it is only based on votingPower mapping change. Requires a change to deduct voting power instead. 

**[Interaction] [Bug]** There is an onlyOwner modifier on mint reward. Governance contract cannot call mint on the token contract unless voting contract deploys token contract. It currently only takes an address. 

**[Feature Request]** No onchain execution mechanism.

### Token Contract

**[Feature]** Minting is done only to the contract deployer. This gives power to the committee to transfer tokens in a controlled manner. Good!

**[Design] [Improvement]** There is no way for the committee to assign multiple countries voting power!! There are two ways but neither was completely implemented:
1. Transfer function - does not update votingPower mapping. A fix here is allow token holders to assign a part of their tokens to be voting tokens.
2. Delegate function - would assign all power to one delegatee country only. This means the parent holds the tokens, with no actual token transfer. Could extend delegate function to delegate to target addresses and involving a transfer of tokens if desired.

**[Bug] [Major]** revokeDelegate function does not zero the delegatee's voting power, resulting in duplicate votes. You have to track the delegator/delegatee relationship in order to zero the delegatee voting power.

**[Feature] [Improvement]** Interesting use of voting power and token balance in delegation. Would be good to comment extensively so other devs know how it is used.

### Governance Contract
**[Variable] [Consider Deletion]** IERC is an interface and the token variable (line 41) is not needed. MyToken is the contract instance which contains callable functions.

**[Feature]** setTokenContract function allows pointing/upgrading to a different contract. Very nice consideration! Definitely a good call to allow only the owner to call this.

**[Feature]** rewardVoter is internal. Are there plans for scaling in the future?

**[Variable] [Proposal struct]** Does the proposal struct need an exists field if its existence is controlled by the ProposalID?

**[Feature request] [Proposal struct]** You can only ban 1 country per proposal. Perhaps an array of addresses for multiple bans?

**[Design] [Bug]** The proposalId assignment can become quite a mess with a huge amount of proposals due to insufficient controls during creation. Consider the following cases:
1. A batch proposal is submitted with IDs 1,2,4 (no check in submitProposalBatch function). A follow up proposal is made by a member state. The ID assigned is totalProposal++ which is 3+1=4; This will result in a collision. The collision will cause the proposals mapping to overwritten. Perhaps there is an enforcement that batch proposals are all sequential?
2. A lot of follow up proposals are made. How to determine the start of next batch submission? Perhaps a requirement that the lowest proposalId is bigger than totalProposal?

**[Bug] [Minor]** votesbyVoter function, line 163 (original repo), has not voted should be an equality to zero vote count, not more than zero.

**[Bug] [Minor]** votesbyVoter function, line 160 (original repo), opposite condition. If NOT on the banned list, then allow.

**[Feature] [Improvement]** Currently the endVoting function ends all active proposals in the queue. Without proposal deletion, the proposals mapping will grow without limit over time, which may be an expected behaviour for audit purposes, but the endVote function will begin to take a linear amount of time longer. the events will also repeatedly emit past proposal events if called again. Better to end proposals individually? Or have a check to skip passed or empty proposal indices. See below.

**[Feature] [Improvement]** The endVote function uses totalProposal variable in the for loop. If there are any gaps in the proposalIds, we would waste an iteration. This can be seen in the testEndVoting (see line 101 in this repo). At index zero, everything will return zero because we started with proposalId 1.

**[Feature request] [Proposal struct]** Use a passed flag to skip over iteration early in endVote.

**[Bug] [SEVERE]** Introduced a mathematical vulnerability in endVote function. Quorum is calculated as passed/(passed+failed). If failed is 0, any pass vote will result in a pass!
