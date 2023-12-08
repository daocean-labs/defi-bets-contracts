//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IPointTracker {
    function reducePointsForPlayer(address _player, uint256 _points) external;

    function addPointsForPlayer(address _player, uint256 _points,uint256 _expTime) external;

    function getSeasonEndDate() external view returns (uint256);
}
