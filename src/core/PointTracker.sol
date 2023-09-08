//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

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

    uint256 public constant MINIMUM_DFI_AMOUNT = 10 ether;
    uint256 public constant STARTING_POINTS = 100;

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

    constructor(address _manager) {
        manager = _manager;
    }

    /* === Mutation Functions === */

    function addPointsForPlayer(address _player, uint256 _points) external seasonIsActive {
        _isManager();
        _isPlayerActive(_player);

        pointsInSeason[season][_player]++;

        emit PointsAdded(_player, _points, pointsInSeason[season][_player]);
    }

    function reducePointsForPlayer(address _player, uint256 _points) external seasonIsActive {
        _isManager();
        _isPlayerActive(_player);
        _hasEnoughPoints(_player, _points);

        pointsInSeason[season][_player]--;

        emit PointsRemoved(_player, _points, pointsInSeason[season][_player]);
    }

    function activateAccount() external seasonIsActive {
        if (isActivated[season][msg.sender] == true) {
            revert PointTracker__AccountAlreadyActivated();
        }

        if (msg.sender.balance < MINIMUM_DFI_AMOUNT) {
            revert PointTracker__AccountNotEligible();
        }

        pointsInSeason[season][msg.sender] = STARTING_POINTS;
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
        if (pointsInSeason[season][_player] > _points) {
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
}
