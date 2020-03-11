<#
.Synopsis
    Expands {} delimeted strings via a pscustomobject passed in
.DESCRIPTION
    This cmdlet expands inserts hashtable (pscustomobjects) contents
    into a string.

    It scans the input string for '{' characters and then
.EXAMPLE
    $person = [pscustomobject]@{
        Name = "John"
        Surname = "Smith"
    }
    $person | Expand-FormatString -Text "Hello, {Name} {Surname}"

    Expand-FormatString -Text "Hello, {Name} {Surname}" -InputObject $person

    Expand-FormatString -Text (Get-Content 'input.txt' -Raw) -InputObject $person
#>
function Expand-FormatString {
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Text,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true)]
        $InputObject
    )

    return [System.Text.RegularExpressions.Regex]::Replace($Text, '{[0-9a-zA-Z_]+}', {
        param (
            [System.Text.RegularExpressions.Match]
            $Match
        )
        # get the matched value, e.g.: {Name}
        $Value = $Match.Value
        # remove the braces, e.g.: Name
        $property = $Value[1..($Value.Length - 2)] -join ''
        # Look up that property in the inputobject
        return $InputObject.$property
    })
}
