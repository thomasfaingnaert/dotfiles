if ($^O eq "linux") {
    $pdf_previewer='evince %O %S';
}
else {
    $pdf_previewer='SumatraPDF.exe %O %S';
}
$pdflatex='pdflatex -file-line-error -synctex=1 -interaction=nonstopmode %O %B';
$pdf_mode=1;
