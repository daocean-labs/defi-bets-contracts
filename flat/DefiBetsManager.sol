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


// File @openzeppelin/contracts/security/Pausable.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol@v0.6.1

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts/utils/math/SafeMath.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File src/interface/core/IDefiBets.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IDefiBets {
    function setBetForAccount(
        address _account,
        uint256 _betSize,
        uint256 _minPrice,
        uint256 _maxPrice,
        uint256 _expTime,
        uint256 _winning
    ) external;

    function claimForAccount(address _account, uint256 _betID) external returns (uint256, bool);

    function setBetParamater(
        uint256 _minBetDuration,
        uint256 _maxBetDuration,
        uint256 _slot,
        uint256 _timeDelta,
        uint256 _dependentTimeStamp
    ) external;

    function performExpiration(uint256 _expTime, uint256 _expPrice) external;

    function initializeNewExpTime() external;

    function lastActiveExpTime() external returns (uint256);

    function initializeData(uint256 _startExpTime, uint256 _minBetDuration, uint256 _maxBetDuration, uint256 _slot)
        external;
}


// File src/interface/core/IPointTracker.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IPointTracker {
    function reducePointsForPlayer(address _player, uint256 _points) external;

    function addPointsForPlayer(address _player, uint256 _points) external;

    function getSeasonEndDate() external view returns (uint256);
}


// File @openzeppelin/contracts/utils/math/Math.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}


// File src/lib/MathLibraryDefiBets.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


// Useful for debugging. Remove when deploying to a live network.

error MathLibraryDefibets__WrongParameter();
error MathLibraryDefibets__StdDeviationOutOfBounds();

library MathLibraryDefibets {
    using SafeMath for uint256;

    // positive Z-Table probability values from standard deviation 0 to 3. Needed to get probability from standard deviation.
    bytes constant z_table_positive =
        hex"144F151615DC16A11763182318E0199A1A501B031BB01C591CFE1D9C1E361EC91F571FDF206120DD215321C3222D229122F02348239B23E82431247424B224EC25212552257F25A925CE25F12610262C2646265D26722685269626A526B226BE26C926D226DA26E126E826ED26F226F626FA26FD27002703";

    // negative Z-Table probability values from standard deviation -3 to -0.05. Needed to get probability from standard deviation.
    bytes constant z_table_negative =
        hex"000D001000130016001A001E00230028002F0036003E00470052005E006B007A008B009E00B300CA00E40100011F01420167019101BE01EF0224025E029C02DF0328037503C80420047F04E3054D05BD063306AF073107B9084708DA09740A120AB70B600C0D0CC00E300EED0FAD106F113411FA12C11388";

    uint256 public constant BILLION = 1000000000;
    uint256 public constant Z_TABLE_MAX = 59; // 60 values per table with each value 2 byte length

    function abs(int256 x) private pure returns (int256) {
        return x >= 0 ? x : -x;
    }

    function calculateStandardDeviation(
        uint256 currPrice,
        uint256 impliedVolatility30,
        uint256 timeUntilEpxiry,
        uint256 impliedVolatitityTime
    ) internal pure returns (uint256) {
        uint256 adjImpliedVol =
            (impliedVolatility30.mul(Math.sqrt(timeUntilEpxiry.mul(10 ** 8).div(impliedVolatitityTime)))).div(10000);

        return (currPrice.mul(adjImpliedVol)).div(10000);
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), mul(_start, 2)))
        }

        return tempUint;
    }

    /**
     *
     * @dev - return the zScore with 4 decimals
     */
    function calculateZScore(uint256 _delta, uint256 _stdDeviation) internal pure returns (uint256) {
        return _delta.mul(10 ** 4).div(_stdDeviation);
    }

    function lookupZtableFromStdDeviation(uint256 zScore, bool useNegativeZTable) private pure returns (uint16) {
        uint256 index = zScore.div(500);

        if (Z_TABLE_MAX < index) {
            index = Z_TABLE_MAX;
        }

        if (useNegativeZTable) {
            // use negative Z-Table
            index = Z_TABLE_MAX - index; /* Invert for negative Z-Table values */
            return toUint16(z_table_negative, index);
        } else {
            // use positive Z-Table
            return toUint16(z_table_positive, index);
        }
    }

    function calculateProbabilityForBetPrice(uint256 betPrice, uint256 currPrice, uint256 stdDeviation)
        internal
        pure
        returns (uint16)
    {
        uint256 delta = 0;
        bool isNegative = false;

        if (currPrice > betPrice) {
            isNegative = true;
            delta = currPrice.sub(betPrice);
        } else {
            delta = betPrice.sub(currPrice);
        }

        uint256 zScore = calculateZScore(delta, stdDeviation);

        return lookupZtableFromStdDeviation(zScore, isNegative);
    }

    /**
     *
     * @param lowerPrice - lower price of the price range with decimals
     * @param upperPrice - upper price of the price range with decimals
     * @param currPrice  - the current price of the underlying with decimals
     * @param impliedVolatility - the implied volatility for x days in promille => 30% = 3000
     * @param impliedVolatilityTime - the time of the volatility in seconds
     * @param timeUntilEpxiry - the remaining time until expiration in seconds
     */
    function calculateProbabilityRange(
        uint256 lowerPrice,
        uint256 upperPrice,
        uint256 currPrice,
        uint256 impliedVolatility,
        uint256 impliedVolatilityTime,
        uint256 timeUntilEpxiry
    ) public pure returns (uint256) {
        // Sanity checks
        if ((lowerPrice < 0) || (upperPrice < 0) || (currPrice < 0)) {
            revert MathLibraryDefibets__WrongParameter();
        }

        uint256 stdDeviation =
            calculateStandardDeviation(currPrice, impliedVolatility, timeUntilEpxiry, impliedVolatilityTime);

        //-----------------------------------------------------
        // 1. calculate probability for lower range boundary
        //-----------------------------------------------------

        uint16 propability_lower_10000 = calculateProbabilityForBetPrice(lowerPrice, currPrice, stdDeviation);

        //-----------------------------------------------------
        // 2. calculate probability for higher range boundary
        //-----------------------------------------------------

        uint16 propability_higher_10000 = calculateProbabilityForBetPrice(upperPrice, currPrice, stdDeviation);

        //---------------------------------------------------------------
        // 3. calculate end probability for the range. (higher - lower)
        //---------------------------------------------------------------
        uint256 probability = propability_higher_10000 - propability_lower_10000;

        return (probability);
    }
}


// File src/core/DefiBetsManager.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;






// Library import

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

        (uint256 _tokenAmount, bool _profit) = IDefiBets(_defiBets).claimForAccount(msg.sender, _tokenId);

        //Update the points of the user
        if (_profit) {
            IPointTracker(pointTracker).addPointsForPlayer(msg.sender, _tokenAmount);
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
