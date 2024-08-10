// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BossGame is ERC721 {
    struct Boss {
        uint256 hp;
        bool alive;
    }

    Boss public currentBoss;
    address[] public attackers;
    uint256 private _tokenIds;
    uint256 private _bossIds;

    event BossDefeated(uint256 bossNumber);
    event BossSpawned(uint256 bossNumber, uint256 hp);
    event AttackLanded(address attacker, uint256 damage);

    constructor() ERC721("BossSlayer", "BSL") {
        spawnNewBoss();
    }

    function spawnNewBoss() private {
        _bossIds++;
        currentBoss = Boss(1000, true); // Boss with 1000 HP
        delete attackers;
        emit BossSpawned(_bossIds, currentBoss.hp);
    }

    function attackBoss() public {
        require(currentBoss.alive, "Boss is already defeated");

        uint256 damage = 100; // Fixed damage for simplicity
        if (currentBoss.hp <= damage) {
            currentBoss.hp = 0;
            currentBoss.alive = false;
            rewardAttackers();
            emit BossDefeated(_bossIds);
            spawnNewBoss();
        } else {
            currentBoss.hp -= damage;
        }

        attackers.push(msg.sender);
        emit AttackLanded(msg.sender, damage);
    }

    function rewardAttackers() private {
        for (uint i = 0; i < attackers.length; i++) {
            _tokenIds++;
            _mint(attackers[i], _tokenIds);
        }
    }

    function getBossHP() public view returns (uint256) {
        return currentBoss.hp;
    }

    function isBossAlive() public view returns (bool) {
        return currentBoss.alive;
    }

    function getCurrentBossId() public view returns (uint256) {
        return _bossIds;
    }
}
