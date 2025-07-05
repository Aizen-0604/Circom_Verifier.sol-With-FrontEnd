import { buildBabyjub } from 'circomlibjs';
import { randomBytes, createHash } from 'crypto';
import { writeFileSync } from 'fs';

const babyJub = await buildBabyjub();
const F       = babyJub.F;                     // field helper

// ── constants ────────────────────────────────────────────────────────────
const L  = babyJub.subOrder;                   // subgroup order (≈ 2²⁵⁰)
const G  = babyJub.Base8;                      // generator inside prime subgroup

// ── helper: hash bytes → uint256 < L ─────────────────────────────────────
function sha256ToFr(bytes) {
  const h = createHash('sha256').update(bytes).digest('hex');
  return (BigInt('0x' + h) & ((1n << 250n) - 1n)) % L;
}

// ── 1. keypair (scalar a, public A = a·G) ────────────────────────────────
const a = BigInt('0x' + randomBytes(32).toString('hex')) % L;
const A = babyJub.mulPointEscalar(G, a);       // [Ax, Ay]

// ── 2. message & hash ────────────────────────────────────────────────────
const MSG = 'hello Baby‑JubJub 👋';
const mBytes = Buffer.from(MSG, 'utf8');
const M = sha256ToFr(mBytes);                  // field element

// ── 3. deterministic nonce r = H(a || m)  (like Ed25519) ─────────────────
const r = sha256ToFr(Buffer.concat([Buffer.from(a.toString(16).padStart(64,'0'), 'hex'), mBytes]));
const R = babyJub.mulPointEscalar(G, r);       // [Rx, Ry]

// ── 4. challenge k = H(R || A || m) ──────────────────────────────────────
const kInput = Buffer.concat([
  Buffer.from(R[0].toString(16).padStart(64,'0'), 'hex'),
  Buffer.from(R[1].toString(16).padStart(64,'0'), 'hex'),
  Buffer.from(A[0].toString(16).padStart(64,'0'), 'hex'),
  Buffer.from(A[1].toString(16).padStart(64,'0'), 'hex'),
  mBytes
]);
const k = sha256ToFr(kInput);

// ── 5. signature scalar s = (r + k·a) mod L ──────────────────────────────
const s = (r + k * a) % L;

// ── 6. write JSON for Remix ──────────────────────────────────────────────
const out = {
  message : MSG,
  Ax : A[0].toString(),
  Ay : A[1].toString(),
  Rx : R[0].toString(),
  Ry : R[1].toString(),
  s  :  s.toString(),
  M  :  M.toString()
};
writeFileSync('signature.json', JSON.stringify(out, null, 2));
console.log('✅  signature.json created – copy those numbers into Remix!');
