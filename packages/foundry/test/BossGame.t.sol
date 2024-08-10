// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/BossGame.sol";

contract BossGameTest is Test {
    BossGame public bossGame;
    address public player1;
    address public player2;

    function setUp() public {
        bossGame = new BossGame();
        player1 = address(0x1);
        player2 = address(0x2);
    }

    function testInitialBossState() public {
        assertEq(bossGame.getBossHP(), 1000, "Initial boss HP should be 1000");
        assertTrue(bossGame.isBossAlive(), "Boss should be alive initially");
        assertEq(bossGame.getCurrentBossId(), 1, "Initial boss ID should be 1");
    }

    function testAttackBoss() public {
        vm.prank(player1);
        bossGame.attackBoss();

        assertEq(bossGame.getBossHP(), 900, "Boss HP should decrease by 100 after attack");
        assertTrue(bossGame.isBossAlive(), "Boss should still be alive after one attack");
    }

    function testDefeatBoss() public {
        for (uint i = 0; i < 10; i++) {
            vm.prank(player1);
            bossGame.attackBoss();
        }

        assertEq(bossGame.getBossHP(), 1000, "New boss should spawn with full HP");
        assertTrue(bossGame.isBossAlive(), "New boss should be alive");
        assertEq(bossGame.getCurrentBossId(), 2, "Boss ID should increment after defeat");
    }

    function testMultipleAttackers() public {
        vm.prank(player1);
        bossGame.attackBoss();

        vm.prank(player2);
        bossGame.attackBoss();

        assertEq(bossGame.getBossHP(), 800, "Boss HP should decrease by 200 after two attacks");
    }

    function testRewardDistribution() public {
        for (uint i = 0; i < 10; i++) {
            if (i % 2 == 0) {
                vm.prank(player1);
            } else {
                vm.prank(player2);
            }
            bossGame.attackBoss();
        }

        assertEq(bossGame.balanceOf(player1), 1, "Player 1 should receive 1 NFT");
        assertEq(bossGame.balanceOf(player2), 1, "Player 2 should receive 1 NFT");
    }

    function testCannotAttackDefeatedBoss() public {
        for (uint i = 0; i < 10; i++) {
            vm.prank(player1);
            bossGame.attackBoss();
        }

        vm.expectRevert("Boss is already defeated");
        bossGame.attackBoss();
    }

    function testEmitBossDefeatedEvent() public {
        for (uint i = 0; i < 9; i++) {
            vm.prank(player1);
            bossGame.attackBoss();
        }

        vm.expectEmit(false, false, false, true);
        emit BossGame.BossDefeated(1);
        
        vm.prank(player1);
        bossGame.attackBoss();
    }

    function testEmitBossSpawnedEvent() public {
        for (uint i = 0; i < 10; i++) {
            vm.prank(player1);
            bossGame.attackBoss();
        }

        vm.expectEmit(false, false, false, true);
        emit BossGame.BossSpawned(2, 1000);
        
        vm.prank(player1);
        bossGame.attackBoss();
    }

    function testEmitAttackLandedEvent() public {
        vm.expectEmit(true, false, false, true);
        emit BossGame.AttackLanded(player1, 100);

        vm.prank(player1);
        bossGame.attackBoss();
    }
}
