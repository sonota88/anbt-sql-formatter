# 0.1.1 (2025-01-12)

No breaking changes.

## Improvements

- Avoid mutative string manipulation (coarse-tokenizer.rb: tokenize)
  - Prevents frozen literal warnings in Ruby 3.4 (Issue #17)
- Update comments (PR #14)
- Some small fixes, cleanups, formatting improvements


# 0.1.0 (2018-12-16)

## Breaking changes

- Support `"{schema}"."{table}"` notation.
  - Tokenize as a single name token. This affects formatter output:

```
echo 'select a from b.c, "d"."e"' | bin/anbt-sql-formatter

(before)
SELECT
        a
    FROM
        b.c
        ,"d" . "e"

(after)
SELECT
        a
    FROM
        b.c
        ,"d"."e"
```

# 0.0.7 (2018-08-11)

No breaking changes.

## Features

- New configuration parameter `Rule#in_values_num`
  for controlling number of values in IN clause per line.


# 0.0.6 (2018-03-31)

No breaking changes.


# 0.0.5 (2016-11-29)

No breaking changes.


# 0.0.4 (2016-06-24)

## Bug Fixes

- Wrong matching when a string literal or a comment includes a multiwords
  keyword.


# 0.0.3 (2015-02-14)

## Improvements

- Use `/usr/bin/env` for shebang.
