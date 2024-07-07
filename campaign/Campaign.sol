// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;

/**
 * @title Campaign
 * @dev A contract to manage crowdfunding campaigns.
 */
contract Campaign {
    ///New Campaign request struct
    struct Request {
        //Campaign description
        string description;
        //Campaign value in ETH
        uint value;
        //Campaign amount recipient
        address payable recipient;
        //Did campaign complete
        bool complete;
        //Was campaign approved
        uint approvalCount;
        //List of request approver addresses and approval status
        //this is request specific, for main contract see other mapping below
        mapping(address => bool) approvals;
    }

    // Mapping to store requests
    mapping(uint => Request) public requests;

    // counter
    uint numRequests;

    // Campaign manager contract address
    address public manager;

    // Campaign minimum contribution
    uint public minimumContribution;

    //List of approver addresses and approval status
    mapping(address => bool) public approvers;

    //Approvers count
    uint public approversCount;

    /**
     * @dev Modifier to restrict access to manager only.
     */
    modifier restricted() {
        require(msg.sender == manager, "Only manager can call this function.");
        _;
    }

    /**
     * @dev Constructor to initialize the campaign with a minimum contribution and creator address.
     * @param minimum The minimum contribution amount.
     * @param creator The address of the campaign creator.
     */
    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    /**
     * @notice Allows contributors to participate in the campaign by contributing funds.
     * @dev Adds the contributor to the approvers mapping and increments the approvers count.
     */
    function contribute() public payable {
        require(
            msg.value > minimumContribution,
            "Contribution is less than the minimum required."
        );

        approvers[msg.sender] = true;
        approversCount++;
    }

    /**
     * @notice Creates a new spending request.
     * @dev Only callable by the manager. Initializes a new request.
     * @param description A description of the request.
     * @param value The amount of money requested.
     * @param recipient The address to receive the funds if the request is approved.
     */
    function createRequest(
        string memory description,
        uint value,
        address payable recipient
    ) public restricted {
        Request storage r = requests[numRequests++];
        r.description = description;
        r.value = value;
        r.recipient = recipient;
        r.complete = false;
        r.approvalCount = 0;
    }

    /**
     * @notice Approves a spending request.
     * @dev A contributor can approve a request only once.
     * @param index The index of the request to be approved.
     */
    function approveRequest(uint index) public {
        Request storage request = requests[index];

        require(
            approvers[msg.sender],
            "You must be a contributor to approve requests."
        );
        require(
            !request.approvals[msg.sender],
            "You have already approved this request."
        );

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    /**
     * @notice Finalizes a spending request and transfers the funds to the recipient.
     * @dev The request must have more than 50% approval and must not be complete.
     * @param index The index of the request to be finalized.
     */
    function finalizeRequest(uint index) public {
        Request storage request = requests[index];

        require(
            request.approvalCount > (approversCount / 2),
            "Not enough approvals."
        );
        require(!request.complete, "Request is already complete.");

        request.recipient.transfer(request.value);
        request.complete = true;
    }

    /**
     * @notice Returns a summary of the campaign.
     * @dev Provides details about the campaign including minimum contribution, balance, number of requests, approvers count, and manager address.
     * @return A tuple containing the minimum contribution, balance, number of requests, approvers count, and manager address.
     */
    function getSummary()
        public
        view
        returns (uint, uint, uint, uint, address)
    {
        return (
            minimumContribution,
            address(this).balance,
            numRequests,
            approversCount,
            manager
        );
    }

    /**
     * @notice Returns the total number of requests.
     * @return The number of requests.
     */
    function getRequestsCount() public view returns (uint) {
        return numRequests;
    }
}
