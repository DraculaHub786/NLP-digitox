#!/usr/bin/env python3
"""
NLP-Digitox NSFW blocklist updater (binary/hash edition).

Why not Kotlin source?
- ~900k+ domains cannot live in a Kotlin arrayOf(): method-size limits,
  exploded build times, tens of MB of DEX bloat.
- A runtime Map<String, Boolean> of that size costs >100 MB RAM.

What this does instead:
- Downloads Block List Project porn.txt (maintained upstream list).
- Normalizes + dedupes domains, reports overlap with the curated
  NsfwDomains.kt (informational only).
- Emits a compact binary asset: sorted 64-bit FNV-1a hashes of every
  domain, delta-encoded as LEB128 varints, gzip-compressed.
  -> ~930k domains fit in a small asset, ~7.5 MB LongArray in RAM,
     O(log n) binary-search lookups, negligible false-positive rate.

Runtime pairing:
    utils/NsfwBlocklistStore.kt   (loads asset, decodes, lookups)

Usage:
    python tools/update_nsfw_blocklist.py android/app/src/main/java/com/nlp/digitox/utils/NsfwDomains.kt

Optional:
    python tools/update_nsfw_blocklist.py <existing_kt> \
        --bin-out android/app/src/main/assets/nsfw/nsfw_hashes.bin
"""

import argparse
import gzip
import hashlib
import re
import sys
import urllib.request
from pathlib import Path

SOURCE_URL = "https://raw.githubusercontent.com/blocklistproject/Lists/master/porn.txt"

DOMAIN_RE = re.compile(
    r"^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$",
    re.I,
)

FNV_OFFSET = 0xCBF29CE484222325
FNV_PRIME = 0x100000001B3


def fnv1a64(value: str) -> int:
    """64-bit FNV-1a, byte-wise, UTF-8 encoded (must mirror Kotlin impl)."""
    h = FNV_OFFSET
    for byte in value.encode("utf-8"):
        h ^= byte
        h = (h * FNV_PRIME) & 0xFFFFFFFFFFFFFFFF
    return h


def normalize(value: str):
    value = value.strip().lower()
    value = re.sub(r"^[a-z]+://", "", value)
    value = value.split("/", 1)[0]
    value = value.split(":", 1)[0]
    value = value.removeprefix("www.")
    value = value.rstrip(".")
    if DOMAIN_RE.fullmatch(value):
        return value.lower()
    return None


def extract_existing_domains(text: str):
    """Informational: how much of the curated list the source already covers."""
    domains = set()
    for item in re.findall(r'"([^"\r\n]+)"', text):
        d = normalize(item)
        if d:
            domains.add(d)
    return domains


def download_source():
    req = urllib.request.Request(
        SOURCE_URL,
        headers={"User-Agent": "NLP-Digitox-blocklist-updater/1.0"},
    )
    with urllib.request.urlopen(req, timeout=120) as response:
        return response.read().decode("utf-8", errors="replace")


def parse_source(text: str):
    domains = set()
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue

        # Accept common hosts/adblock/domain-list forms.
        line = re.sub(r"^\|\|", "", line)
        line = line.split("^", 1)[0]
        if line.startswith("0.0.0.0 "):
            line = line[8:]
        elif line.startswith("127.0.0.1 "):
            line = line[10:]

        d = normalize(line)
        if d:
            domains.add(d)
    return domains


def write_varint(buf, value: int):
    """Unsigned LEB128."""
    while True:
        byte = value & 0x7F
        value >>= 7
        if value:
            buf.append(byte | 0x80)
        else:
            buf.append(byte)
            return


def encode_payload(domains):
    """Sorted hashes -> delta varints. Returns (payload_bytes, count, sha256_hex)."""
    hashes = sorted({fnv1a64(d) for d in domains})

    # Sanity: detect accidental 64-bit collisions inside the list itself.
    if len(set(hashes)) != len(hashes):
        raise RuntimeError("Internal hash collision detected - aborting")

    payload = bytearray()
    prev = 0
    for h in hashes:
        write_varint(payload, h - prev)
        prev = h

    digest = hashlib.sha256(payload).hexdigest()
    return bytes(payload), len(hashes), digest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "existing_file",
        nargs="?",
        default="android/app/src/main/java/com/nlp/digitox/utils/NsfwDomains.kt",
        help="Curated Kotlin blocklist (used for overlap stats)",
    )
    parser.add_argument(
        "--bin-out",
        default="android/app/src/main/assets/nsfw/nsfw_hashes.bin",
        help="Output path for the gzipped hash asset",
    )
    parser.add_argument("--skip-download", action="store_true",
                        help="Only print curated-list stats; skip network")
    args = parser.parse_args()

    existing_path = Path(args.existing_file)
    existing = set()
    if existing_path.exists():
        print("Reading curated NsfwDomains.kt (overlap stats)...")
        existing = extract_existing_domains(
            existing_path.read_text(encoding="utf-8", errors="replace")
        )
        print(f"Curated normalized domains:  {len(existing):,}")
    else:
        print(f"WARN: curated file not found ({existing_path}); skipping stats")

    if args.skip_download:
        print("--skip-download set; nothing to do beyond stats.")
        return

    print("Downloading maintained source...")
    source = parse_source(download_source())
    print(f"Source normalized domains:   {len(source):,}")

    overlap = len(source & existing)
    print(f"Already covered by curated:  {overlap:,} "
          f"({overlap / max(len(existing), 1):.1%} of curated)")

    print("Encoding hashes...")
    payload, count, digest = encode_payload(source)

    out_path = Path(args.bin_out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with gzip.GzipFile(filename="", mode="wb",
                       fileobj=out_path.open("wb"), mtime=0) as gz:
        gz.write(payload)

    size_kb = out_path.stat().st_size / 1024
    print(f"Wrote: {out_path}")
    print(f"       domains={count:,}  asset={size_kb:,.0f} KB  "
          f"ram~{count * 8 / 1024 / 1024:.1f} MB  sha256={digest[:16]}")


if __name__ == "__main__":
    main()
