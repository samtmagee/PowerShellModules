<#
.Synopsis
    Expands {} delimeted strings via a pscustomobject passed in
.DESCRIPTION
    This cmdlet expands inserts hashtable (pscustomobjects) contents
    into a string.

    It scans the input string using the regular expression
        {[0-9a-zA-Z_]+}
    And replaces instances of the matches with the properties from the InputObject.

    Given the string
        Hello, {Name} {Surname}
    And the input hashtable
        @{Name='John'; Surname='Smith'}
    It would find {Name} and {Surname} and use the values from the hashtable to
    create the output
        Hello, John Smith
    {Name} is replaced with John, and {Surname} is replaced with Smith

    If the key is not found within the InputObject, an empty string is inserted
.EXAMPLE
    Using a pipe:

    $person = [pscustomobject]@{
        Name = "John"
        Surname = "Smith"
    }
    $person | Expand-FormatString -Text "Hello, {Name} {Surname}"


    Multiple objects can be piped:

    Get-ADUser -Filter '*' -Property 'DisplayName' | Expand-FormatString -Text 'Hello {DisplayName}, your email is {UserPrincipalName}'


    Using variables:

    Expand-FormatString -Text "Hello, {Name} {Surname}" -InputObject $person


    Reading a file and formatting it:

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

    Process {
        [System.Text.RegularExpressions.Regex]::Replace($Text, '{[0-9a-zA-Z_]+}', {
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
}
