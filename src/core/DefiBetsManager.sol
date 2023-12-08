//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interface/core/IDefiBets.sol";
import "../interface/core/IPointTracker.sol";

// Library import
import "../lib/MathLibraryDefiBets.sol";

error DefiBetsManager__NoValidUnderlying();
error DefiBetsManager__NoLiquidity();
error DefiBetsManager__FeeNotAllowed();
error DefiBetsManager__FeeWouldBeTooSmall();
error DefiBetsManager__ParamNull();
error DefiBetsManager__NotValidRoundId();
error DefiBetsManager__AccessForbidden();
error DefiBetsManager__ExpTimeNotValid();
error DefiBetsManager__NoPointTrackerSet();

/**
 * @title DefiBets Manager Contract
 * @notice This contract controls the main functions of the protocol, allowing users to interact with the decentralized betting platform. It manages liquidity, bets, winnings, and expiration of bets.
 */
contract DefiBetsManager is Pausable, Ownable {
    using SafeMath for uint256;

    struct IVFeed {
        address feedAddress;
        uint256 period;
    }

    uint256 public constant MULTIPLIER = 10000;

    /* ====== State Variables ====== */

    address public pointTracker;

    mapping(bytes32 => IVFeed) public underlyingIVFeeds;
    mapping(bytes32 => address) public underlyingPriceFeeds;
    mapping(bytes32 => bool) public validUnderlying;
    mapping(bytes32 => address) public defiBetsContracts;

    /* ====== Events ====== */
    event UnderlyingAdded(string underlying, bytes32 underlyingHash, address defiBets);
    event PriceFeedUpdated(bytes32 underlying, address priceFeed);
    event FeeUpdated(uint256 feePpm);
    event IVFeedUpdated(bytes32 underlying, address feed, uint256 period);
    event PayoutFactorUpdated(uint256 payoutFactor);

    /* ====== Modifier ====== */

    constructor() {}

    /* ======= Mutation Functions ====== */

    /**
     *
     * @dev Sets a bet for a user in the decentralized betting platform.
     * @param _betSize The size of the bet.
     * @param _minPrice The minimum price for the bet.
     * @param _maxPrice The maximum price for the bet.
     * @param _expTime The expiration time for the bet.
     * @param _underlying The underlying asset for the bet.
     */
    function setBet(uint256 _betSize, uint256 _minPrice, uint256 _maxPrice, uint256 _expTime, string memory _underlying)
        external
        whenNotPaused
    {
        bytes32 _hash = getUnderlyingByte(_underlying);
        _isValidUnderlying(_hash);
        _isPointTrackerSet();

        if (_expTime > IPointTracker(pointTracker).getSeasonEndDate()) {
            revert DefiBetsManager__ExpTimeNotValid();
        }

        //TODO: Check if the account has enough points

        uint256 _price = getCurrPrice(_hash);

        uint256 _winning = calculateWinning(_price, _betSize, _minPrice, _maxPrice, _expTime, _hash);

        address _defiBets = defiBetsContracts[_hash];

        _executeBetForAccount(_defiBets, _betSize, _minPrice, _maxPrice, _expTime, _winning);

        IPointTracker(pointTracker).reducePointsForPlayer(msg.sender, _betSize);
    }

    /**
     * @dev Claims the winnings for a user based on a specified token ID and underlying asset hash.
     * @param _tokenId The token ID representing the bet.
     * @param _hash The hash of the underlying asset for the bet.
     */
    function claimWinnings(uint256 _tokenId, bytes32 _hash) external whenNotPaused {
        _isPointTrackerSet();
        address _defiBets = defiBetsContracts[_hash];

        (uint256 _tokenAmount, bool _profit,uint256 expTime) = IDefiBets(_defiBets).claimForAccount(msg.sender, _tokenId);

        //Update the points of the user
        if (_profit) {
            IPointTracker(pointTracker).addPointsForPlayer(msg.sender, _tokenAmount,expTime);
        }
    }

    /**
     * @dev Executes the expiration of a bet based on the specified expiration time and underlying asset.
     * @param _expTime The expiration time of the bet.
     * @param _underlying The underlying asset for the bet.
     * @param _roundId The round id for a valid price of the underlying
     */
    function executeExpiration(uint256 _expTime, string memory _underlying, uint80 _roundId) external whenNotPaused {
        bytes32 _hash = getUnderlyingByte(_underlying);
        _isValidUnderlying(_hash);

        uint256 _price = getPrice(_hash, _expTime, _roundId);

        address _defiBets = defiBetsContracts[_hash];

        IDefiBets(_defiBets).performExpiration(_expTime, _price);
    }

    function createNewExpTime(bytes32 _tokenHash) external whenNotPaused {
        _isValidUnderlying(_tokenHash);

        address _defiBets = defiBetsContracts[_tokenHash];

        IDefiBets(_defiBets).initializeNewExpTime();
    }

    /* ====== Setup Functions ====== */

    function setPointTracker(address _pointTracker) external onlyOwner {
        pointTracker = _pointTracker;
    }

    function addUnderlyingToken(string memory _underlying, address _feed, address _defiBets) external onlyOwner {
        bytes32 _hash = getUnderlyingByte(_underlying);

        validUnderlying[_hash] = true;

        updatePriceFeed(_hash, _feed);

        defiBetsContracts[_hash] = _defiBets;

        emit UnderlyingAdded(_underlying, _hash, _defiBets);
    }

    function updatePriceFeed(bytes32 _hash, address _feed) public onlyOwner {
        _isValidUnderlying(_hash);

        underlyingPriceFeeds[_hash] = _feed;

        emit PriceFeedUpdated(_hash, _feed);
    }

    function updateIVFeed(bytes32 _hash, address _feed, uint256 _period) public onlyOwner {
        _isValidUnderlying(_hash);

        underlyingIVFeeds[_hash] = IVFeed(_feed, _period);

        emit IVFeedUpdated(_hash, _feed, _period);
    }

    function initializeBets(
        bytes32 _hash,
        uint256 _startExpTime,
        uint256 _minBetDuration,
        uint256 _maxBetDuration,
        uint256 _slot
    ) external onlyOwner {
        address _defiBets = defiBetsContracts[_hash];

        IDefiBets(_defiBets).initializeData(_startExpTime, _minBetDuration, _maxBetDuration, _slot);
    }

    function setDefiBetsParameter(
        uint256 _minBetDuration,
        uint256 _maxBetDuration,
        uint256 _slot,
        uint256 _timeDelta,
        uint256 _dependentTimeStamp,
        bytes32 _hash
    ) external onlyOwner {
        _isValidUnderlying(_hash);

        address _defiBetsAddress = defiBetsContracts[_hash];

        IDefiBets(_defiBetsAddress).setBetParamater(
            _maxBetDuration, _minBetDuration, _slot, _timeDelta, _dependentTimeStamp
        );
    }

    /* ====== Internal Functions ====== */

    function _isValidUnderlying(bytes32 _hash) internal view {
        if (validUnderlying[_hash] == false) {
            revert DefiBetsManager__NoValidUnderlying();
        }
    }

    function _executeBetForAccount(
        address _defiBets,
        uint256 _betSize,
        uint256 _minPrice,
        uint256 _maxPrice,
        uint256 _expTime,
        uint256 _winning
    ) internal {
        IDefiBets(_defiBets).setBetForAccount(msg.sender, _betSize, _minPrice, _maxPrice, _expTime, _winning);
    }

    function _isRoundIdValid(
        uint256 _expTime,
        uint80 _roundId,
        uint80 _latestRoundId,
        uint256 _latestRoundIdTimestamp,
        address _priceFeed
    ) internal view {
        bool _valid = true;

        if (_roundId > _latestRoundId) {
            _valid = false;
        }

        if (_roundId < _latestRoundId) {
            (,,, uint256 _timestamp,) = AggregatorV3Interface(_priceFeed).getRoundData(_roundId + 1);
            _valid = _timestamp >= _expTime;
        }

        if (_roundId == _latestRoundId) {
            _valid = _latestRoundIdTimestamp <= _expTime;
        }

        if (_valid == false) {
            revert DefiBetsManager__NotValidRoundId();
        }
    }

    function _calculateWinnings(uint256 _value, uint256 _probability) internal pure returns (uint256) {
        return (_value).mul(MULTIPLIER).div(_probability);
    }

    function _isPointTrackerSet() internal view {
        if (pointTracker == address(0)) {
            revert DefiBetsManager__NoPointTrackerSet();
        }
    }

    /* ====== Pure/View Functions ====== */

    function getCurrPrice(bytes32 _hash) public view returns (uint256) {
        uint256 price;

        address _priceFeed = underlyingPriceFeeds[_hash];
        if(_priceFeed == address(0)){
            return 0;
        }

        (, int256 answer,,,) = AggregatorV3Interface(_priceFeed).latestRoundData();

        price = uint256(answer);

        return price;
    }

    function getPrice(bytes32 _hash, uint256 _expTime, uint80 _roundId) public view returns (uint256) {
        uint256 price;

        if (underlyingPriceFeeds[_hash] != address(0) && block.timestamp >= _expTime) {
            address _priceFeed = underlyingPriceFeeds[_hash];

            (uint80 _latestRoundId, int256 _latestAnswer,, uint256 _latestTimestamp,) =
                AggregatorV3Interface(_priceFeed).latestRoundData();

            _isRoundIdValid(_expTime, _roundId, _latestRoundId, _latestTimestamp, _priceFeed);

            if (_latestRoundId == _roundId) {
                price = uint256(_latestAnswer);
            } else {
                (, int256 _answer,,,) = AggregatorV3Interface(_priceFeed).getRoundData(_roundId);
                price = uint256(_answer);
            }
        }

        return price;
    }

    function getUnderlyingByte(string memory _token) public pure returns (bytes32) {
        return keccak256(bytes(_token));
    }

    function calculateWinning(
        uint256 _price,
        uint256 _betSize,
        uint256 _minPrice,
        uint256 _maxPrice,
        uint256 _expTime,
        bytes32 _hash
    ) public view returns (uint256) {
        uint256 vola = getImplVol(_hash);
        if (vola == 0) {
            return 0;
        }

        //Probabiliy per 10000
        uint256 probability = MathLibraryDefibets.calculateProbabilityRange(
            _minPrice,
            _maxPrice,
            _price, /* current price BTC */
            vola,
            underlyingIVFeeds[_hash].period,
            (_expTime.sub(block.timestamp))
        ); /* days untill expiry * 10000 */

        return _calculateWinnings(_betSize, probability);
    }

    function _isNotNull(uint256 param) internal pure {
        if (0 == param) {
            revert DefiBetsManager__ParamNull();
        }
    }

    function getImplVol(bytes32 _hash) public view returns (uint256) {
        address volaFeed = underlyingIVFeeds[_hash].feedAddress;
        if (volaFeed == address(0)) {
            return 0;
        }

        (, int256 answer,,,) = AggregatorV3Interface(underlyingIVFeeds[_hash].feedAddress).latestRoundData();

        return uint256(answer);
    }
}
