Saved OyVoice settings from older builds never gain working dictation selectors. Those builds stored the stop control under the key `stop` (now `finish`) and the composer under `input` (now `composer`). `migrateSelectors` in `extension/provider_catalog.js` merges saved keys but leaves them under their retired names, so a migrated config ends up with no usable `finish` or `composer` selector.

Extend `migrateSelectors(saved)` so that:

- a saved `stop` value fills `finish`, but only when `saved` has no `finish` key of its own;
- a saved `input` value fills `composer`, but only when `saved` has no `composer` key of its own;
- the returned object never has `stop` or `input` keys;
- every other saved key is preserved unchanged;
- existing behavior stays: defaults fill missing keys and retired aria-label values still upgrade to the current defaults.

Add a test at `extension/tests/migrate_selectors.test.mjs` (`node:test` + `node:assert`, plain Node, no installs; importing `extension/provider_catalog.js` attaches `OyVoiceProviderCatalog` to `globalThis`). Run `node --test extension/tests/` and report the result.
