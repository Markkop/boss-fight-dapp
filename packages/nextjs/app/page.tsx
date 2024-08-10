"use client";

import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { Address, Balance } from "~~/components/scaffold-eth";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const [bossHP, setBossHP] = useState<number>(0);
  const [isBossAlive, setIsBossAlive] = useState<boolean>(true);
  const [currentBossId, setCurrentBossId] = useState<number>(0);

  const { writeContractAsync: writeBossGameAsync, isMining: isAttacking } = useScaffoldWriteContract("BossGame");

  const { data: bossHPData } = useScaffoldReadContract({
    contractName: "BossGame",
    functionName: "getBossHP",
  });

  const { data: bossAliveData } = useScaffoldReadContract({
    contractName: "BossGame",
    functionName: "isBossAlive",
  });

  const { data: currentBossIdData } = useScaffoldReadContract({
    contractName: "BossGame",
    functionName: "getCurrentBossId",
  });

  useEffect(() => {
    if (bossHPData) setBossHP(Number(bossHPData));
    if (bossAliveData !== undefined) setIsBossAlive(bossAliveData);
    if (currentBossIdData) setCurrentBossId(Number(currentBossIdData));
  }, [bossHPData, bossAliveData, currentBossIdData]);

  return (
    <div className="flex items-center flex-col flex-grow pt-10">
      <div className="px-5">
        <h1 className="text-center mb-8">
          <span className="block text-2xl mb-2">Welcome to</span>
          <span className="block text-4xl font-bold">Boss Slayer Game</span>
        </h1>
        <div className="flex justify-center items-center space-x-2 flex-col sm:flex-row">
          <p className="my-2 font-medium">Connected Address:</p>
          <Address address={connectedAddress} />
        </div>
        <div className="mt-8 bg-base-300 p-6 rounded-lg">
          <h2 className="text-2xl font-bold mb-4">Current Boss</h2>
          <p>Boss ID: {currentBossId}</p>
          <p>HP: {bossHP}</p>
          <p>Status: {isBossAlive ? "Alive" : "Defeated"}</p>
          <button
            className="btn btn-primary mt-4"
            onClick={async () => {
              const response = await writeBossGameAsync({
                functionName: "attackBoss",
              });
            }}
            disabled={!isBossAlive || isAttacking}
          >
            {isAttacking ? "Attacking..." : "Attack Boss"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default Home;
