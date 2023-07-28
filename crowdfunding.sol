// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Crowdfunding is Pausable, Ownable{
    using SafeMath for uint;

    struct Project {
        address payable creator;
        uint deadline;
        uint goal;
        uint amountRaised;
        bool withdrawn;
        mapping(address => uint) contributions;
    }

    Project[] private projects;

    function createProject(uint durationInDays, uint goalAmount) public whenNotPaused {
        uint deadline = block.timestamp + (durationInDays * 1 days);

        projects.push();
        Project storage newProject = projects[projects.length - 1];
        newProject.creator = payable(msg.sender);
        newProject.deadline = deadline;
        newProject.goal = goalAmount;
        newProject.amountRaised = 0;
        newProject.withdrawn = false;

}    

    function contribute(uint projectId) public payable whenNotPaused {
        Project storage project = projects[projectId];
        require(block.timestamp < project.deadline, "Project is already over");
        require(msg.value.add(project.amountRaised) <= project.goal, "Can't exceed project's goal");

        project.amountRaised = project.amountRaised.add(msg.value);
        project.contributions[msg.sender] = project.contributions[msg.sender].add(msg.value);
    }

    function withdraw(uint projectId) public whenNotPaused {
        Project storage project = projects[projectId];
        require(msg.sender == project.creator, "Only project creator can withdraw funds");
        require(!project.withdrawn, "Funds have already been withdrawn");
        require(project.amountRaised >= project.goal, "Project goal has not been met");
        require(block.timestamp >= project.deadline, "Project is not yet over");

        project.withdrawn = true;
        project.creator.transfer(project.amountRaised);
    }

    function checkGoalReached(uint projectId) public view returns (bool) {
        Project storage project = projects[projectId];
        return (project.amountRaised >= project.goal);
    }

    function getProjectCount() public view returns (uint) {
        return projects.length;
    }

    // owner can pause the contract operations in case of bug detection or an attack
    function pause() public onlyOwner {
        _pause();
    }

    // owner can resume the contract operations
    function unpause() public onlyOwner {
        _unpause();
    }
}
