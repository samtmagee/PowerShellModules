<#
.Synopsis
   Sort files into folders by date
.DESCRIPTION
   Sort files from a source folder into a destination folder based on the year, month and day of the LastWriteTime.  A file with a LastWriteTime of January 2nd 1970 will be moved to a folder in your destination Destination:\1970\01\02 of the file
.EXAMPLE
   Sort-FilesbyDate -source 'C:\Users\Fresco\Downloads\' -destination 'C:\Users\Fresco\Pictures\sorted'
.EXAMPLE
   Sort-FilesbyDate -source 'C:\Users\Fresco\Downloads\' -destination 'C:\Users\Fresco\Pictures\sorted' -extention '*.jpg','*.avi'
#>
function Sort-FilesbyDate {
    param (
        $source,
        $destination,
        $extention = '*.*'
    )

    $files = Get-ChildItem -Recurse -File -Path $source -Include $extention

    foreach ($file in $files) {
    
        $fileYear = Get-Date -Date $file.LastWriteTime -Format 'yyyy'
        $fileMonth = Get-Date -Date $file.LastWriteTime -Format 'MM'
        $fileDay = Get-Date -Date $file.LastWriteTime -Format 'dd'

        $destinationDateDirectory = "$destination\$fileYear\$fileMonth\$fileDay"
        $destinationDateDirectoryExists = Test-Path -Path $destinationDateDirectory

        if (! $destinationDateDirectoryExists) { New-Item -Path $destinationDateDirectory -ItemType Directory }

        try {
            Move-Item -Path $file.FullName -Destination $destinationDateDirectory -ErrorAction Stop
        }
        catch [System.IO.IOException] {
            Write-host "$($error[-1].CategoryInfo.Activity) $($error[-1].CategoryInfo.Category): $($error[-1].Exception.Message) $($file.FullName)" -ForegroundColor Red
        }
        catch {
            Write-host "It was probably nothing, don't worry about it." -ForegroundColor Blue
        }
        finally {
            $error.Clear()
        }
    }
}
