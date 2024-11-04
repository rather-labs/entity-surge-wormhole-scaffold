"use client";

import "./page.css";

const Connect = () => {
  return (
    <>
      <div className="text-center mt-0 bg-base-300 px-10 pt-10 pb-8">
        <h1 className="text-4xl my-0">Entity Surge + Wormhole Connect</h1>
        <p className="text-neutral">Transfer NTT-enabled Tokens Across Supported Chains.</p>
      </div>
      <div className="bg-base-300 w-full">
        <iframe src="https://entity-wormhole-connect.vercel.app/" width="400" height="636" className="mx-auto"></iframe>
      </div>
    </>
  );
};

export default Connect;
