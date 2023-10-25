// Sources flattened with hardhat v2.17.2 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File src/core/PointTracker.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract PointTracker is Ownable {
    /* === Errors === */
    error PointTracker__SeasonOutOfBounds();
    error PointTracker__AccessForbidden();
    error PointTracker__AccountAlreadyActivated();
    error PointTracker__AccountNotEligible();
    error PointTracker__SeasonIsNotActive();
    error PointTracker__PlayerNotActive();
    error PointTracker__SeasonIsActive();
    error PointTracker__NotEndOfSeasonReached();
    error PointTracker__NotEnoughPoints();

    uint256 public constant MINIMUM_DFI_AMOUNT = 0.1 ether;
    uint256 public immutable i_startingPoints;

    /* === State Varibales === */
    address private manager;
    uint256 private season;

    uint256 private endOfSeason;

    bool private seasonActive;

    mapping(uint256 => mapping(address => uint256)) private pointsInSeason;
    mapping(uint256 => mapping(address => bool)) private isActivated;

    /* === Events === */
    event AccountActivation(address indexed player, uint256 season);
    event SeasonFinished(uint256 season);
    event SeasonStarted(uint256 season);
    event PointsAdded(address indexed player, uint256 pointsAdded, uint256 newScore);
    event PointsRemoved(address indexed player, uint256 pointsRemoved, uint256 newScore);

    /* === Modifier === */
    modifier seasonIsActive() {
        if (seasonActive == false) {
            revert PointTracker__SeasonIsNotActive();
        }

        _;
    }

    modifier seasonNotActive() {
        if (seasonActive == true) {
            revert PointTracker__SeasonIsActive();
        }
        _;
    }

    constructor(address _manager, uint256 startingPoints) {
        manager = _manager;
        i_startingPoints = startingPoints;
    }

    /* === Mutation Functions === */

    function addPointsForPlayer(address _player, uint256 _points) external seasonIsActive {
        _isManager();
        _isPlayerActive(_player);

        pointsInSeason[season][_player] += _points;

        emit PointsAdded(_player, _points, pointsInSeason[season][_player]);
    }

    function reducePointsForPlayer(address _player, uint256 _points) external seasonIsActive {
        _isManager();
        _isPlayerActive(_player);
        _hasEnoughPoints(_player, _points);

        pointsInSeason[season][_player] -= _points;

        emit PointsRemoved(_player, _points, pointsInSeason[season][_player]);
    }

    function activateAccount() external seasonIsActive {
        if (isActivated[season][msg.sender] == true) {
            revert PointTracker__AccountAlreadyActivated();
        }

        if (msg.sender.balance < MINIMUM_DFI_AMOUNT) {
            revert PointTracker__AccountNotEligible();
        }

        pointsInSeason[season][msg.sender] = i_startingPoints;
        isActivated[season][msg.sender] = true;

        emit AccountActivation(msg.sender, season);
    }

    function finishSeason() external onlyOwner seasonIsActive {
        if (block.timestamp < endOfSeason) {
            revert PointTracker__NotEndOfSeasonReached();
        }
        seasonActive = false;

        emit SeasonFinished(season);
    }

    function startSeason(uint256 _endOfSeason) external onlyOwner seasonNotActive {
        seasonActive = true;

        season++;

        endOfSeason = _endOfSeason;

        emit SeasonStarted(season);
    }

    /* === Internal Functions === */

    function _isManager() internal view {
        if (msg.sender != manager) {
            revert PointTracker__AccessForbidden();
        }
    }

    function _isPlayerActive(address _player) internal view {
        if (isActivated[season][_player] == false) {
            revert PointTracker__PlayerNotActive();
        }
    }

    function _hasEnoughPoints(address _player, uint256 _points) internal view {
        if (pointsInSeason[season][_player] < _points) {
            revert PointTracker__NotEnoughPoints();
        }
    }

    /* === Pure / View Functions === */

    function getManager() public view returns (address) {
        return manager;
    }

    function getLatestSeason() public view returns (uint256) {
        return season;
    }

    function getPlayerPoints(uint256 _season, address _player) public view returns (uint256) {
        if (_season > season) {
            revert PointTracker__SeasonOutOfBounds();
        }

        return pointsInSeason[_season][_player];
    }

    function getSeasonEndDate() external view returns (uint256) {
        return endOfSeason;
    }

    function isAccountActive(uint256 _season, address _player) public view returns (bool) {
        return isActivated[_season][_player];
    }
}
