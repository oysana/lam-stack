import test from "node:test";
import assert from "node:assert/strict";
import "./provider_catalog.js";

const catalog = globalThis.OyVoiceProviderCatalog;

test("stop alias fills finish when finish is absent", () => {
  const out = catalog.migrateSelectors({ stop: "#old-stop" });
  assert.equal(out.finish, "#old-stop");
  assert.equal("stop" in out, false);
});

test("modern finish beats the stop alias", () => {
  const out = catalog.migrateSelectors({ stop: "#old", finish: "#new" });
  assert.equal(out.finish, "#new");
});

test("input alias fills composer when composer is absent", () => {
  const out = catalog.migrateSelectors({ input: "#old-input" });
  assert.equal(out.composer, "#old-input");
  assert.equal("input" in out, false);
});

test("modern composer beats the input alias", () => {
  const out = catalog.migrateSelectors({ input: "#i", composer: "#c" });
  assert.equal(out.composer, "#c");
});

test("other saved keys are preserved", () => {
  const out = catalog.migrateSelectors({ foo: "bar", start: "#s" });
  assert.equal(out.foo, "bar");
  assert.equal(out.start, "#s");
});

test("defaults fill missing keys and retired labels still upgrade", () => {
  const out = catalog.migrateSelectors({});
  for (const k of ["composer", "start", "finish", "cancel"]) {
    assert.ok(out[k], `missing default for ${k}`);
  }
  const retired = catalog.migrateSelectors({ finish: 'button[aria-label="Submit dictation"]' });
  assert.equal(retired.finish, catalog.selectorDefaults.finish);
});

test("undefined saved config yields defaults", () => {
  const out = catalog.migrateSelectors(undefined);
  assert.equal(out.composer, catalog.selectorDefaults.composer);
});
