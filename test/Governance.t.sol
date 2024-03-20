pragma solidity ^0.8.0;

import "forge-std/src/Test.sol";
import "../src/Token.sol";
import {ProposalVoting} from "../src/Governance.sol";

contract TestProposalVoting is Test {
    
    ProposalVoting private proposalVoting;
    MyToken private token;
    address[] private initialOwners;

    // This function runs before each test case to set up the contract
    function setUp() public {
        token = new MyToken(1000, msg.sender);
        initialOwners.push(address(1));
        initialOwners.push(address(2));
        proposalVoting = new ProposalVoting(initialOwners, address(token));
    }

    // Test for initial setup of the contract
    function testInitialSetup() public {
        assertEq(proposalVoting.totalProposals(), 0);
    }

    // Test for submitting a batch of proposals
    function testSubmitProposalBatch() public {
        uint256[] memory proposalIds = new uint256[](1);
        proposalIds[0] = 1;
        bool[] memory proposalTypes = new bool[](1);
        proposalTypes[0] = true;
        address[] memory bannedCountries = new address[](1);
        bannedCountries[0] = address(1);
        string[] memory titles = new string[](1);
        titles[0] = "Test Proposal";
        string[] memory summaries = new string[](1);
        summaries[0] = "Test Summary";


        proposalVoting.submitProposalBatch(proposalIds, proposalTypes, bannedCountries, titles, summaries);

        assertEq(proposalVoting.totalProposals(), 1);
    }

    // Test for submitting a follow-up proposal
    function testSubmitFollowUpProposal() public {
        // Committee creates new proposal
        uint256[] memory proposalIds = new uint256[](1);
        proposalIds[0] = 1;
        bool[] memory proposalTypes = new bool[](1);
        proposalTypes[0] = true;
        address[] memory bannedCountries = new address[](1);
        bannedCountries[0] = address(1);
        string[] memory titles = new string[](1);
        titles[0] = "Test Proposal";
        string[] memory summaries = new string[](1);
        summaries[0] = "Test Summary";
        proposalVoting.submitProposalBatch(proposalIds, proposalTypes, bannedCountries, titles, summaries);

        // Address 2 gets a country role and creates follow up proposal
        proposalVoting.grantRole(proposalVoting.COUNTRY_ROLE(), address(2));
        vm.prank(address(2));
        proposalVoting.submitFollowUpProposal(1, "Follow Up Proposal", "Follow Up Summary");

        assertEq(proposalVoting.totalProposals(), 2);
    }

    // Test for voting on a proposal
    function testVote() public {
        uint256[] memory proposalIds = new uint256[](1);
        proposalIds[0] = 1;
        bool[] memory proposalTypes = new bool[](1);
        proposalTypes[0] = true;
        address[] memory bannedCountries = new address[](1);
        bannedCountries[0] = address(1);
        string[] memory titles = new string[](1);
        titles[0] = "Test Proposal";
        string[] memory summaries = new string[](1);
        summaries[0] = "Test Summary";

        proposalVoting.submitProposalBatch(proposalIds, proposalTypes, bannedCountries, titles, summaries);
        
        // Address 2 gets a country role
        proposalVoting.grantRole(proposalVoting.COUNTRY_ROLE(), address(2));

        //Skip forward the time
        skip(30 hours);

        //Delegate power to address 2
        token.delegate(address(2));

        //Vote as Country 2 with country role
        vm.startPrank(address(2));
        proposalVoting.vote(1, 10, false);

        (uint votes,,,,,,,) = proposalVoting.proposals(1);
        assertEq(votes, 10);
    }

    // Test for ending the voting period
    function testEndVoting() public {
        uint256[] memory proposalIds = new uint256[](1);
        proposalIds[0] = 1;
        bool[] memory proposalTypes = new bool[](1);
        proposalTypes[0] = true;
        address[] memory bannedCountries = new address[](1);
        bannedCountries[0] = address(1);
        string[] memory titles = new string[](1);
        titles[0] = "Test Proposal";
        string[] memory summaries = new string[](1);
        summaries[0] = "Test Summary";

        proposalVoting.submitProposalBatch(proposalIds, proposalTypes, bannedCountries, titles, summaries);
        
        // Address 2 gets a country role
        proposalVoting.grantRole(proposalVoting.COUNTRY_ROLE(), address(2));

        //Skip forward the time
        skip(30 hours);

        //Delegate power to address 2
        token.delegate(address(2));

        //Vote as Country 2 with country role
        vm.prank(address(2));
        proposalVoting.vote(1, 10, false);

        //We expect a rever here because the governance contract is not the deployer / owner of token.
        vm.expectRevert();
        proposalVoting.endVoting();
    }

    // Test for claiming remaining tokens
    function testClaimRemainingTokens() public {
        // Test not applicable since it is based on voting power. claimRemainingPower would be more appropriate
        vm.expectRevert();
        proposalVoting.claimRemainingTokens();

    }
}
