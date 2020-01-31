<#
.Synopsis
    Generates random passwords
.DESCRIPTION
    This cmdlet can be used to generate random passwords
    There are two forms for passwords, random and pronounceable.
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
        $i$g$o$l$n$u$u$y
        size, age, colour, element, noun, 2 numbers, symbol
.EXAMPLE
#>
function New-Password {
    [CmdletBinding()]
    param (
        [switch]$random = $false,
        [string]$format = '$i$g$o$l$n$u$u$y'
    )

    $root = $PSScriptRoot
    # $root = 'C:\Users\mcarter\Documents\WindowsPowerShell\Modules\pwgen'
    
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
                throw "invalid escape sequence '$current'"
            }
        } else {
            [void]$outstring.Append($current)
        }
    }

    return $outstring.ToString()
}
