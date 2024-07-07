// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;

import "./Campaign.sol";

/**
 * @title CampaignFactory
 * @dev Factory contract to create and manage multiple Campaign contracts.
 */
contract CampaignFactory {
    address[] public deployedCampaigns;

    /**
     * @notice Creates a new Campaign contract.
     * @dev Deploys a new Campaign contract with the specified minimum contribution and stores its address.
     * @param minimum The minimum contribution required for the new campaign.
     */
    function createCampaign(uint minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(address(newCampaign));
    }

    /**
     * @notice Returns a list of all deployed Campaign contracts.
     * @return An array of addresses of deployed Campaign contracts.
     */
    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}
