# Realtime Database rules tests

`database.rules.json` is the last line of defence for shared sessions: it is what
stops an edited client from renaming someone else's room, starting a run it does
not own, or claiming a completion before the run has ended. A rule is also the
only place a rejection is *invisible* — the app sees a bare
`permission-denied` and has to guess at the cause.

These tests run the real rules against the Realtime Database emulator, using the
same payloads `SessionService` writes, so a rules change that breaks the client
fails here instead of on a user's phone.

## Running them

```sh
cd test/rules
npm install
npm test
```

`npm test` starts the emulator, runs the three suites, and shuts it down again
(`firebase emulators:exec`). Nothing touches a live project: the emulator runs
under the throwaway project id `demo-nlp`. All ten cases should pass.

Requires Node 18 or newer — the suites use the built-in `node --test` runner and
`node:assert` — plus the Firebase CLI and a JDK on `PATH`.

### Why the test script looks the way it does

Three details are load-bearing; changing any of them turns the suite green for
the wrong reason or red for no reason:

* **`--test-concurrency=1`.** `node --test` runs test *files* in parallel by
  default. `initializeTestEnvironment` loads `database.rules.json` into the one
  shared emulator and `TestEnvironment.cleanup()` removes it again, so two files
  running side by side take turns deleting each other's ruleset. The symptom is
  every "should succeed" write coming back `permission-denied` and every
  "should be refused" case still passing — a green run that proves nothing. The
  files must run one after another.
* **`firebase.json` in this directory sets no `database.rules`.** The rules do
  not live here, and the Firebase CLI refuses a config whose rules path resolves
  outside the config's own directory (`../../database.rules.json is outside of
  project directory`). `harness.js` reads the real `database.rules.json` and
  hands it to `initializeTestEnvironment`, which uploads it to the emulator, so
  the emulator-startup rules are irrelevant. A file with no rules starts the
  emulator with its default (open) rules and the harness then installs the real
  ones before any test body runs.
* **`withSecurityRulesDisabled` returns `Promise<void>`.** It discards whatever
  its callback returns, so `readRaw` captures the snapshot into an outer
  variable instead of returning it. Returning it directly made every assertion
  read `undefined`, which failed the "should succeed" cases on an `undefined`
  comparison rather than on the write it was meant to check.

## What is covered

| File | Proves |
| --- | --- |
| `name_length.test.js` | an 80-character name is accepted, 81 is refused, and the refusal takes the whole atomic create with it |
| `join_by_code.test.js` | a code-join succeeds; a bare ID join of an invite room, a code for a different room, and any join of a started room are all refused |
| `start_owner_only.test.js` | the owner can start with a server timestamp, a member cannot start at all, and nobody can backdate `runStartAt` to a client clock |

## Adding a case

1. Put the shared payload builders in `harness.js` — never inline a payload that
   is supposed to mirror the client. `harness.js` is the single place that has to
   be kept in step with `SessionService`.
2. Add the new `*.test.js` file.
3. Add it to the `test` script in `package.json`. The file list is explicit on
   purpose: `node --test .` would also execute `harness.js`, which has no tests
   and would report a spurious failure.
