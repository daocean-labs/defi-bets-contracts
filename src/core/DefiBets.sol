//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interface/core/IDefiBets.sol";

contract DefiBets is Ownable, IDefiBets {
    /* === Errors === */
    error DefiBets__Forbidden();
    error DefiBets__NoValidExpTime();
    error DefiBets__NoValidPrice();
    error DefiBets__NoValidWinningPrice();
    error DefiBets__OutOfActiveExpTimeRange();
    error DefiBets__AlreadyInitialized();
    error DefiBets__ParameterNotInitialized();
    error DefiBets_NoValidParamters();
    error DefiBets__TokenDontExists();
    error DefiBets__NotExecutableTime();
    error DefiBets__NotTheTokenOwner();
    error DefiBets__NotEpxired();
    error DefiBets__NotActive();
    error DefiBets__AlreadyClaimed();

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    struct ExpTimeInfo {
        uint256 expPrice;
        uint256 slotSize;
        bool finished;
        bool init;
    }

    struct Bet {
        address account;
        uint256 expTime;
        uint256 betSize;
        uint256 profit;
        uint256 minPrice;
        uint256 maxPrice;
        bool claimed;
    }

    uint256 private constant MULTIPLIER = 1000000;

    /* ====== State Variables ====== */
    Counters.Counter public betIDs;
    string public underlying;
    bool private initialized;
    uint256 public minBetDuration;
    uint256 public maxBetDuration;
    uint256 public slot; /* Steps of valid bet prices */
    uint256 public timeDelta;

    bool public isActive;

    //All mappings can be searched with the expiration date.
    uint256 private dependentTimeStamp;
    uint256 public lastActiveExpTime;
    mapping(uint256 => bool) private validExpTime;
    mapping(uint256 => ExpTimeInfo) public expTimeInfos;
    mapping(uint256 => Bet) private bets;

    mapping(uint256 => mapping(uint256 => uint256)) public betsWinningSlots;

    address public defiBetsManager;

    /* ====== Events ====== */
    event EpxirationTimeCreated(uint256 expTime);

    event BetPlaced(
        address indexed account,
        uint256 betSize,
        uint256 profit,
        uint256 expDate,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 betID
    );
    event Claimed(address indexed account, uint256 betID, bool profit);
    event Expiration(uint256 indexed expTime, uint256 expPrice);
    event BetParameterUpdated(
        uint256 minBetDuration, uint256 maxBetDuration, uint256 slot, uint256 timeDelta, uint256 dependentTimeStamp
    );

    /**
     * @param _defiBetsManager - the manager and owner of the contract.
     */
    constructor(string memory _underlying, address _defiBetsManager, uint256 _timeDelta) {
        underlying = _underlying;

        defiBetsManager = _defiBetsManager;

        isActive = true;

        timeDelta = _timeDelta; // 60 * 60 * 24  = 24 h
    }

    /* ====== Mutation Functions ====== */
    function setBetForAccount(
        address _account,
        uint256 _betSize,
        uint256 _minPrice,
        uint256 _maxPrice,
        uint256 _expTime,
        uint256 _winning
    ) external {
        _isDefiBetManager();
        _isInitialized();

        // validate input paramaters
        _validExpirationTime(_expTime);
        _isValidActiveTimeRange(_expTime);
        _validPriceRange(_minPrice, _maxPrice);

        _createBetData(_account, _expTime, _betSize, _winning, _minPrice, _maxPrice);

        //Attention: This function has high gas costs!!!!
        _distributeWinningsToSlots(_minPrice, _maxPrice, _winning, _expTime);

        emit BetPlaced(_account, _betSize, _winning, _expTime, _minPrice, _maxPrice, betIDs.current());
    }

    function claimForAccount(address _account, uint256 _betID) external returns (uint256, bool) {
        _isDefiBetManager();
        _isClaimed(_betID);

        Bet memory _betTokenInfo = getBetData(_betID);
        ExpTimeInfo memory _expInfo = expTimeInfos[_betTokenInfo.expTime];

        if (_expInfo.finished != true) {
            revert DefiBets__NotEpxired();
        }

        if (ownerOf(_betID) != _account) {
            revert DefiBets__NotTheTokenOwner();
        }

        uint256 _tokensForClaim;
        bool _profits;

        if (_expInfo.expPrice >= _betTokenInfo.minPrice && _expInfo.expPrice < _betTokenInfo.maxPrice) {
            _tokensForClaim = _betTokenInfo.profit;

            _profits = true;
        }

        bets[_betID].claimed = true;

        emit Claimed(_account, _betID, _profits);

        return (_tokensForClaim, _profits);
    }

    function performExpiration(uint256 _expTime, uint256 _expPrice) external {
        _isDefiBetManager();
        _isInitialized();

        _validExpirationTime(_expTime);

        if (_expTime > block.timestamp) {
            revert DefiBets__NotExecutableTime();
        }

        //update the data

        expTimeInfos[_expTime].finished = true;
        expTimeInfos[_expTime].expPrice = _expPrice;

        emit Expiration(_expTime, _expPrice);
    }

    function initializeNewExpTime() external {
        _isDefiBetManager();

        _isActive();

        _isNextExpTimeValid();

        uint256 _expTime = dependentTimeStamp > lastActiveExpTime
            ? dependentTimeStamp.add(timeDelta)
            : lastActiveExpTime.add(timeDelta);

        _initExpTime(_expTime);

        lastActiveExpTime = _expTime;
    }

    /* ====== Setup Function ====== */

    function initializeData(
        uint256 _dependentTimeStamp,
        uint256 _minBetDuration,
        uint256 _maxBetDuration,
        uint256 _slot
    ) external {
        _isDefiBetManager();

        _isNotIntialized();

        setBetParamater(_minBetDuration, _maxBetDuration, _slot, timeDelta, _dependentTimeStamp);

        _initializeExpTimes();

        initialized = true;
    }

    function setBetParamater(
        uint256 _minBetDuration,
        uint256 _maxBetDuration,
        uint256 _slot,
        uint256 _timeDelta,
        uint256 _dependentTimeStamp
    ) public {
        _isDefiBetManager();
        if (_minBetDuration >= _maxBetDuration) {
            revert DefiBets_NoValidParamters();
        }

        minBetDuration = _minBetDuration;
        maxBetDuration = _maxBetDuration;
        slot = _slot;
        timeDelta = _timeDelta;
        dependentTimeStamp = _dependentTimeStamp;

        emit BetParameterUpdated(minBetDuration, maxBetDuration, slot, timeDelta, dependentTimeStamp);
    }

    function stop() external onlyOwner {
        isActive = false;
    }

    /* ====== Internal Functions ====== */

    function _createBetData(
        address _account,
        uint256 _expTime,
        uint256 _betSize,
        uint256 _winning,
        uint256 _minPrice,
        uint256 _maxPrice
    ) internal {
        betIDs.increment();
        uint256 newTokenId = betIDs.current();

        Bet memory _newBet;

        _newBet.account = _account;
        _newBet.betSize = _betSize;
        _newBet.minPrice = _minPrice;
        _newBet.maxPrice = _maxPrice;
        _newBet.profit = _winning;
        _newBet.expTime = _expTime;

        bets[newTokenId] = _newBet;
    }

    function _distributeWinningsToSlots(uint256 _minPrice, uint256 _maxPrice, uint256 _winning, uint256 _expTime)
        internal
    {
        uint256 _slotAmount = (_maxPrice.sub(_minPrice)).div(slot);

        for (uint256 i = 0; i < _slotAmount; i++) {
            uint256 _slot = _minPrice.add(i.mul(slot));

            uint256 _slotWinning = betsWinningSlots[_expTime][_slot];

            betsWinningSlots[_expTime][_slot] = _slotWinning.add(_winning);
        }
    }

    function _isDefiBetManager() internal view {
        if (msg.sender != defiBetsManager) {
            revert DefiBets__Forbidden();
        }
    }

    function _validExpirationTime(uint256 _expTime) internal view {
        if (expTimeInfos[_expTime].init != true) {
            revert DefiBets__NoValidExpTime();
        }
    }

    function _isValidActiveTimeRange(uint256 _expTime) internal view {
        if (_expTime < block.timestamp.add(minBetDuration) || _expTime > block.timestamp.add(maxBetDuration)) {
            revert DefiBets__OutOfActiveExpTimeRange();
        }
    }

    function _validPriceRange(uint256 minPrice, uint256 maxPrice) internal view {
        if ((0 != (minPrice % slot)) || (0 != (maxPrice % slot)) || (minPrice >= maxPrice)) {
            revert DefiBets__NoValidPrice();
        }
    }

    function _isNotIntialized() internal view {
        if (initialized) {
            revert DefiBets__AlreadyInitialized();
        }
    }

    function _isActive() internal view {
        if (isActive == false) {
            revert DefiBets__NotActive();
        }
    }

    function _initializeExpTimes() internal {
        uint256 _timeSteps = (maxBetDuration.sub(minBetDuration)).div(timeDelta);

        for (uint256 i = 0; i < _timeSteps; i++) {
            uint256 _expTime = dependentTimeStamp.add(timeDelta.mul(i));

            _initExpTime(_expTime);
        }

        lastActiveExpTime = dependentTimeStamp.add(timeDelta.mul(_timeSteps.sub(1)));
    }

    function _initExpTime(uint256 _expTime) internal {
        expTimeInfos[_expTime].init = true;
        expTimeInfos[_expTime].slotSize = slot;

        emit EpxirationTimeCreated(_expTime);
    }

    function _isInitialized() internal view {
        if (initialized != true) {
            revert DefiBets__ParameterNotInitialized();
        }
    }

    function _isNextExpTimeValid() internal view {
        uint256 _nextExpTime = lastActiveExpTime.add(timeDelta);
        if (_nextExpTime > block.timestamp.add(maxBetDuration)) {
            revert DefiBets__OutOfActiveExpTimeRange();
        }
    }

    function _isClaimed(uint256 _tokenId) internal view {
        if (bets[_tokenId].claimed) {
            revert DefiBets__AlreadyClaimed();
        }
    }

    /* ====== Pure/View Functions ====== */

    function getDependentExpTime() public view returns (uint256) {
        return dependentTimeStamp;
    }

    function getBetData(uint256 _betID) public view returns (Bet memory) {
        if (_betID > betIDs.current()) {
            revert DefiBets__TokenDontExists();
        }

        return bets[_betID];
    }

    function ownerOf(uint256 _betID) public view returns (address) {
        return bets[_betID].account;
    }
}
