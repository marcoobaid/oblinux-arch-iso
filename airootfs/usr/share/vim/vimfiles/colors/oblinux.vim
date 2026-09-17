" OBLinux Slate & Amber color scheme: restrained, terminal-safe, no plugins.
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "oblinux"

hi Normal       ctermfg=252 ctermbg=234 guifg=#f2f3f5 guibg=#151a22
hi CursorLine   ctermbg=235 guibg=#202936
hi LineNr       ctermfg=109 ctermbg=234 guifg=#a9b8c8 guibg=#151a22
hi CursorLineNr ctermfg=173 ctermbg=235 cterm=bold guifg=#d68a3c guibg=#202936 gui=bold
hi StatusLine   ctermfg=234 ctermbg=173 cterm=bold guifg=#151a22 guibg=#d68a3c gui=bold
hi StatusLineNC ctermfg=252 ctermbg=60 guifg=#f2f3f5 guibg=#2c3a4e
hi Visual       ctermbg=60 guibg=#3f6690
hi Search       ctermfg=234 ctermbg=173 guifg=#151a22 guibg=#d68a3c
hi IncSearch    ctermfg=234 ctermbg=221 cterm=bold guifg=#151a22 guibg=#e6a65f gui=bold
hi Comment      ctermfg=109 cterm=italic guifg=#a9b8c8 gui=italic
hi Constant     ctermfg=180 guifg=#ddb07b
hi String       ctermfg=151 guifg=#b7d7b0
hi Identifier   ctermfg=110 guifg=#82add8
hi Statement    ctermfg=173 cterm=bold guifg=#d68a3c gui=bold
hi PreProc      ctermfg=146 guifg=#b9a6cf
hi Type         ctermfg=116 guifg=#83c5be
hi Special      ctermfg=215 guifg=#e6a65f
hi Error        ctermfg=231 ctermbg=124 cterm=bold guifg=#ffffff guibg=#a83232 gui=bold
hi Todo         ctermfg=234 ctermbg=173 cterm=bold guifg=#151a22 guibg=#d68a3c gui=bold
hi Directory    ctermfg=110 cterm=bold guifg=#82add8 gui=bold
hi NonText      ctermfg=60 guifg=#52647a
hi MatchParen   ctermfg=234 ctermbg=109 cterm=bold guifg=#151a22 guibg=#a9b8c8 gui=bold
hi Pmenu        ctermfg=252 ctermbg=60 guifg=#f2f3f5 guibg=#2c3a4e
hi PmenuSel     ctermfg=234 ctermbg=173 guifg=#151a22 guibg=#d68a3c
