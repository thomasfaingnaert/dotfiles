if exists('g:loaded_radix')
    finish
endif
let g:loaded_radix = 1

command -nargs=? -range=% Dec2hex call radix#dec2hex(<line1>, <line2>, <q-args>)
command -nargs=? -range=% Hex2dec call radix#hex2dec(<line1>, <line2>, <q-args>)
