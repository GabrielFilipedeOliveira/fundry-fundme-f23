// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external{
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimunDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public{
        assertEq(fundMe.getOwner(),msg.sender);
    }

/* What can we worked whith address outside our sistem?
1.Unit
    - Testing a specific part of our code.

2.Integration
    - Testing how our code interacts with other  parts of our code.

3.Forked
    - Testing our code on a simulated real environment.

4.Staging
    - Testing our code in a real enviraonment that is not prod */

    function testPriceFeedVersionIsAccurate() public{
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
    
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //hey, the next line, should revert
        fundMe.fund(); //send 0 ETH
    }
    
    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER); //the next tx will be sent by USER
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAnountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }

    function testAddsFundersToArrayOfFunders()public{
        vm.prank(USER); //the next tx will be sent by USER
        fundMe.fund{value:SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        assertEq(funder,USER);
    }

    modifier funded(){
        vm.prank(USER); //the next tx will be sent by USER
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        
        //Assert
        uint256 endingOwnerBalance =fundMe.getOwner().balance;
        uint256 endingFundBalance = address(fundMe).balance;
        
        assertEq(endingFundBalance, 0);
        assertEq(startingFundBalance+startingOwnerBalance,endingOwnerBalance);

    }

    function testWithDrawFromAMutipleFundersCheaper() public funded{
        //Arrange
        //para gerar um address de um numero deve se usar uint160, pois o numero de bytes sao os mesmos
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1;

        for (uint160 i=startingFunderIndex; i < numberOfFunders; i++){
            
            hoax(address(i),SEND_VALUE);//faz a funcao do cheatcode prank e deal ao mesmo tempo e recebe um valor e um endereço
            fundMe.fund{value:SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundBalance = address(fundMe).balance;


        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();


        //Arrange
        assert(address(fundMe).balance ==0);
        assert(startingFundBalance+startingOwnerBalance==fundMe.getOwner().balance);
    }

    function testWithDrawFromAMutipleFunders() public funded{
        //Arrange
        //para gerar um address de um numero deve se usar uint160, pois o numero de bytes sao os mesmos
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1;

        for (uint160 i=startingFunderIndex; i < numberOfFunders; i++){
            
            hoax(address(i),SEND_VALUE);//faz a funcao do cheatcode prank e deal ao mesmo tempo e recebe um valor e um endereço
            fundMe.fund{value:SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundBalance = address(fundMe).balance;


        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();


        //Arrange
        assert(address(fundMe).balance ==0);
        assert(startingFundBalance+startingOwnerBalance==fundMe.getOwner().balance);
    }
}



  