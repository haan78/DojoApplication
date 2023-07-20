<?php
//phpinfo();

function versionnum(string $ver) : float {    
    if (preg_match_all("/^([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{1,2})($|-.*)/",$ver,$matches)) {
        $strval = $matches[1][0].str_pad($matches[2][0],2,"0",STR_PAD_LEFT).".".str_pad($matches[3][0],2,"0",STR_PAD_LEFT);
        return floatval($strval);
    } else {        
        return 0;
    }    
}

echo number_format(versionnum(""),2);