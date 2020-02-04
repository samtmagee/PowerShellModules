<#
.Synopsis
    Expands {} delimeted strings via a pscustomobject passed in
.DESCRIPTION
    
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
        # enumerate through each char in the input string
        $enumerator = $Text.GetEnumerator()
        $property = ""
        [System.Text.StringBuilder]$outstring = ""
        while($enumerator.MoveNext())
        {
            [char]$current = $enumerator.Current
            if ($current -eq [char]'{')
            {
                do
                {
                    [void]$enumerator.MoveNext()
                    $property += $enumerator.Current
                } until($enumerator.Current -eq '}')
                # remove the trailing '}'
                $property = $property[0..($property.Length - 2)] -join ''
                [void]$outstring.Append($InputObject.$property);
                $property = ""
            } else {
                [void]$outstring.Append($current);
            }
        }

        return $outstring.ToString()
    }
}
