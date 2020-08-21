<#
.Synopsis
    Generates random passwords
.DESCRIPTION
    This cmdlet can be used to generate random passwords
    Format strings are
        $i => s[i]ze
        $g => a[g]e
        $o => c[o]lours
        $l => e[l]ements (mostly metals)
        $d => a[d]jectives

        $a => [a]nimals
        $b => [b]uildings
        $v => [v]ehicles
        $n => [n]ouns (animals, vehicles, buildings)

        $h => c[h]ar
        $u => n[u]mber
        $y => s[y]mbol (!$%^&*#+-_=)
    The default format is
        $i$o$a$u$y
        size, colour, animal, numbers, symbol
.EXAMPLE
#>
function New-Password {
    [CmdletBinding()]
    param (
        [string]$format = '$i$o$a$u$y'
    )

    $root = $PSScriptRoot

    $mappings = [PSCustomObject]@{
        i = [string[]](Get-Content "$root\sizes.txt")
        g = [string[]](Get-Content "$root\ages.txt")
        o = [string[]](Get-Content "$root\colours.txt")
        l = [string[]](Get-Content "$root\elements.txt")
        d = [string[]](Get-Content "$root\adjectives.txt")

        a = [string[]](Get-Content "$root\animals.txt")
        b = [string[]](Get-Content "$root\buildings.txt")
        v = [string[]](Get-Content "$root\vehicles.txt")
        n = [string[]](@(Get-Content "$root\animals.txt"; Get-Content "$root\buildings.txt"; Get-Content "$root\vehicles.txt"))

        h = [string[]](Get-Content "$root\chars.txt")
        u = [string[]](Get-Content "$root\numbers.txt")
        y = [string[]](Get-Content "$root\symbols.txt")
    }

    $rng = [System.Random]::new()
    $enumerator = $format.GetEnumerator()
    [System.Text.StringBuilder]$outstring = ""

    while($enumerator.MoveNext()) {
        [char]$current = $enumerator.Current
        if ($current -eq '$') {
            if (!$enumerator.MoveNext()) { throw 'invalid escape sequence' }
            $current = $enumerator.Current
            $m = $mappings.$current
            if ($m) {
                [void]$outstring.Append($m[$rng.Next($m.Count)]);
            } else {
                throw "invalid escape sequence $'$current'"
            }
        } else {
            [void]$outstring.Append($current)
        }
    }

    return [PSCustomObject]@{
        Password = $outstring.ToString()
        SecureString = (ConvertTo-SecureString -String $outstring.ToString() -AsPlainText -Force)
    }
}
