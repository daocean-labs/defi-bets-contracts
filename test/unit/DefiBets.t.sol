//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {DefiBets} from "../../src/core/DefiBets.sol";

contract DefiBetsTest is Test {
    DefiBets public defiBets;

    address public PLAYER = makeAddr("player");
    address public MANAGER = makeAddr("manager");

    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    string underlying = "BTC";
    uint256 timeDelta = 1 days;
    uint256 dependentTimeStamp;
    uint256 minBetDuration = 1 days;
    uint256 maxBetDuration = 7 days;
    uint256 slot = 100e18;

    //Settings for bets
    uint256 public constant BET_SIZE = 100;
    uint256 public constant MIN_PRICE = 25000e18;
    uint256 public constant MAX_PRICE = 30000e18;
    uint256 public constant WINNING = 200;

    function setUp() external {
        defiBets = new DefiBets(underlying, MANAGER, timeDelta);

        dependentTimeStamp = block.timestamp;

        vm.deal(PLAYER, STARTING_USER_BALANCE);
        vm.deal(MANAGER, STARTING_USER_BALANCE);
    }

    modifier isInitialized() {
        vm.prank(MANAGER);
        defiBets.initializeData(dependentTimeStamp, minBetDuration, maxBetDuration, slot);
        _;
    }

    //////////////////////
    // setBetForAccount //
    //////////////////////

    function testSetBetForAccountIsCalculating() external isInitialized {
        //Arrange
        uint256 expTimeAdds = 3;
        vm.startPrank(MANAGER);
        for(uint256 i = 0;i < expTimeAdds;i++){
            defiBets.initializeNewExpTime();
        }
        uint256 expTime = defiBets.timeDelta() * 3 + dependentTimeStamp;
        vm.stopPrank();

        //Act
        vm.prank(MANAGER);
        defiBets.setBetForAccount(PLAYER, BET_SIZE, MIN_PRICE, MAX_PRICE, expTime, WINNING);
        DefiBets.Bet memory bet = defiBets.getBetData(1);

        //Assert
        assertEq(bet.account, PLAYER);
        assertEq(bet.betSize, BET_SIZE);
        assertEq(bet.expTime, expTime);
        assertEq(bet.claimed, false);
    }

    function testSetBetForAccountFailedWhenNotInitialized() external {
        //Arrange
        vm.prank(MANAGER);

        //Act + Assert
        vm.expectRevert(DefiBets.DefiBets__ParameterNotInitialized.selector);

        defiBets.setBetForAccount(PLAYER, BET_SIZE, MIN_PRICE, MAX_PRICE, 10, WINNING);
    }
}
