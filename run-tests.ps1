param (
    [switch]$Strict,
    [switch]$SkipAnalyze,
    [switch]$Coverage
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   BELTEI Portal - Test Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$AnalysisFailed = $false

if (-not $SkipAnalyze) {
    Write-Host "`n[1/2] Running Flutter Analyze..." -ForegroundColor Yellow
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        $AnalysisFailed = $true
        if ($Strict) {
            Write-Host "`n[!] Static analysis failed. Strict mode is ON, exiting." -ForegroundColor Red
            exit 1
        } else {
            Write-Host "`n[!] Static analysis found issues (warnings/infos). Continuing to tests..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[PASS] Static analysis passed successfully!" -ForegroundColor Green
    }
} else {
    Write-Host "`n[-] Skipping static analysis." -ForegroundColor Gray
}

if ($Coverage) {
    Write-Host "`n[2/2] Running Flutter Tests with Coverage..." -ForegroundColor Yellow
    flutter test --coverage
} else {
    Write-Host "`n[2/2] Running Flutter Tests..." -ForegroundColor Yellow
    flutter test
}

$TestsFailed = ($LASTEXITCODE -ne 0)

if ($TestsFailed) {
    Write-Host "`n[!] Tests failed." -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Green
if ($AnalysisFailed) {
    Write-Host "   [PASS] Tests passed, but static analysis has issues." -ForegroundColor Yellow
} else {
    Write-Host "   [PASS] All checks and tests passed successfully!" -ForegroundColor Green
}
Write-Host "========================================" -ForegroundColor Green
