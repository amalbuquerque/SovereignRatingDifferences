function! InvGrade()
    execute "%s/PanelData,/InvGrade_PanelData_WithAvgRating/g"
    execute "%s/_results.csv/_InvGrade_results.csv/g"
endfunction

function! SpecGrade()
    execute "%s/PanelData,/SpecGrade_PanelData_WithAvgRating/g"
    execute "%s/_results.csv/_SpecGrade_results.csv/g"
endfunction
