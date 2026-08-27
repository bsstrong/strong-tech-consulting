# Worksite Jurisdiction Resolver Contract

## Purpose

The municipal worksite-tax registry requires a legal worksite-jurisdiction result. A postal city, mailing city, employer-entered city, or employee home address is not a substitute for that result.

This contract defines the boundary between address resolution and the governed three-result tax-screening decision. It does not select a geocoder or implement HelixOS.

## Input

Required worksite fields:

- street address;
- city/locality as entered;
- state;
- ZIP code;
- country;
- evaluation date.

Employee home address is not an input to this worksite-only screen. Resident-only taxes remain a separate review class and require a different workflow.

## Successful resolution output

```json
{
  "country_code": "US",
  "state_code": "XX",
  "jurisdiction_type": "incorporated city",
  "jurisdiction_name": "Canonical legal name",
  "jurisdiction_id_scheme": "authoritative scheme name",
  "jurisdiction_id": "stable authoritative identifier",
  "inside_legal_boundary": true,
  "resolver_source": "authoritative dataset or service",
  "resolver_version": "immutable version or snapshot",
  "resolved_at": "ISO-8601 timestamp",
  "confidence": "AUTHORITATIVE_UNIQUE"
}
```

The result must identify the legal municipality, not merely echo a mailing label. State-specific identifiers such as Ohio municipal FIPS and Pennsylvania PSD codes must be preserved where they are authoritative for the tax source.

## Non-success outcomes

- `INCOMPLETE_ADDRESS`
- `NO_AUTHORITATIVE_RESULT`
- `AMBIGUOUS_BOUNDARY`
- `MULTIPLE_JURISDICTIONS`
- `UNSUPPORTED_COUNTRY`
- `RESOLVER_UNAVAILABLE`
- `SOURCE_VERSION_UNAVAILABLE`

Every non-success outcome maps to tax-screening result `UNDETERMINED`.

## Matching rules

1. Match stable authoritative jurisdiction ID when the registry provides one.
2. Otherwise require the resolved state, legal jurisdiction type, and canonical legal name to agree exactly with a governed alias/canonical-name record.
3. Never use fuzzy name matching to produce `CLEAR` or a confirmed-positive result.
4. A city/state name match may be retained as a discovery hint, but its decision remains `UNDETERMINED` unless the product explicitly adopts a conservative false-positive-only proxy for `BUFFER_REVIEW_REQUIRED`.
5. County, school district, transit district, JEDD/JEDZ, and other nonmunicipal matches must not be silently mapped to a municipality row.
6. Consolidated or independent cities must retain their legal jurisdiction type and must not be converted to an ordinary county.

## Screening handoff

The screening operation receives the resolver output, governed dataset version, and evaluation date. It returns:

- decision;
- machine-readable reason code;
- dataset version;
- resolver source/version;
- matched registry record ID, if any;
- evidence and coverage status;
- evaluation timestamp.

`CLEAR` is permitted only for a unique authoritative resolution in a `COMPLETE` or `NO_AUTHORITY_CONFIRMED` state with no current direct-primary match. All `PARTIAL`-state misses, evidence-queue matches, resolution failures, and evaluation failures return `UNDETERMINED`.
