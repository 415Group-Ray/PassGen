function Shuffle-PassGenArray {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$InputObject
    )

    $result = @($InputObject)

    for ($index = $result.Count - 1; $index -gt 0; $index--) {
        $swapIndex = Get-Random -Minimum 0 -Maximum ($index + 1)
        $temporary = $result[$swapIndex]
        $result[$swapIndex] = $result[$index]
        $result[$index] = $temporary
    }

    return ,$result
}
