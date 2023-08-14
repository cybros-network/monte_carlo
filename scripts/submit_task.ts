import { loadSync as loadEnvSync } from "https://deno.land/std/dotenv/mod.ts"
import { parse } from "https://deno.land/std/flags/mod.ts"

import { ApiPromise, HttpProvider, Keyring, WsProvider } from "https://deno.land/x/polkadot/api/mod.ts";
import { cryptoWaitReady } from "https://deno.land/x/polkadot/util-crypto/mod.ts";
import type { KeyringPair } from "https://deno.land/x/polkadot/keyring/types.ts";

const env = loadEnvSync()
const parsedArgs = parse(Deno.args, {
  alias: {
    "dryRun": "dry",
    "uniqueTrackId": "track-id",
  },
  boolean: [
    "dryRun",
  ],
  string: [
    "prompt",
    "uniqueTrackId",
  ],
  default: {
    dryRun: false,
  },
})

const dryRun = parsedArgs.dryRun
const prompt = (parsedArgs.prompt ?? "").trim()
if (prompt.length === 0) {
  console.error("prompt is blank.")
  Deno.exit(1)
}
const uniqueTrackId = parseInt(parsedArgs.uniqueTrackId ?? "")
if (Number.isNaN(uniqueTrackId) || uniqueTrackId <= 0) {
  console.error("uniqueTrackId is invalid.")
  Deno.exit(1)
}
const jobPoolId = parseInt(env.JOB_POOL_ID)
if (Number.isNaN(jobPoolId) || jobPoolId <= 0) {
  console.error("jobPoolId is invalid.")
  Deno.exit(1)
}
const jobPolicyId = parseInt(env.JOB_POLICY_ID)
if (Number.isNaN(jobPolicyId) || jobPolicyId <= 0) {
  console.error("jobPolicyId is invalid.")
  Deno.exit(1)
}
const jobSpecVersion = parseInt(env.JOB_SPEC_VERSION)
if (Number.isNaN(jobSpecVersion) || jobSpecVersion <= 0) {
  console.error("jobSpecVersion is invalid.")
  Deno.exit(1)
}

const input = {
  e2e: false,
  data: prompt,
}

function createSubstrateApi(rpcUrl: string): ApiPromise | null {
  let provider = null;
  if (rpcUrl.startsWith("wss://") || rpcUrl.startsWith("ws://")) {
    provider = new WsProvider(rpcUrl);
  } else if (
    rpcUrl.startsWith("https://") || rpcUrl.startsWith("http://")
  ) {
    provider = new HttpProvider(rpcUrl);
  } else {
    return null;
  }

  return new ApiPromise({
    provider,
    throwOnConnect: true,
    throwOnUnknown: true,
  });
}

await cryptoWaitReady().catch((e) => {
  console.error(e.message);
  Deno.exit(1);
});

const operatorKeyPair: KeyringPair = (() => {
  const operatorMnemonic = env.SUB_OPERATOR_MNEMONIC;
  if (operatorMnemonic === undefined || operatorMnemonic === "") {
    console.error("Mnemonic is blank")
    Deno.exit(1)
  }

  try {
    return new Keyring({ type: "sr25519" }).addFromUri(operatorMnemonic, { name: "The operator" });
  } catch (e) {
    console.error(`Operator mnemonic invalid: ${e.message}`);
    Deno.exit(1)
  }
})();
console.log(`Operator: ${operatorKeyPair.address}`);

const api = createSubstrateApi(env.SUB_NODE_RPC_URL);
if (api === null) {
  console.error(`Invalid RPC URL "${env.SUB_NODE_RPC_URL}"`);
  Deno.exit(1);
}

api.on("error", (e) => {
  console.error(`Polkadot.js error: ${e.message}"`);
  Deno.exit(1);
});

await api.isReady.catch((e) => console.error(e));

console.info(`Sending offchainComputingPool.createJob(poolId, policyId, uniqueTrackId, implSpecVersion, input, softExpiresIn)`);
const txPromise = api.tx.offchainComputingPool.createJob(
  jobPoolId, jobPolicyId, uniqueTrackId, jobSpecVersion, JSON.stringify(input), null
);
console.info(`Call hash: ${txPromise.toHex()}`);
if (dryRun) {
  Deno.exit(0)
}

const txHash = await txPromise.signAndSend(operatorKeyPair, { nonce: -1 });
console.info(`Transaction hash: ${txHash.toHex()}`);

Deno.exit(0)
