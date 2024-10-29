"use client";

import React, { useCallback, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { ArrowsRightLeftIcon, Bars3Icon, DocumentTextIcon } from "@heroicons/react/24/outline";
import { FaucetButton, RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { useOutsideClick } from "~~/hooks/scaffold-eth";

type HeaderMenuLink = {
  label: string;
  href: string;
  icon?: React.ReactNode;
};

export const menuLinks: HeaderMenuLink[] = [
  {
    label: "Home",
    href: "/",
  },
  {
    label: "Contracts",
    href: "/debug",
    icon: <DocumentTextIcon className="h-4 w-4 relative bottom-0.5" />,
  },
  {
    label: "Connect",
    href: "/connect",
    icon: <ArrowsRightLeftIcon className="h-4 w-4 relative bottom-0.5" />,
  },
];

export const HeaderMenuLinks = () => {
  const pathname = usePathname();

  return (
    <>
      {menuLinks.map(({ label, href, icon }) => {
        const isActive = pathname === href;
        return (
          <li key={href} className="h-full items-center border-r border-accent">
            <Link
              href={href}
              passHref
              className={`${
                isActive ? "bg-base-200 shadow-md" : ""
              } hover:bg-base-200 focus:!bg-base-200 active:!text-neutral py-1.5 px-5 text-sm gap-2 flex h-full items-center uppercase tracking-wider text-xs font-medium`}
            >
              {icon}
              <span>{label}</span>
            </Link>
          </li>
        );
      })}
    </>
  );
};

/**
 * Site header
 */
export const Header = () => {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const burgerMenuRef = useRef<HTMLDivElement>(null);
  useOutsideClick(
    burgerMenuRef,
    useCallback(() => setIsDrawerOpen(false), []),
  );

  return (
    <div className="sticky lg:static top-0 navbar bg-base-100 min-h-0 flex-shrink-0 justify-between z-20 py-0 px-0 pl-2 border-b border-accent h-16">
      <div className="navbar-start w-auto lg:w-1/2 h-full">
        <div className="lg:hidden dropdown" ref={burgerMenuRef}>
          <label
            tabIndex={0}
            className={`ml-1 btn btn-ghost ${isDrawerOpen ? "hover:bg-secondary" : "hover:bg-transparent"}`}
            onClick={() => {
              setIsDrawerOpen(prevIsOpenState => !prevIsOpenState);
            }}
          >
            <Bars3Icon className="h-1/2" />
          </label>
          {isDrawerOpen && (
            <ul
              tabIndex={0}
              className="menu menu-compact dropdown-content mt-3 p-2 shadow bg-base-100 w-52"
              onClick={() => {
                setIsDrawerOpen(false);
              }}
            >
              <HeaderMenuLinks />
            </ul>
          )}
        </div>
        <Link href="/" passHref className="hidden lg:flex items-center gap-2 ml-4 mr-6 shrink-0">
          <div className="flex relative">
            <Image alt="Entity iso" className="cursor-pointer mr-2" src="/iso.svg" width={30} height={30} />
          </div>
          <div className="flex relative">
            <Image alt="Entity logo" className="cursor-pointer" src="/entity-logo.png" width={80} height={40} />
          </div>
          {/* <div className="flex flex-col">
            <span className="font-bold leading-tight">Scaffold-ETH</span>
            <span className="text-xs">Ethereum dev stack</span>
          </div> */}
        </Link>
        <ul className="hidden lg:flex lg:flex-nowrap menu menu-horizontal px-0 py-0 h-full gap-0 border-l border-accent items-center">
          <HeaderMenuLinks />
        </ul>
      </div>
      <div className="navbar-end flex-grow h-full">
        <RainbowKitCustomConnectButton />
        <FaucetButton />
      </div>
    </div>
  );
};
