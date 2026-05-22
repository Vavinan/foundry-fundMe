//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_ETH_VALUE = 10 ether;
    //uint256 constant GAS_PRICE = 1;

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_ETH_VALUE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public{
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));
        // assertEq(fundMe.i_owner(), address(this)); // if deployed within test code
        assertEq(fundMe.getOwner(), msg.sender); // if deployed using script code
    }

    function testPriceFeedVersionisAccurate() public{
        uint256 version = fundMe.getVersion(); //unit testing and integration testing
        assertEq(version, 4);
    }

    function  testFundFailsWithoutEnoughFund() public{
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded{
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded{

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();      
    }

    function testWithdrawWithSingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunder() public funded{
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        //ACT
        //uint256 gasStarting = gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        //uint256 gasLeft = gasleft();
        //uint256 gasUsed = (gasStarting - gasLeft)*tx.gasprice;
        //console.log("Gas Used: ", gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunderWithCheaperWithdraw() public funded{
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        //ACT
        //uint256 gasStarting = gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        //uint256 gasLeft = gasleft();
        //uint256 gasUsed = (gasStarting - gasLeft)*tx.gasprice;
        //console.log("Gas Used: ", gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance); 
    }
}

/*
What can we do to work with address outside our system?
1.Unit: testing a specific part
2.Integration: testing how different parts work together
3.Forked: tetsing our code in a simulated real environment
4.Staging: testing in a real environment that is not a production environment

*/
