<#
.SYNOPSIS
Returns a summary of a CSV file: columns, row count, and sample values.
.DESCRIPTION
Reads a CSV file and returns one object per column with name, type, null count,
unique count, min, max, and sample values. Also returns file-level metadata.
Read-only: no file is modified. Requires read access to the CSV file.
.EXAMPLE
./scripts/data/Get-CsvSummary.ps1 -Path ./report.csv
.EXAMPLE
./scripts/data/Get-CsvSummary.ps1 -Path ./data.csv -Delimiter ';'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$Path,

    [char]$Delimiter = ','
)

$data = Import-Csv -LiteralPath $Path -Delimiter $Delimiter -ErrorAction Stop

$rowCount = $data.Count
$columns = $data[0].PSObject.Properties.Name

$columnSummary = $columns |
    ForEach-Object {
        $colName = $_
        $values = $data | ForEach-Object { $_.$colName } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        $numericValues = $values | Where-Object { $_ -match '^-?\d+(\.\d+)?$' } | ForEach-Object { [double]$_ }

        [pscustomobject]@{
            Column     = $colName
            NullCount  = $rowCount - $values.Count
            UniqueCount = ($values | Sort-Object -Unique).Count
            Min        = if ($numericValues.Count -gt 0) { ($numericValues | Sort-Object | Select-Object -First 1) } else { $null }
            Max        = if ($numericValues.Count -gt 0) { ($numericValues | Sort-Object -Descending | Select-Object -First 1) } else { $null }
            Sample     = ($values | Select-Object -First 3 -Unique) -join ', '
        }
    } |
    Sort-Object Column

[pscustomobject]@{
    FilePath     = $Path
    RowCount     = $rowCount
    ColumnCount  = $columns.Count
    Columns      = $columnSummary
    Delimiter    = $Delimiter
}
