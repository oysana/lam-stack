OyVoice's provider detection accepts hostile lookalike domains. In this checkout, `fromUrl("https://chatgpt.com.evil.com/")` in `extension/provider_catalog.js` returns the ChatGPT provider, so a malicious page can pose as the dictation provider.

The intended rule: a URL counts as ChatGPT Web only when its hostname is `chatgpt.com` itself or a subdomain of `chatgpt.com` (for example `www.chatgpt.com`). Every other host must return `null`.

Fix `fromUrl` in `extension/provider_catalog.js`. Do not change how `google_speech` or non-https URLs are handled. Add a regression test at `extension/tests/provider_catalog.test.mjs` using `node:test` and `node:assert` (plain Node, no npm install; importing `extension/provider_catalog.js` attaches `OyVoiceProviderCatalog` to `globalThis`). Run your test with `node --test extension/tests/` and report what you ran and what passed.
