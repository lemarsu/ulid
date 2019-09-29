# ulid

Universally Unique Lexicographically Sortable Identifier for Crystal

![](https://raw.githubusercontent.com/diegogub/ulid/master/README/logo.png)

UUID can be suboptimal for many use-cases because:

- It isn't the most character efficient way of encoding 128 bits of randomness
- UUID v1/v2 is impractical in many environments, as it requires access to a unique, stable MAC address
- UUID v3/v5 requires a unique seed and produces randomly distributed IDs, which can cause fragmentation in many data structures
- UUID v4 provides no other information than randomness which can cause fragmentation in many data structures

Instead, herein is proposed ULID:

```crystal
require "ulid"

ulid = Ulid::ULID.new
ulid.to_s # => "05PQXW3M5XRY8ERYNCGZWD2MCM"
```

- 128-bit compatibility with UUID
- 1.21e+24 unique ULIDs per millisecond
- Lexicographically sortable!
- Canonically encoded as a 26 character string, as opposed to the 36 character UUID
- Uses Crockford's base32 for better efficiency and readability (5 bits per character)
- Case insensitive
- No special characters (URL safe)
- Monotonic sort order (correctly detects and handles the same millisecond)

For more information, see [ulid specs][ulid-specs]

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     ulid:
       github: lemarsu/ulid
       version: 0.1.0
   ```

2. Run `shards install`

## Usage

```crystal
require "ulid"

ulid = Ulid::ULID.new
ulid.to_s # => "05PQXW3M5XRY8ERYNCGZWD2MCM"

ulid2 = Ulid::ULID.new "05PQXW3M5XRY8ERYNCGZWD2MCM"
ulid2 == ulid # => true
```

## Contributing

1. Fork it (<https://github.com/lemarsu/ulid/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [LeMarsu](https://github.com/lemarsu) - creator and maintainer

[ulid-specs]: https://github.com/ulid/spec
