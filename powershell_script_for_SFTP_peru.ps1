Get-ChildItem .\Documents -Directory | Foreach {
   $record=@()
   $Files = Get-ChildItem $_.FullName -Recurse -File
   $Size = '{0:N2}' -f (( $Files | Measure-Object -Property Length -Sum).Sum /1MB)
#    [PSCustomObject]@{Profile = $_.FullName ; TotalObjects = "$($Files.Count)" ; SizeMB = $Size}
   $record = "" | Select Profile, TotalObjects, SizeMB
   $record.Profile = $_.FullName
   $record.TotalObjects = "$($Files.Count)"
   $record.SizeMB = $Size
   $report += $record
   }
   $report | Export-Csv -Path C:\Users\pnatarajan.da\Desktop\caftp.csv
