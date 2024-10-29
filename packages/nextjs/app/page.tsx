"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { ArrowsRightLeftIcon, DocumentTextIcon } from "@heroicons/react/24/outline";
import { Address } from "~~/components/scaffold-eth";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();

  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10 bg-neutral-content-alt">
        <div className="px-5">
          <h1 className="text-center">
            <span className="block text-2xl mb-2">Cross-Chain Launchpad</span>
            <span className="block text-4xl font-bold">Entity Surge | Wormhole</span>
          </h1>
          <div className="flex justify-center items-center space-x-2 flex-col sm:flex-row">
            <p className="my-2 font-medium">Current Manager:</p>
            <Address address={connectedAddress} />
          </div>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-12 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-10 pt-10 pb-8 text-center items-center max-w-xs ">
              <DocumentTextIcon className="h-8 w-8 fill-secondary" />
              <p>
                Manage Your Launchpad Smart Contracts in the{" "}
                <Link href="/debug" passHref className="link">
                  Contracts
                </Link>{" "}
                tab.
              </p>
            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs ">
              <ArrowsRightLeftIcon className="h-8 w-8 fill-secondary" />
              <p>
                Execute Cross-Chain Token Transfers in the{" "}
                <Link href="/connect" passHref className="link">
                  Connect
                </Link>{" "}
                tab.
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
