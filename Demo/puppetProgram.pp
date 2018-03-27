node 'james-demo'{
exec { 'powershell_system32':
  command => 'c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -Command "Get-Disk |

Where partitionstyle -eq "raw" |

Initialize-Disk -PartitionStyle MBR -PassThru |

New-Partition -DriveLetter "S" -UseMaximumSize |

Format-Volume -FileSystem NTFS -NewFileSystemLabel "APPDATA" -Confirm:$false"',
  logoutput => true,
}


file { 'bin':
  ensure   => 'directory',
  path => 's:\\bin',
  require => Exec['powershell_system32']  
}

$iis_features = ['Web-Server','Web-WebServer','Web-Asp-Net45','NET-Framework-45-ASPNET','Web-Filtering','Web-Mgmt-Console','Web-Mgmt-Tools']

windowsfeature { $iis_features:
  ensure => present,
}


dsc_xwebsite {'Stop DefaultSite':
    dsc_ensure       => 'present',
    dsc_name         => 'Default Web Site',
    dsc_state        => 'Stopped',
    
  }


dsc_xwebsite {'puppet':
    dsc_ensure       => 'present',
    dsc_name         => 'puppet',
    dsc_state        => 'Started',
    dsc_physicalpath => 's:\\bin',
    dsc_applicationpool => 'puppet'
  } 
dsc_xWebAppPool {'puppet':
        
    dsc_name   => 'puppet',
    dsc_ensure => 'Present',
    dsc_state  => 'Started',
            
  }
}
