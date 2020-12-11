require "base64"
require './lib/from_sips/sips_fhir_dispensing_generator'

filename = File.join(File.dirname(__FILE__), "example_sjis.csv")
params = {
    encoding: "Shift_JIS",
    nsips: Base64.encode64(File.read(filename, encoding: "shift_jis")),
}
generator = SipsFhirDispensingGenerator.new(params).perform
result = generator.to_json
puts result
__END__

shift_jis
VkVSMDEwNDAxLDIwMjAxMDAxMjM1OTU5LCxQQzAxLDEzLDQsMTIzNDU2NyyD\ngYNog4yBW5byi8csMTA2NjIyMiyTjIuek3ONYIvmmFqWe5bYglKBW4JRgVuC\nUCCPWpdGlXOTro5ZmFqWe5bYg0+DiYOTg2iDXoOPgVuCUYJRgmUsMDMxMjM0\nNTY3LAoxLDEyMzQ1Njc4LLbdvN6sILLB27MsirOO0oFAiOqYWSwxLDE5Nzkx\nMTAxLDE2MDgzODksk4yLnpNzkKKTY5JKi+aCUIFbglGCUoFbglOCVIFbglWC\nVoJXLDAzMzM1MzExNzAsMDMzMzUzMTE5MywwOTAxMjM0NTY3OCx5b3NoaW5v\ncmkua29kYW1hQG1lZGxleS5qcCwwLDEsMDYwNTAxMTYsMTk5OTAxMDEsgliC\nUYJPglOCVCyCUIJPLDEsMzAsNzAsMCwsLCwxNTEzODA5Miw5NjAzMjgzLDE5\nOTkwMTAxLCwsLCwsLCwsLDAsMCwwLDAsMCwwLDAsMCwwLDAsMCw0MTIyCjIs\nMjAyMDEwMDExMjM0NSwxLEEsMjAyMDEwMDEsMjAyMDEwMDQsMjAyMDEwMDEs\nMjAyMDEwMDEsMCwwLDAsaG9nZSw5OTk5OTk5LDEzLIOBg2iDjIFbg06DioNq\ng2KDTiwxMDY2MjIyLJOMi56Tc41gi+aYWpZ7ltiCUoFbglGBW4JQII9al0aV\nc5OujlmYWpZ7ltiDT4OJg5ODaINeg4+BW4JRglGCZSwwMzEyMzQ1NjcsMDEs\nk+CJyCwsLDAwMDEssrwgwNuzLIjjjnSBQJG+mFksOTk5OSyW8o3cjnSBQI6f\nmFksLCwsLCyW6YrUi3iT+pOZicGOWiAoMDCBRjAwKSwsMCwwLDAsMCwwLDAs\nMCwwCjMsMSwxMDEzMDQ0NDAwMDAwMDAwLJPglZ6BRYxvjPuBRYJQk/qCUonx\nkqmSi5dbkEiM4ywsLCwsMiwxLDMsMywyMDIwMTAwMSwyLDAsMCwsLCwsLAo0\nLDEsMSwxLDIyMzMwMDJGMTE3NCw2MTA0NTMxMTksMTAzODM1NDAxLCyDgINS\ng1+DQ4OTj/mCUYJUgk+CjYKHLEwtg0qDi4N7g1aDWINlg0ODkywwLDAsMCww\nLDAsMCwzLDEsj/ksMCwwLDAsMCwxLDguNSwsLCwyMjMzMDAyRjFaWlosLCyB\neZTKgXqDSoOLg3uDVoNYg2WDQ4OTj/mCUYJUgk+CjYKHLDAsMyyP+SwxLCws\nLCwxCjQsMiwxLDEsNjEzMjAxMkYxMDI1LDYxNjEzMDQ3NiwxMTA2MjY5MDEs\nLINwg5ODWIN8g4qDk4Jzj/mCUIJPgk8gglCCT4JPgo2ChyyDWoN0g0iDYINB\ng4CDd4NMg1qDYIOLiZaOX4mWLDAsMywyLjUsMC41LDAsMCw2LDEsj/ksMCww\nLDAsMCwxLDQwLjUsLCwsLCwsLDAsLCwsLCwsLAozLDEsMTAxMjA0MDQwMDAw\nMDAwMCyT4JWegUWMb4z7gUWCUJP6glGJ8ZKpl1uQSIzjLCwsLCwyLDEsMTQs\nMiwyMDIwMTAwMSwxLDAsMCwsLCwsLAo0LDEsMSwxLDExMzIwMDJCMTA2MCw2\nMTA0MjEwMDYsMTAwNjA3MDAyLCyDQYOMg3KDQYNgg5OOVYJQgk+BkyyDdING\ng2qDZ4NDg5MsMCwwLDAsMCwwLDAsMTAwLDEsgocsMCwwLDAsMCwxLDEyLjEs\nLCwsLCwsLDAsLCw1MCwsLCwsCjUsNTY4LDkwLDU1LDAsNjExLjgsMCw3OSw4\nMiwxNywyOCwxMCw4NzQsMjYyMCwxMDAsMCwyMDAsMjcyMCwyOTIwLDkyMCwy\nMDAwCjYsMSw4MCw0LDMsMTkyLDIsMTk0LCwsLCwsLCwsLCwsLCwsLCwsLCxB\nCjYsMiw4MCw0LDE0LDE5MiwyLDE5NCwsLCwsLCwsLCwsLCwsLCwsLCwsQQo3\nLDEsMTIzNDU2Nzg5LInBjlqCYCwxLDk5Cg==\n
