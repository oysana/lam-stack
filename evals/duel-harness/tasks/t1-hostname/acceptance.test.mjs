import test from "node:test";
import assert from "node:assert/strict";
import "./provider_catalog.js";

const catalog = globalThis.OyVoiceProviderCatalog;
const ids = url => catalog.fromUrl(url)?.id ?? null;

test("exact chatgpt.com is the chatgpt provider", () => {
  assert.equal(ids("https://chatgpt.com/"), "chatgpt");
  assert.equal(ids("https://chatgpt.com/c/deadbeef"), "chatgpt");
});

test("subdomains of chatgpt.com are allowed", () => {
  assert.equal(ids("https://www.chatgpt.com/"), "chatgpt");
  assert.equal(ids("https://auth.chatgpt.com/login"), "chatgpt");
});

test("lookalike hosts are rejected", () => {
  assert.equal(ids("https://chatgpt.com.evil.com/"), null);
  assert.equal(ids("https://notchatgpt.com/"), null);
  assert.equal(ids("https://chatgpt.com.phish.io/x"), null);
  assert.equal(ids("https://fake-chatgpt.com/"), null);
});

test("non-chatgpt and non-https urls stay rejected", () => {
  assert.equal(ids("http://chatgpt.com/"), null);
  assert.equal(ids("https://example.com/"), null);
  assert.equal(ids("not a url"), null);
  assert.equal(ids("ftp://chatgpt.com/"), null);
});

test("google_speech extension url still resolves", () => {
  assert.equal(
    ids("chrome-extension://dmbciflhimhohoajahjmcjpoampldjbc/google_speech.html"),
    "google_speech"
  );
});
