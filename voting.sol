// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Voting {
    bool public isVoting; //indicates whether the voting process is active or not

    struct Vote {
        address receiver; //address of the candidate receiving the vote
        uint timeStamp; //timestamp when the vote was cast
    }

    address public administrator; //address of the contract administrator

    //mapping to store whether an address is a registered voter
    mapping(address => bool) public voters;
    //mapping to store the vote cast by each voter
    mapping(address => Vote) public votes;
    //mapping to track whether a voter has already voted.
    mapping(address => bool) public hasVoted;
    //mapping to count the number of votes received by each candidate.
    mapping(address => uint) public voteCount;
    //mapping to store candidate information based on their address.
    mapping(address => Candidate) public candidates;

    //event emitted when a vote is cast.
    event AddVote(address indexed voter, address receiver, uint timeStamp);
    //event emitted when a vote is removed.
    event RemoveVote(address voter);
    //event emitted when the voting process starts.
    event StartVoting(address startedBy);
    //event emitted when the voting process stops.
    event StopVoting(address stoppedBy);

    //struct to represent candidate information.
    struct Candidate {
        string name;
        bool isRegistered;
    }

    //constructor to initialize the contract with the administrator and set voting status to inactive.
    constructor() {
        administrator = msg.sender;
        isVoting = false;
    }

    //modifier to restrict access to only the contract administrator.
    modifier onlyAdmin() {
        require(
            msg.sender == administrator,
            "Only an Admin may carry out this task"
        );
        _;
    }

    //modifier to restrict access to only registered voters.
    modifier onlyVoter() {
        require(voters[msg.sender], "Only registered Voters may vote");
        _;
    }

    //function to register a candidate by the administrator.
    function registerCandidate(
        address candidateAddress,
        string memory name
    ) external onlyAdmin {
        require(
            !candidates[candidateAddress].isRegistered,
            "Candidate is already registered"
        );

        candidates[candidateAddress] = Candidate(name, true);
    }

    //function to unregister a candidate by the administrator.
    function unregisterCandidate(address candidateAddress) external onlyAdmin {
        require(
            candidates[candidateAddress].isRegistered,
            "Candidate is not registered"
        );

        candidates[candidateAddress].isRegistered = false;
    }

    //function to register a voter by the administrator.
    function registerVoter(address voter) external onlyAdmin {
        voters[voter] = true;
    }

    //function to start the voting process by the administrator.
    function startVoting() external onlyAdmin returns (bool) {
        isVoting = true;
        emit StartVoting(msg.sender);
        return true;
    }

    //function to stop the voting process by the administrator.
    function stopVoting() external onlyAdmin returns (bool) {
        isVoting = false;
        emit StopVoting(msg.sender);
    }

    //function to cast a vote for a candidate by a registered voter.
    function addVote(address receiver) external onlyVoter returns (bool) {
        require(!hasVoted[msg.sender], "You have already voted");
        require(
            candidates[receiver].isRegistered,
            "Candidate is not registered"
        );
        votes[msg.sender].receiver = receiver;
        votes[msg.sender].timeStamp = block.timestamp;

        hasVoted[msg.sender] = true; //Marks the voter as having voted

        voteCount[receiver]++;

        emit AddVote(msg.sender, receiver, block.timestamp);
        return true;
    }

    //function to remove a vote by a registered voter.
    function removeVote() external onlyVoter returns (bool) {
        address voter = msg.sender;
        address receiver = votes[voter].receiver;

        require(hasVoted[voter], "You have not voted");

        voteCount[receiver]--;

        delete votes[voter];
        hasVoted[voter] = false;

        emit RemoveVote(msg.sender);
        return true;
    }

    //function to get the candidate selected by a voter.
    function getVote(
        address voterAddress
    ) external view returns (address candidateAddress) {
        return votes[voterAddress].receiver;
    }
}
