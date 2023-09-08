//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {PointTracker} from "../../src/core/PointTracker.sol";

contract PointTrackerTest is Test {
    PointTracker public pointTracker;

    address public PLAYER = makeAddr("player");
    address public MANAGER = makeAddr("manager");
    address public OWNER = makeAddr("owner");
    address public BAD_ACTOR = makeAddr("bad_actor");

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant SEASON_DURATION = 30 days;
    uint256 public endOfSeason;

    function setUp() external {
        vm.prank(OWNER);
        pointTracker = new PointTracker(MANAGER);

        endOfSeason = block.timestamp + SEASON_DURATION;

        vm.deal(MANAGER, STARTING_USER_BALANCE);
        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    modifier seasonStarted() {
        vm.prank(OWNER);
        pointTracker.startSeason(endOfSeason);
        _;
    }

    //////////////////////
    //   startSeason    //
    //////////////////////

    function testStartSeasonIsCalculating() external {
        //Arrange

        vm.prank(OWNER);

        //Act
        pointTracker.startSeason(endOfSeason);

        //assert
        assertEq(endOfSeason, pointTracker.getSeasonEndDate());
        assertEq(1, pointTracker.getLatestSeason());
    }

    function testStartSeasonFailedWhenNotCalledFromOwner() external {
        //Arrange
        vm.prank(BAD_ACTOR);

        vm.expectRevert(bytes("Ownable: caller is not the owner"));

        //Act + Assert
        pointTracker.startSeason(endOfSeason);
    }

    //////////////////////
    //   finishSeason   //
    //////////////////////

    function testFinishSeasonIsCalculating() external seasonStarted {
        //Arrange

        vm.warp(endOfSeason + 1);
        vm.roll(block.number + 1);

        //Act
        vm.prank(OWNER);
        pointTracker.finishSeason();
    }

    function testFinishSeasonFailedWhenTheEndOfSeasonDidntPass() external seasonStarted {
        //Act + Assert
        vm.expectRevert(PointTracker.PointTracker__NotEndOfSeasonReached.selector);

        vm.prank(OWNER);
        pointTracker.finishSeason();
    }

    //////////////////////
    // activateAccount  //
    //////////////////////

    function testActivateAccountIsCalculating() external seasonStarted {
        //Arrange
        vm.prank(PLAYER);

        //Act
        pointTracker.activateAccount();

        //Assert

        uint256 points = pointTracker.getPlayerPoints(1, PLAYER);
        assertEq(points, 100);
    }

    function testActivateAccountFailedWhenCallerHasNotEnoughETH() external seasonStarted {
        //Arrange
        vm.deal(PLAYER, 0);
        vm.prank(PLAYER);

        //Act + Assert

        vm.expectRevert(PointTracker.PointTracker__AccountNotEligible.selector);
        pointTracker.activateAccount();
    }

    function testActivateAccountFailedWhenAccountAlreadyActivated() external seasonStarted {}

    ////////////////////////
    // addPointsForPlayer //
    ////////////////////////

    ///////////////////////////
    // reducePointsForPlayer //
    ///////////////////////////
}
