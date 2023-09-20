//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {DefiBetsManager} from "../../src/core/DefiBetsManager.sol";
import {DefiBets} from "../../src/core/DefiBets.sol";
import {BTCPriceOracle} from "../../src/oracles/BTCPriceOracle.sol";
import {ImpliedVolatilityOracle} from "../../src/oracles/ImpliedVolatilityOracle.sol";
import {MathLibraryDefibets} from "../../src/lib/MathLibraryDefiBets.sol";
import {PointTracker} from "../../src/core/PointTracker.sol";

contract DefiBetsManagerTest is Test {
    DefiBetsManager public manager;

    DefiBets public defiBets;
    BTCPriceOracle public priceOracle;
    ImpliedVolatilityOracle public volaOracle;
    PointTracker public pointTracker;

    address public OWNER = makeAddr("owner");
    address public BAD_ACTOR = makeAddr("bad_actor");
    address public PLAYER = makeAddr("player");

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    string public constant PRICE_ORACLE_DESCRIPTION = "Price Oracle BTC";
    uint8 public constant PRICE_ORACLE_DECIMALS = 18;
    uint8 public constant VOLA_ORACLE_DECIMALS = 4;
    string public constant VOLA_ORACLE_DESCRIPTION = "Implied Volatility Oracle BTC";
    uint256 public constant VOLA_ORACLE_PERIOD = 30 days;

    uint256 public constant POINT_TRACKER_STARTING_POINTS = 1000;

    bytes32 underlyingByte;
    uint256 dependentTimeStamp;
    string underlying = "BTC";
    uint256 timeDelta = 1 days;
    uint256 underlyingPrice = 24500e18;
    uint256 betSize = 50;
    uint256 minPrice = 23900e18;
    uint256 maxPrice = 27600e18;
    uint256 underlyingVola = 2500;

    uint256 minBetDuration = 1 days;
    uint256 maxBetDuration = 30 days;
    uint256 slotSize = 100 ether;

    function setUp() external {
        vm.startPrank(OWNER);
        manager = new DefiBetsManager();

        defiBets = new DefiBets(underlying,address(manager),timeDelta);
        priceOracle = new BTCPriceOracle(PRICE_ORACLE_DECIMALS,PRICE_ORACLE_DESCRIPTION,1,underlying);
        volaOracle =
            new ImpliedVolatilityOracle(VOLA_ORACLE_DECIMALS,VOLA_ORACLE_DESCRIPTION,1,underlying,VOLA_ORACLE_PERIOD);
        pointTracker = new PointTracker(address(manager),POINT_TRACKER_STARTING_POINTS);
        underlyingByte = manager.getUnderlyingByte(underlying);
        vm.stopPrank();

        vm.deal(OWNER, STARTING_USER_BALANCE);
        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    /////////////////////////
    // addUnderlyingToken  //
    /////////////////////////

    function testAddUnderlyingTokenIsCalculating() external {
        //Arrange

        vm.prank(OWNER);

        //Act
        manager.addUnderlyingToken(underlying, address(priceOracle), address(defiBets));

        //assert

        assert(manager.validUnderlying(underlyingByte));
    }

    /////////////////////////
    // calculateWinning    //
    /////////////////////////

    modifier underlyingAndOraclesAdded() {
        vm.startPrank(OWNER);
        manager.addUnderlyingToken(underlying, address(priceOracle), address(defiBets));
        manager.updateIVFeed(underlyingByte, address(volaOracle), VOLA_ORACLE_PERIOD);
        volaOracle.updateAnswer(int256(underlyingVola));
        vm.stopPrank();
        _;
    }

    function testCalculateWinningIsCorrect() external underlyingAndOraclesAdded {
        //Arrange
        uint256 _expTime = block.timestamp + 4 days;

        uint256 probability = MathLibraryDefibets.calculateProbabilityRange(
            minPrice, maxPrice, underlyingPrice, underlyingVola, VOLA_ORACLE_PERIOD, _expTime - block.timestamp
        );
        console.log("The probability:", probability);

        uint256 winning =
            manager.calculateWinning(underlyingPrice, betSize, minPrice, maxPrice, _expTime, underlyingByte);

        console.log("The winning is", winning);
    }

    /////////////////////////
    //        setBet       //
    /////////////////////////
    modifier defiBetsInitialized() {
        dependentTimeStamp = block.timestamp;
        vm.startPrank(OWNER);
        manager.initializeBets(underlyingByte, dependentTimeStamp, minBetDuration, maxBetDuration, slotSize);
        for (uint256 i = 0; i < maxBetDuration / timeDelta; i++) {
            manager.createNewExpTime(underlyingByte);
        }
        vm.stopPrank();
        _;
    }

    modifier seasonActivated() {
        vm.prank(OWNER);
        pointTracker.startSeason(30 days);
        _;
    }

    modifier pointTrackerIsSet() {
        vm.prank(OWNER);
        manager.setPointTracker(address(pointTracker));
        _;
    }

    function testSetBetIsCalculating()
        external
        underlyingAndOraclesAdded
        defiBetsInitialized
        seasonActivated
        pointTrackerIsSet
    {
        uint256 expTime = dependentTimeStamp + 2 * timeDelta;
        vm.startPrank(OWNER);
        priceOracle.updateAnswer(int256(underlyingPrice));
        volaOracle.updateAnswer(int256(underlyingVola));
        vm.stopPrank();

        vm.startPrank(PLAYER);

        pointTracker.activateAccount();

        manager.setBet(betSize, minPrice, maxPrice, expTime, "BTC");

        vm.stopPrank();
    }
}
