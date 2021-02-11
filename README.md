# UsefulDecode

A quick sketch of a more useful error reporting experience for `JSONDecoer`.

Before:


>valueNotFound(Swift.String, Swift.DecodingError.Context(codingPath: [_JSONKey(stringValue: "Index 0", intValue: 0), CodingKeys(stringValue: "address", intValue: nil), CodingKeys(stringValue: "city", intValue: nil), CodingKeys(stringValue: "birds", intValue: nil), _JSONKey(stringValue: "Index 1", intValue: 1), CodingKeys(stringValue: "name", intValue: nil)], debugDescription: "Expected String value but found null instead.", underlyingError: nil))

After:

```
Value not found: expected 'name' (String) at [0]/address/city/birds/[1]/name, got:
{
  "feathers" : "some",
  "name" : null
}
```

## Usage

```swift
let decoder = JSONDecoder()
let value = try decoder.decodeWithBetterErrors(MyCoolType.self, from: someData)
// there's no step 3
```

## Installation

There's no Package.swift yet. If I decide it's finished enough to be usable in production, I'll add one.
