#$SQL_PATH = "C:\Users\AlexandrM\Dropbox\Projects\migrator\sql"
$SQL_PATH = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "sql"

$Config = Get-IniContent(Join-Path (Split-Path $MyInvocation.MyCommand.Path) "config.ini")


$DB_HOST = $Config.mysql.hostname
$DB_USER = $Config.mysql.username
$DB_PASS = $Config.mysql.password
$DB_NAME = $Config.mysql.database

$fixtures = $Config.migrator.fixtures.ToLower()
if(($fixtures -eq "true") -or ($fixtures -eq "yes") -or ($fixtures -eq "y") -or ($fixtures -eq "1")) {
   $LOAD_FIXTURES = $true
} else {
    $LOAD_FIXTURES = $false
}

Function Get-IniContent ($filePath) {
    $ini = @{}
    switch -regex -file $FilePath {
        "^\[(.+)\]" # Section 
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        } 
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

Function Get-Current-Version() {
    $CurrentVersion = Invoke-Expression "mysql --skip-column-names  -B -u $DB_USER -p$DB_PASS $DB_NAME -e 'SELECT version FROM version'" 2>$null | Select -Last 1
    if(-not $CurrentVersion) {
        $CurrentVersion = 0
    }
    return $CurrentVersion
}

Function Get-Available-Versions() {
    return Get-ChildItem $SQL_PATH | ?{ $_ -match "\d+" }
}

Function Get-Latest-Version() {
    return Get-Available-Versions | Select -Last 1
}

Function Get-Version-Info($Version) {
    return Get-Content(Join-Path -Path (Join-Path -Path $SQL_PATH -ChildPath $Version) -ChildPath "README.md")
}

Function Get-Version-Title($Version) {
    return Get-Version-Info($Version) | Select -First 1
}

Function Get-Version-Up($Version) {
    return [IO.File]::ReadAllText((Join-Path -Path (Join-Path -Path $SQL_PATH -ChildPath $Version) -ChildPath "up.sql"))
}

Function Get-Version-Down($Version) {
    return [IO.File]::ReadAllText((Join-Path -Path (Join-Path -Path $SQL_PATH -ChildPath $Version) -ChildPath "down.sql"))
}

Function Get-Version-Fixtures($Version) {
    $FixturesPath = Join-Path -Path (Join-Path -Path $SQL_PATH -ChildPath $Version) -ChildPath "fixtures.sql"
    if(Test-Path $FixturesPath) {
        return [IO.File]::ReadAllText($FixturesPath)
    } else {
        return $false
    }
}

Function Migrate($ToVersion) {    
    $CurrentVersion = Get-Current-Version

    if(-not $ToVersion) {
        $ToVersion = (Get-Latest-Version).Name
    }

    if($CurrentVersion -eq $ToVersion) {
        Write-Host "You are up to date" -ForegroundColor Green
    } else {

        if($CurrentVersion -lt $ToVersion) {
            $Versions = Get-Available-Versions | ?{ $_.Name -gt $CurrentVersion } | ?{ $_.Name -le $ToVersion }
        } else {
            $Versions = Get-Available-Versions | ?{ $_.Name -le $CurrentVersion } | ?{ $_.Name -gt $ToVersion } | Sort-Object -Descending
        }
    
        ForEach($Version in $Versions) {
            $Title = Get-Version-Title($Version)
        
            if($CurrentVersion -lt $ToVersion) {
                $Script = Join-Path $Version.FullName "up.sql"
                Write-Host "[+] Migrating to $Version" -ForegroundColor Yellow
            } else {
                $Script = Join-Path $Version.FullName "down.sql"
                Write-Host "[-] Rollback to $Version" -ForegroundColor Yellow
            }
        
            Write-Host $Title
            
            &cmd /c "mysql -u $DB_USER -p$DB_PASS $DB_NAME < $Script"
            
            if($CurrentVersion -lt $ToVersion) {
                    
                if($LOAD_FIXTURES) {
                    $Script = Join-Path $Version.FullName "fixtures.sql"
                    if(Test-Path $Script) {                            
                        &cmd /c "mysql -u $DB_USER -p$DB_PASS $DB_NAME < $Script"
                        Write-Host "[*] Fixtures for version $Version loaded" -ForegroundColor Green
                    }
                }

            }
            
        
            Write-Host
        }

    }
}

Function Rollback() {
    $CurrentVersion = Get-Current-Version
    $ToVersion = $CurrentVersion - 1

    if($ToVersion -gt 0) {
        Migrate($ToVersion)
    } else {
        Write-Host "There is no previous version that you can rollback to" -ForegroundColor Red
    }
}

if(($args[0] -eq "-1") -or ($args[0] -eq "rollback")) {
    Rollback
} elseif($args[0]) {
    Migrate($args[0])
} else {
    Migrate
}