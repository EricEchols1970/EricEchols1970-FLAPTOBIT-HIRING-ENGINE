// SPDX-License-Identifier: MIT
/**
 * FLAPTOBIT AI Autonomous Hiring Engine Protocol
 * $FLAPTOKEN — ERC-20 Token Contract
 *
 * Owner/Founder: Eric Marlon Echols
 * Fixed Supply: 100,000,000 $FLAPTOKEN
 * Price: $0.25 USD per token
 * Stake: 100 $FLAPTOKEN ($25) for platform access
 *
 * Self-Custody Protocol: FLAPTOBIT never holds user assets.
 */

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract FlapToken is ERC20, Ownable {
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18; // 100M $FLAPTOKEN
    uint256 public constant STAKE_AMOUNT = 100 * 10**18; // 100 $FLAPTOKEN for platform access
    uint256 public constant AFFILIATE_BUYBACK_PERCENT = 20; // 20% affiliate buy-back mechanism
    uint256 public constant TOKEN_PRICE_USD = 25; // $0.25 per $FLAPTOKEN in cents

    mapping(address => bool) public hasStaked;
    mapping(address => uint256) public stakedAmount;
    mapping(address => address) public affiliateReferrer;

    event Staked(address indexed user, uint256 amount);
    event AffiliateReward(address indexed affiliate, address indexed user, uint256 reward);
    event TokensBurned(address indexed from, uint256 amount);

    constructor() ERC20("$FLAPTOKEN", "$FLAP") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    /**
     * Stake 100 $FLAPTOKEN to access the FLAPTOBIT platform.
     * Tokens remain in the user's wallet — self-custody model.
     * This function only records the stake status on-chain.
     */
    function stake() external {
        require(balanceOf(msg.sender) >= STAKE_AMOUNT, "Insufficient $FLAPTOKEN balance to stake");
        require(!hasStaked[msg.sender], "Already staked");

        hasStaked[msg.sender] = true;
        stakedAmount[msg.sender] = STAKE_AMOUNT;

        emit Staked(msg.sender, STAKE_AMOUNT);
    }

    /**
     * Register an affiliate referrer for the 80/20 commission split.
     * 80% to the affiliate, 20% buy-back mechanism.
     */
    function setAffiliate(address referrer) external {
        require(referrer != msg.sender, "Cannot refer yourself");
        require(referrer != address(0), "Invalid referrer");
        affiliateReferrer[msg.sender] = referrer;
    }

    /**
     * Check if an address has staked and has platform access.
     */
    function hasPlatformAccess(address user) external view returns (bool) {
        return hasStaked[user];
    }

    /**
     * Get user's staked amount.
     */
    function getStakedAmount(address user) external view returns (uint256) {
        return stakedAmount[user];
    }

    /**
     * Owner can burn unsold tokens to maintain fixed supply integrity.
     */
    function burnTokens(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    /**
     * Returns the total supply (constant — never mintable beyond initial supply).
     */
    function totalSupply() public view override returns (uint256) {
        return TOTAL_SUPPLY;
    }
}
