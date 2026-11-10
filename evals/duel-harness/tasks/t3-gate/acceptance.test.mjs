import { test } from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import "./provider_catalog.js";

const catalog = globalThis.OyVoiceProviderCatalog;
const ROOT = new URL("..", import.meta.url).pathname;

function runNode(args) {
  const env = { ...process.env };
  for (const k of Object.keys(env)) if (k.startsWith("NODE_TEST")) delete env[k];
  return execFileSync("node", args, { cwd: ROOT, stdio: "pipe", timeout: 90000, env });
}

test("fromUrl accepts chatgpt.com and its subdomains", () => {
  assert.equal(catalog.fromUrl("https://chatgpt.com/").id, "chatgpt");
  assert.equal(catalog.fromUrl("https://chatgpt.com/c/abc").id, "chatgpt");
  assert.equal(catalog.fromUrl("https://www.chatgpt.com/").id, "chatgpt");
  assert.equal(catalog.fromUrl("https://a.b.chatgpt.com/").id, "chatgpt");
});

test("fromUrl rejects lookalike and unrelated hosts", () => {
  for (const u of [
    "https://chatgpt.com.evil.com/",
    "https://evilchatgpt.com/",
    "https://notchatgpt.com/",
    "https://chatgpt.com@evil.com/",
    "https://speechnotes.co/",
    "https://example.com/",
  ]) assert.equal(catalog.fromUrl(u), null, u);
});

test("fromUrl unchanged for google_speech and non-https", () => {
  assert.equal(catalog.fromUrl("chrome-extension://dmbciflhimhohoajahjmcjpoampldjbc/google_speech.html").id, "google_speech");
  assert.equal(catalog.fromUrl("chrome-extension://dmbciflhimhohoajahjmcjpoampldjbc/google_speech.html#voicebridge=x").id, "google_speech");
  assert.equal(catalog.fromUrl("chrome-extension://foreign/google_speech.html"), null);
  assert.equal(catalog.fromUrl("http://chatgpt.com/"), null);
  assert.equal(catalog.fromUrl("not a url"), null);
});

test("repo JS suite provider_adapters stays green", () => {
  runNode(["--test", "tests/js/provider_adapters.test.js"]);
});

test("repo JS suite options_contract stays green", () => {
  runNode(["--test", "tests/js/options_contract.test.js"]);
});

test("extension version is bumped beyond the shipped base 0.6.0.256", () => {
  const manifest = JSON.parse(readFileSync(`${ROOT}extension/manifest.json`, "utf8"));
  assert.notEqual(manifest.version, "0.6.0.256");
  assert.match(manifest.version, /^0\.6\.0\.\d+$/);
});

test("STATUS.md records the bumped extension version", () => {
  const manifest = JSON.parse(readFileSync(`${ROOT}extension/manifest.json`, "utf8"));
  const status = readFileSync(`${ROOT}STATUS.md`, "utf8");
  assert.ok(status.includes(`extension **${manifest.version}**`));
});

test(".content-hash carries the bumped version", () => {
  const manifest = JSON.parse(readFileSync(`${ROOT}extension/manifest.json`, "utf8"));
  const line = readFileSync(`${ROOT}extension/.content-hash`, "utf8").trim();
  assert.ok(line.endsWith(` ${manifest.version}`));
});
