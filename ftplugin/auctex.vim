" Vim filetype plugin
" Language:	LaTeX
" Maintainer: Carl Mueller, cmlr@math.rochester.edu
" Last Change:	December 3, 2001
" Website:  http://www.math.rochester.edu/u/cmlr/vim/syntax/index.html

" Auctex-style macros for Latex typing.
" You will have to customize the functions RunLatex(), Xdvi(), 
" and the maps for inserting template files, on lines 87 - 94.

" Run Latex
noremap <buffer> K :call <SID>RunLatex()<CR><Esc>
noremap <buffer> <C-Tab> :call <SID>RunLatex()<CR><Esc>
inoremap <buffer> <C-Tab> <Esc>:call <SID>RunLatex()<CR><Esc>

" Due to Ralf Aarons
" In normal mode, gw formats the paragraph (without splitting dollar signs).
function! s:TeX_par()
    if (getline(".") != "")
        let s:op_wrapscan = &wrapscan
        set nowrapscan
        let s:par_begin = '^$\|^\s*\\begin{\|^\s*\\\['
        let s:par_end = '^$\|^\s*\\end{\|^\s*\\\]'
        exe '?'.s:par_end.'?+'
        norm V
        exe '/'.s:par_begin.'/-'
        norm Q
        let &wrapscan = s:op_wrapscan
    endif
endfun
map <buffer> gw :call <SID>TeX_par()<CR>

function! s:RunLatex()
    write
    split %<.log
    q!
    ! xterm -bg ivory -fn 7x14 -e latex % &
"    ! latex %
endfunction

" Find Latex Errors
" To find the tex error, first run Latex (see the 2 previous maps).
" If there is an error, press "x" or "r" to stop the Tex processing.
" Then press Shift-Tab to go to the position of the error.
noremap <buffer> <S-Tab> :call <SID>NextTexError()<CR><Space>
inoremap <buffer> <S-Tab> <Esc>:call <SID>NextTexError()<CR><Space>

function! s:NextTexError()
    only
    edit %<.log
    edit %
    exe "normal G/\^l\\.\\d\<CR>f zz"
    let s:numberlength = col(".") - 3
    normal $
    let s:errorposition = col(".") - s:numberlength - 4
    let s:linenumber = strpart(getline(line(".")), 2, s:numberlength)
        "Put a space in the .log file so that you can see where you were,
	"and move on to the next latex error.
    exe "normal I \<Esc>"
    write
    split #
    exe "normal" s:linenumber . "G" . s:errorposition . "lzz"
endfunction

noremap <buffer> <F9> <C-W>o
inoremap <buffer> <F9> <C-O><C-W>o

" Run xdvi
noremap <buffer> <M-Tab> :call <SID>Xdvi()<CR><Space>
inoremap <buffer> <M-Tab> <Esc>:call <SID>Xdvi()<CR><Space>
function! s:Xdvi()
    write
    ! xterm -bg ivory -fn 7x14 -e latex %
    ! xterm -bg ivory -fn 7x14 -e latex %
    ! xdvi -expert -s 6 -margins 2cm -geometry 750x950 %< &
endfunction

" Run Ispell (Thanks the Charles Campbell)
" The first set is for vim, the second set for gvim.

"noremap <buffer> <S-Insert> :w<CR>:!ispell %<CR><Space>:e %<CR><Space>
"inoremap <buffer> <S-Insert> <Esc>:w<CR>:!ispell %<CR><Space>:e %<CR><Space>
"vnoremap <buffer> <S-Insert> <C-C>'<c'><Esc>:e ispell.tmp<CR>p:w<CR>:!ispell %<CR><CR>:e %<CR><CR>ggddyG:bwipeout!<CR>:!rm ispell.tmp*<CR><Esc>pkdd
"vnoremap <buffer> <S-Insert> <C-C>`<v`>s<Space><Esc>mq:e ispell.tmp<CR>i<C-R>"<Esc>:w<CR>:!ispell %<CR><CR>:e %<CR><CR>ggVG<Esc>`<v`>s<Esc>:bwipeout!<CR>:!rm ispell.tmp*<CR>`q"_s<C-R>"<Esc>

noremap <S-Insert> :w<CR>:! xterm -bg ivory -fn 10x20 -e ispell %<CR><Space>:e %<CR><Space>
inoremap <S-Insert> <Esc>:w<CR>:! xterm -bg ivory -fn 10x20 -e ispell %<CR><Space>:e %<CR><Space>
"vnoremap <S-Insert> <C-C>'<c'><Esc>:e ispell.tmp<CR>p:w<CR>:! xterm -bg ivory -fn 10x20 -e ispell %<CR><CR>:e %<CR><CR>ggddyG:bwipeout!<CR>:!rm ispell.tmp*<CR><Esc>pkdd
vnoremap <S-Insert> <C-C>`<v`>s<Space><Esc>mq:e ispell.tmp<CR>i<C-R>"<Esc>:w<CR>:! xterm -bg ivory -fn 10x20 -e ispell %<CR><CR>:e %<CR><CR>ggVG<Esc>`<v`>s<Esc>:bwipeout!<CR>:!rm ispell.tmp*<CR>`q"_s<C-R>"<Esc>

" In normal mode, F1 inserts a latex template.
" F2 inserts a minimal latex template
" F3 inserts a letter template
" F4 inserts an exam template
map <buffer> <F1> :if strpart(getline(1),0,9) != "\\document"<CR>0read ~/.Vim/latex<CR>normal 23j$<CR>endif<Esc><Space>i
map <buffer> <F2> :if strpart(getline(1),0,9) != "\\document"<CR>0read ~/.Vim/min-latex<CR>normal 4j$<CR>endif<Esc><Space>i
map <buffer> <F3> :inoremap <buffer> . .  <CR>:inoremap <buffer> ? ?  <CR>:if strpart(getline(1),0,9) != "\\document"<CR>0read ~/.Vim/letter<CR>normal 9jt}<CR>endif<Esc><Space>i
map <buffer> <F4> :if strpart(getline(1),0,9) != "\\document"<CR>!cp ~/Storage/Latex/urmathexam.sty urmathexam.sty<CR>0read ~/Storage/Latex/exam.tex<CR>endif<Esc><Space>

"       dictionary
" set dictionary+=(put filename and path here)

" Boldface:  (2 alternative macros)
" In the first, \mathbf{} appears.
" In the second, you type the letter, and it capitalizes the letter
" and surrounds it with \mathbf
" inoremap <buffer> <M-b> \mathbf{}<Left>
"inoremap <buffer> <M-b> <Left>\mathbf{<Right>}<Esc>h~a
inoremap <buffer> <M-b> <Left>\mathbf{<Right>}<Esc>hvUla

" Cal:  (3 alternative macros:  see Boldface)
" The third one also inserts \cite{}, if the previous character is a blank
" inoremap <buffer> <M-c> \mathcal{}<Left>
" inoremap <buffer> <M-c> <Left>\mathcal{<Right>}<Esc>h~a
inoremap <buffer> <M-c> <C-R>=<SID>MathCal()<CR>
function! s:MathCal()
    if getline(line("."))[col(".")-2] =~ "[a-zA-Z0-9]"
	"return "\<Left>\\mathcal{\<Right>}\<Esc>h~a"
	return "\<Left>\\mathcal{\<Right>}\<Esc>hvUla"
    else
	return "\\cite{}\<Left>"
    endif
endfunction

"inoremap <buffer> <M-b> <C-R>=<SID>WithBrackets("mathbf")<CR>
"function! s:WithBrackets(string)
"    let s:user = input(a:string . ": ")
"    return "\\" . a:string . "{" . s:user . "}"
"endfunction

" This is for _{}^{}.  It moves you to the second parenthesis.
inoremap <buffer> <M-f> <Esc>f{a

" Alt-h inserts \widehat{}
inoremap <buffer> <M-h> \widehat{}<Left>

" Alt-i inserts \item
inoremap <buffer> <M-i> \item

" Alt-m inserts \mbox{}
inoremap <buffer> <M-m> \mbox{}<Left>

" Alt-o inserts \overline{}
inoremap <buffer> <M-o> \overline{}<Left>

" Alt-r inserts (\ref{})
" There are 2 versions.
" The second one inserts \ref{} if the preceding word is Lemma or the like.
"inoremap <buffer> <M-r> (\ref{})<Left><Left>
inoremap <buffer> <M-r> <C-R>=<SID>TexRef()<CR><Esc>F{a
function! s:TexRef()
    let s:insert = '(\ref{})'
    let s:lemma = strpart(getline(line(".")),col(".")-7,6)
    if s:lemma == "Lemma " || s:lemma == "emmas " || s:lemma == "eorem " || s:lemma == "llary "
	let s:insert = '\ref{}'
    endif
    return s:insert
endfunction

" Alt-s inserts \sqrt{}
inoremap <buffer> <M-s> \sqrt{}<Left>

" Textbf
inoremap <buffer> <M-t> \textbf{}<Left>
vnoremap <buffer> <M-t> <C-C>`>a}<Esc>`<i\textbf{<Esc>

" This is for _{}^{}.  It gets rid of the ^{} part
inoremap <buffer> <M-x> <Esc>f^cf}

" Alt-u inserts \underline
inoremap <buffer> <M-u> \underline{}<Left>

" Alt-- (Alt-minus) inserts _{}^{}
inoremap <buffer> <M--> _{}^{}<Esc>3hi

" Alt-<Right> inserts \lim_{}
inoremap <buffer> <M-Right> \lim_{}<Left>

" Smart quotes.  Thanks to Ron Aaron <ron@mossbayeng.com>.
function! s:TexQuotes()
    let s:insert = "''"
    let s:left = getline(line("."))[col(".")-2]
    if s:left == ' ' || s:left == '' || s:left == '	'   " Tab
	let s:insert = '``'
    elseif s:left == '\'
	let s:insert = '"'
    endif
    return s:insert
endfunction
imap <buffer> " <C-R>=<SID>TexQuotes()<CR>

" Typing ... results in \dots
"function! s:Dots()
"    let s:left = strpart(getline(line(".")),col(".")-3,2)
"    if s:left == ".."
"	return "\<BS>\<BS>\\dots"
"    else
"       return "."
"    endif
"endfunction
" Use this if you want . to result in a period followed by 2 spaces.
function! s:Dots()
    let s:column = col(".")
    let s:currentline = getline(line("."))
    let s:previous = s:currentline[s:column-2]
    if strpart(s:currentline,s:column-4,3) == ".  "
	return "\<BS>\<BS>"
    elseif s:previous == '.'
	return "\<BS>\\dots"
    elseif s:previous =~ '[\$A-Za-z]' && s:currentline !~ "@"
	return ".  "
    else
	return "."
    endif
endfunction
imap <buffer> . <C-R>=<SID>Dots()<CR>
inoremap <buffer> <M-.> .

" Typing __ results in _{}
function! s:SubBracket()
    let s:insert = "_"
    let s:left = getline(line("."))[col(".")-2]
    if s:left == '_'
	let s:insert = "{}\<Left>"
    endif
    return s:insert
endfunction
inoremap <buffer> _ <C-R>=<SID>SubBracket()<CR>

" Typing ^^ results in ^{}
function! s:SuperBracket()
    let s:insert = "^"
    let s:left = getline(line("."))[col(".")-2]
    if s:left == '^'
	let s:insert = "{}\<Left>"
    endif
    return s:insert
endfunction
inoremap <buffer> ^ <C-R>=<SID>SuperBracket()<CR>

" Since " is not available, <Alt-'> gives it.
inoremap <buffer> <M-'> "

" Begin-End
" F1 - F5 inserts various environments (insert mode).
" Ctrl-F1 through Ctrl-F5 replaces the current environment
"     with \begin-\end{equation} through \begin-\end{}.
inoremap <buffer> <F1> \begin{equation}<CR>\label{}<CR><CR>\end{equation}<Esc>2k$i
noremap <buffer> <C-F1> /\\end\\|\\]<CR>S\end{equation}<Esc>v?\\begin\\|\\[<CR><Esc>S\begin{equation}<Esc>:'<,'>s/&\\|\\lefteqn{\\|\\nonumber\\|\\\\//e<CR>`<:call <SID>PutInLabel()<CR>a
inoremap <buffer> <C-F1> <Esc>/\\end\\|\\]<CR>S\end{equation}<Esc>v?\\begin\\|\\[<CR><Esc>S\begin{equation}<Esc>:'<,'>s/&\\|\\lefteqn{\\|\\nonumber\\|\\\\//e<CR>`<:call <SID>PutInLabel()<CR>a
inoremap <buffer> <F2> \[<CR><CR>\]<Up>
noremap <buffer> <C-F2> /\\end<CR>S\]<Esc>v?\\begin<CR><Esc>S\[<Esc>:'<,'>s/&\\|\\lefteqn{\\|\\nonumber\\|\\\\//e<CR>:'<+1g/\\label/delete<CR>
inoremap <buffer> <C-F2> <Esc>/\\end<CR>S\]<Esc>v?\\begin<CR><Esc>S\[<Esc>:'<,'>s/&\\|\\lefteqn{\\|\\nonumber\\|\\\\//e<CR>:'<+1g/\\label/delete<CR>
inoremap <buffer> <F3> \begin{eqnarray}<CR>\label{}<CR><CR>\end{eqnarray}<Esc>2k$i
noremap <buffer> <C-F3> /\\end\\|\\]<CR>S\end{eqnarray}<Esc>v?\\begin\\|\\[<CR><Esc>S\begin{eqnarray}<Esc>:call <SID>PutInNonumber ()<CR>`<:call <SID>PutInLabel ()<CR>a
inoremap <buffer> <C-F3> <Esc>/\\end\\|\\]<CR>S\end{eqnarray}<Esc>v?\\begin\\|\\[<CR><Esc>S\begin{eqnarray}<Esc>:call <SID>PutInNonumber ()<CR>`<:call <SID>PutInLabel ()<CR>a
inoremap <buffer> <F4> \begin{eqnarray*}<CR><CR>\end{eqnarray*}<Up>
noremap <buffer> <C-F4> /\\end\\|\\]<CR>S\end{eqnarray*}<Esc>v?\\begin\\|\\[<CR><Esc>S\begin{eqnarray*}<Esc>:'<,'>s/\\nonumber//e<CR>:'<+1g/\\label/delete<CR>
inoremap <buffer> <C-F4> <Esc>/\\end\\|\\]<CR>S\end{eqnarray*}<Esc>v?\\begin\\|\\[<CR><Esc>S\begin{eqnarray*}<Esc>:'<,'>s/\\nonumber//e<CR>:'<+1g/\\label/delete<CR>
inoremap <buffer> <F6> \left\{\begin{array}{ll}<CR>&\mbox{$$} \\<CR>&\mbox{}<CR>\end{array}<CR>\right.<Up><Up><Up><Home>
inoremap <buffer> <F7> \noindent<CR>\textbf{Proof.}<CR><CR><CR>\qed<Up><Up>

" The next idea came from a contributed NEdit macro.
" typing the name of the environment followed by <F5> results in 
" \begin{environment} \end{environment}
" But, typing <F5> at the beginning of the line results in a prompt
" for the name of the environment.
inoremap <buffer> <F5> <Esc>v0x:call <SID>DoEnvironment(@")<CR>

" Due to Ralf Arens <ralf.arens@gmx.net>
"inoremap <buffer> <F5> <C-O>:call <SID>PutEnvironment(input("Environment? "))<CR>
inoremap <buffer> <C-F5> <C-O>:call <SID>ChangeEnvironment(input("Environment? "))<CR>
noremap <buffer> <C-F5> :call <SID>ChangeEnvironment(input("Environment? "))<CR>

function! s:DoEnvironment(env)
    if a:env == "\n"
	put! =''
	call <SID>PutEnvironment(input("Environment? "))
    else
	call <SID>SetEnvironment(a:env)
    endif
    startinsert
endfunction

function! s:SetEnvironment(env)
    put! ='\begin{' . a:env . '}'
    normal j
    put ='\end{' . a:env . '}'
    normal k
    if a:env == "array"
	normal k
	exe "normal A\<C-V>{}\<Esc>"
    endif
    if a:env == "theorem" || a:env == "lemma" || a:env == "equation" || a:env == "eqnarray" || a:env == "align" || a:env == "multline"
	put! ='\label{}'
	normal f}
    endif
    startinsert
endfunction

function! s:PutEnvironment(env)
    put! ='\begin{' . a:env . '}'
    normal j
    put ='\end{' . a:env . '}'
    normal k
    if a:env == "array"
	call <SID>ArgumentsForArray(input("{rlc}? "))
    endif
    if a:env == "theorem" || a:env == "lemma" || a:env == "equation" || a:env == "eqnarray" || a:env == "align" || a:env == "multline"
	call <SID>AskLabel(input("Label? "))
    endif
endfunction

function! s:ArgumentsForArray(arg)
    put! = '{' . a:arg . '}'
    normal kgJj
endfunction

function! s:ChangeEnvironment(env)
    exe "normal /\\\\end\\|\\\\]\<CR>dd"
    put! = '\end{' . a:env . '}'
    exe "normal ?\\\\begin\\|\\\\[\<CR>dd"
    put! = '\begin{' . a:env . '}'
    normal j
    if a:env == "theorem" || a:env == "lemma" || a:env == "equation" || a:env == "eqnarray" || a:env == "align" || a:env == "multline"
	if (-1 == match(getline(line(".")),"\\label"))
	    call <SID>AskLabel(input("Label? "))
	endif
    elseif a:env[strlen(a:env)-1] == '*'
	if (-1 != match(getline(line(".")),"\\label"))
	    normal dd
	endif
    endif
endfunction

function! s:AskLabel(label)
    if a:label != ''
        put! ='\label{' . a:label . '}'
        normal j
    endif
endfunction

function! s:PutInLabel()
   if (-1 == match(getline(line(".")+1),"\\label"))
       exe "normal o\\label{\<Esc>"
   endif
endfunction

function! s:PutInNonumber()
   exe "normal /\\\\end\\|\\\\\\\\\<CR>"
   if getline(line("."))[col(".")] != "e"
       .+1,'>s/\\\\/\\nonumber\\\\/e
       normal `>k
       s/\s*$/  \\nonumber/
   endif
endfunction

" Left-right (3 alternatives)
" In the first version, you type Alt-L and then the bracket
" In the second version, you type the bracket, and then Alt-L
" The second version matches with the Alt-B and Alt-C macros,
" if you use the uncommented versions.  It also doubles as a command
" for inserting \label{}
" The third version is like the second version.  Use it if you have
" disabled automatic bracket completion.
"inoremap <buffer> <M-l>( \left(\right)<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>\| \left\|\right\|<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>[ \left[\right]<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>{ \left\{\right\}<Left><Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>< \langle\rangle<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>q \lefteqn{
function! s:LeftRight()
    let s:line = getline(line("."))
    let s:char = s:line[col(".")-1]
    let s:previous = s:line[col(".")-2]
    if s:char == '(' || s:char == '['
        exe "normal i\\left\<Esc>la\\right\<Esc>6h"
    elseif s:char == '|'
	if s:previous == '\'
	    exe "normal ileft\\\<Esc>"
	else
	    exe "normal i\\left\<Esc>"
	endif
	exe "normal la\\right\<Esc>6h"
    elseif s:char == '{'
	if s:previous == '\'
	    exe "normal ileft\\\<Esc>la\\right\<Esc>6h"
	else
	    exe "normal i\\left\\\<Esc>la\\right\\\<Esc>7h"
	endif
    elseif s:char == '<'
	exe "normal s\\langle\\rangle\<Esc>7h"
    elseif s:char == 'q'
	exe "normal s\\lefteqn\<C-V>{\<Esc>"
    else
	exe "normal a\\label\<C-V>{}\<Esc>h"
    endif
endfunction
inoremap <buffer> <M-l> <Esc>:call <SID>LeftRight()<CR>a
noremap <buffer> <M-l> :call <SID>PutLeftRight()<CR>
vnoremap <buffer> <M-l> <C-C>`>a\right<Esc>`<i\left<Esc>
"function! s:LeftRight()
"let s:char = getline(line("."))[col(".")-1]
"let s:previous = getline(line("."))[col(".")-2]
"if s:char == '('
"	exe "normal i\\left\<Esc>la\\right)\<Esc>7h"
"elseif s:char == '['
"	exe "normal i\\left\<Esc>la\\right]\<Esc>7h"
"elseif char == '|'
"	if s:previous == '\'
"		exe "normal ileft\\\<Esc>la\\right\\\|\<Esc>8h"
"	else
"		exe "normal i\\left\<Esc>la\\right\|\<Esc>7h"
"	endif
"elseif s:char == '{'
"	if s:previous == '\'
"		exe "normal ileft\\\<Esc>la\\right\\}\<Esc>8h"
"	else
"		exe "normal i\\left\\\<Esc>la\\right\\}\<Esc>8h"
"	endif
"elseif s:char == '<'
"	exe "normal s\\langle\\rangle\<Esc>7h"
"elseif s:char == 'q'
"	exe "normal s\\lefteqn{\<Esc>lx"
"endif
"endfunction

" Bracket Completion Macros
" Typing the symbol a second time (for example, $$) will result in one
" of the symbole (for instance, $).  With {, typing \{ will result in \{\}.
inoremap <buffer> ( <C-R>=<SID>Double("(",")")<CR>
"inoremap <buffer> [ <C-R>=<SID>Double("[","]")<CR>
inoremap <buffer> [ <C-R>=<SID>CompleteSlash("[","]")<CR>
inoremap <buffer> $ <C-R>=<SID>Double("$","$")<CR>
inoremap <buffer> & <C-R>=<SID>DoubleAmpersands()<CR>
inoremap <buffer> { <C-R>=<SID>CompleteSlash("{","}")<CR>
inoremap <buffer> \| <C-R>=<SID>CompleteSlash("\|","\|")<CR>

" For () and $$
function! s:Double(left,right)
    if strpart(getline(line(".")),col(".")-2,2) == a:left . a:right
	return "\<C-O>s"
    else
	return a:left . a:right . "\<Left>"
    endif
endfunction

" Complete [, \[, {, \{, |, \|
function! s:CompleteSlash(left,right)
    let s:column = col(".")
    let s:first = getline(line("."))[s:column-2]
    let s:second = getline(line("."))[s:column-1]
    if s:first == "\\"
	if a:left == "["
	    return "\[\<CR>\<CR>\\]\<Esc>ki"
	else
	    return a:left . "\\" . a:right . "\<Left>\<Left>"
	endif
    else
        return a:left . a:right . "\<Left>"
    endif
endfunction

" Double ampersands, unless you are in an array environment
function! s:DoubleAmpersands()
    let s:stop = 0
    let s:currentline = line(".")
    while s:stop == 0
	let s:currentline = s:currentline - 1
	let s:thisline = getline(s:currentline)
	if s:thisline =~ '\\begin' || s:currentline == 0
	    let s:stop = 1
	endif
    endwhile
    if s:thisline =~ '\\begin{array}'
	return "&"
    elseif strpart(getline(line(".")),col(".")-2,2) == "&&"
	return "\<C-O>s"
    else
	return "&&\<Left>"
    endif
endfunction

" Embrace the visual region with the symbol.
" This assumes that you are using
" set selection=exclusive
" If you are not, replace these macros with ones like this.
"vnoremap <buffer> ( <C-C>`>a)<C-C>`<i(<Esc>
vnoremap <buffer> <M-l> <C-C>`>a\right<Esc>`<i\left<Esc>
vnoremap <buffer> `( <C-C>`>a)<Esc>`<i(<Esc>
vnoremap <buffer> `[ <C-C>`>a]<Esc>`<i[<Esc>
vnoremap <buffer> `{ <C-C>`>a}<Esc>`<i{<Esc>
vnoremap <buffer> & <C-C>`>a&<Esc>`<i&<Esc>
vnoremap <buffer> `$ <C-C>`>a$<Esc>`<i$<Esc>
vnoremap <buffer> <M-4> <C-C>`>a$<Esc>`<i$<Esc>

" No timeout.  Applies to mappings such as `a for \alpha
set notimeout

" Greek letter, AucTex style bindings
inoremap <buffer> `` ``
inoremap <buffer> `a \alpha
inoremap <buffer> `b \beta
inoremap <buffer> `c \chi
inoremap <buffer> `d \delta
inoremap <buffer> `e \varepsilon
inoremap <buffer> `f \varphi
inoremap <buffer> `g \gamma
inoremap <buffer> `h \eta
inoremap <buffer> `i \int_{}^{}<Esc>3hi
	    " Or \iota or \infty or \in
inoremap <buffer> `k \kappa
inoremap <buffer> `l \lambda
inoremap <buffer> `m \mu
inoremap <buffer> `n \nu
inoremap <buffer> `o \omega
inoremap <buffer> `p \pi
inoremap <buffer> `q \theta
inoremap <buffer> `r \rho
inoremap <buffer> `s \sigma
inoremap <buffer> `t \tau
inoremap <buffer> `u \upsilon
inoremap <buffer> `v \vee
inoremap <buffer> `w \wedge
inoremap <buffer> `x \xi
inoremap <buffer> `y \psi
inoremap <buffer> `z \zeta
inoremap <buffer> `D \Delta
inoremap <buffer> `I \int_{}^{}<Esc>3hi
inoremap <buffer> `F \Phi
inoremap <buffer> `G \Gamma
inoremap <buffer> `L \Lambda
inoremap <buffer> `N \nabla
inoremap <buffer> `O \Omega
inoremap <buffer> `Q \Theta
inoremap <buffer> `R \varrho
inoremap <buffer> `S \sum_{}^{}<Esc>3hi
inoremap <buffer> `U \Upsilon
inoremap <buffer> `X \Xi
inoremap <buffer> `Y \Psi
inoremap <buffer> `0 \emptyset
inoremap <buffer> `1 \left
inoremap <buffer> `2 \right
inoremap <buffer> `3 \Big
inoremap <buffer> `6 \partial
inoremap <buffer> `8 \infty
inoremap <buffer> `/ \frac{}{}<Esc>2hi
inoremap <buffer> `% \frac{}{}<Esc>2hi
inoremap <buffer> `@ \circ
inoremap <buffer> `\| \Big\|
inoremap <buffer> `= \equiv
inoremap <buffer> `\ \setminus
inoremap <buffer> `. \cdot
inoremap <buffer> `* \times
inoremap <buffer> `& \wedge
inoremap <buffer> `- \bigcap
inoremap <buffer> `+ \bigcup
inoremap <buffer> `( \subset
inoremap <buffer> `) \supset
inoremap <buffer> `< \le
inoremap <buffer> `> \ge
inoremap <buffer> `, \nonumber
inoremap <buffer> `: \dots
inoremap <buffer> `~ \tilde{}<Left>
inoremap <buffer> `^ \hat{}<Left>
inoremap <buffer> `; \dot{}<Left>
inoremap <buffer> `_ \bar{}<Left>
inoremap <buffer> `<M-c> \cos
inoremap <buffer> `<C-E> \exp\left(\right)<Esc>6hi
inoremap <buffer> `<C-I> \in
inoremap <buffer> `<C-J> \downarrow
inoremap <buffer> `<C-L> \log
inoremap <buffer> `<C-P> \uparrow
inoremap <buffer> `<Up> \uparrow
inoremap <buffer> `<C-N> \downarrow
inoremap <buffer> `<Down> \downarrow
inoremap <buffer> `<C-F> \to
inoremap <buffer> `<Right> \lim_{}<Left>
inoremap <buffer> `<C-S> \sin
inoremap <buffer> `<C-T> \tan
inoremap <buffer> `<M-l> \ell
inoremap <buffer> `<CR> \nonumber\\<CR>

"  With this map, <Space> will split up a long line, keeping the dollar
"  signs together (see the next function, TexFormatLine).
set tw=0
inoremap <buffer> <Space> <Space><Esc>:call <SID>TexFill()<CR>a
function! s:TexFill()
    if col(".") > 76
	exe "normal a##\<Esc>"
	call <SID>TexFormatLine()
	exe "normal ?##\<CR>2s\<Esc>"
    endif
endfunction

"  This function splits up a long line, keeping the dollar signs together.
function! s:TexFormatLine()
    normal $
    let s:length = col(".")
    let s:go = 1
    while s:length > 78 && s:go
    let s:between = 0
    let s:string = strpart(getline(line(".")),0,76)
    " Count the dollar signs
    let s:evendollars = 1
    let s:counter = 0
    while s:counter <= 75
	if s:string[s:counter] == '$' && s:string[s:counter-1] != '\'  " Skip \$.
	   let s:evendollars = 1 - s:evendollars
	endif
	let s:counter = s:counter + 1
    endwhile
    " Get ready to split the line.
    normal 076l
    if s:evendollars
    " Then you are not between dollars.
       exe "normal ?\\$\\| \<CR>W"
    else
    " Then you are between dollars.
	normal F$
	if col(".") == 1
	   let s:go = 0
	endif
    endif
    exe "normal i\<CR>\<Esc>$"
    let s:length = col(".")
    endwhile
endfunction

noremap <buffer> Q :call <SID>TexFormatLine()<CR>
vnoremap <buffer> Q J:call <SID>TexFormatLine()<CR>
noremap <buffer> <C-CR> :call <SID>TexFormatLine()<CR>
inoremap <buffer> <C-CR> <Esc>:call <SID>TexFormatLine()<CR>
vnoremap <buffer> <C-CR> J:call <SID>TexFormatLine()<CR>

" Matching Brackets Macros (due to Saul Lubkin).  For normal mode.

" Bindings for the Bracket Macros
noremap <buffer> <Tab>x :call <SID>DeleteBrackets()<CR>
noremap <buffer> <Tab>l :call <SID>PutLeftRight()<CR>
noremap <buffer> <Tab><Del> :call <SID>DeleteBrackets()<CR>
noremap <buffer> <Tab>( :call <SID>ChangeRound()<CR>
noremap <buffer> <Tab>[ :call <SID>ChangeSquare()<CR>
noremap <buffer> <Tab>{ :call <SID>ChangeCurly()<CR>
noremap <buffer> <Tab>c :call <SID>ChangeLeftRightBigg()<CR>
noremap <buffer> <Tab>b :call <SID>PutBigg()<CR>

noremap <buffer> <C-Del> :call <SID>DeleteBrackets()<CR>
inoremap <buffer> <C-BS> <Left><C-O>:call <SID>DeleteBrackets()<CR>

" Then the procedures.
function! s:DeleteBrackets()
    let s:b = getline(line("."))[col(".") - 2]
    let s:c = getline(line("."))[col(".") - 1]
    if s:b == '\' && (s:c == '{' || s:c == '}')
	normal X%X%
    endif
    if s:c == '{' || s:c == '[' || s:c == '('
	normal %x``x
    elseif s:c == '}' || s:c == ']' || s:c == ')'
	normal %%x``x``
    endif
endfunction

function! s:PutLeftRight()
    let s:previous = getline(line("."))[col(".") - 2]
    let s:char = getline(line("."))[col(".") - 1]
    if s:previous == '\'
    if s:char == '{'
	exe "normal ileft\\\<Esc>l%iright\\\<Esc>l%"
    elseif s:char == '}'
	exe "normal iright\\\<Esc>l%ileft\\\<Esc>l%"
    endif
    elseif s:char == '[' || s:char == '('
	exe "normal i\\left\<Esc>l%i\\right\<Esc>l%"
    elseif s:char == ']' || s:char == ')'
	exe "normal i\\right\<Esc>l%i\\left\<Esc>l%"
    endif
endfunction

function! s:PutBigg()
    let s:b = getline(line("."))[col(".") - 2]
    let s:c = getline(line("."))[col(".") - 1]
    if s:b == '\'
	exe "normal ibigg\\\<Esc>l%ibigg\\\<Esc>l%"
    elseif s:c == '{' || c == '[' || c == '(' || c == '}' || c == ']' || c == ')'
	exe "normal i\\bigg\<Esc>l%i\\bigg\<Esc>l%"
    endif
endfunction

function! s:ChangeLeftRightBigg()
    let s:b = getline(line("."))[col(".") - 2]
    let s:c = getline(line("."))[col(".") - 1]
    if s:b == '\'
    if s:c == '{'
	exe "normal 5hcwbigg\<Esc>2l%6hcwbigg\<Esc>2l%"
    elseif s:c == '}'
	exe "normal 6hcwbigg\<Esc>2l%5hcwbigg\<Esc>2l%"
    endif
    elseif s:c == '{' || c == '[' || c == '('
	exe "normal 4hcwbigg\<Esc>l%5hcwbigg\<Esc>l%"
    elseif s:c == '}' || s:c == ']' || s:c == ')'
	exe "normal 5hcwbigg\<Esc>l%4hcwbigg\<Esc>l%"
    endif
endfunction

function! s:ChangeCurly()
    let s:c = getline(line("."))[col(".") - 1]
    if s:c == '[' || s:c == '('
	exe "normal i\\\<Esc>l%i\\\<Esc>lr}``r{"
    elseif s:c == ']' || s:c == ')'
	exe "normal %i\\\<Esc>l%i\\\<Esc>lr}``r{%"
    endif
endfunction

function! s:ChangeRound()
    let s:b = getline(line("."))[col(".") - 2]
    let s:c = getline(line("."))[col(".") - 1]
    if s:b == '\'
    if s:c == '{'
	normal X%Xr)``r(
    elseif s:c == '}'
	normal %X%Xr)``r(%
    endif
    elseif s:c == '['
	normal %r)``r(
    elseif s:c == ']'
	normal %%r)``r(%
    endif
endfunction

function! s:ChangeSquare()
    let s:b = getline(line("."))[col(".") - 2]
    let s:c = getline(line("."))[col(".") - 1]
    if s:b == '\'
	if s:c == '{'
	    normal X%Xr]``r[
	elseif s:c == '}'
	    normal %X%Xr]``r[%
	endif
    elseif s:c == '('
	normal %r]``r[
    elseif s:c == ')'
	normal %%r]``r[%
    endif
endfunction

" Saul's menu items
nnoremenu 40.401 Brackets.delete\ brackets\ \ \ Ctrl+Del,Ctrl+BS,Tab-x :call <SID>DeleteBrackets()<CR>
inoremenu 40.402 Brackets.delete\ brackets\ \ \ Ctrl+Del,Ctrl+BS,Tab-x <Left><C-O>:call <SID>DeleteBrackets()<CR> nnoremenu 40.403 Brackets.change\ to\ () :call <SID>ChangeRound()<CR>
inoremenu 40.404 Brackets.change\ to\ () <Esc>:call <SID>ChangeRound()<CR>a
nnoremenu 40.405 Brackets.change\ to\ [] :call <SID>ChangeSquare()<CR>
inoremenu 40.406 Brackets.change\ to\ [] <Esc>:call <SID>ChangeSquare()<CR>a
nnoremenu 40.407 Brackets.change\ to\ \\{\\} :call <SID>ChangeCurly()<CR>
inoremenu 40.408 Brackets.change\ to\ \\{\\} <Esc>:call <SID>ChangeCurly()<CR>a
nnoremenu 40.409 Brackets.insert\ \\left,\\right :call <SID>PutLeftRight()<CR>
inoremenu 40.410 Brackets.insert\ \\left,\\right <Esc>:call <SID>PutLeftRight()<CR>a
nnoremenu 40.410 Brackets.insert\ \\bigg :call <SID>PutBigg()<CR>
inoremenu 40.411 Brackets.insert\ \\bigg <Esc>:call <SID>PutBigg()<CR>a
nnoremenu 40.412 Brackets.change\ \\left,\\right\ to\ \\bigg :call <SID>ChangeLeftRightBigg()<CR>
inoremenu 40.413 Brackets.change\ \\left,\\right\ to\ \\bigg <Esc>:call <SID>ChangeLeftRightBigg()<CR>a

" Menus for running Latex, etc.
nnoremenu 50.401 Latex.run\ latex\ \ \ \ Control-Tab :w<CR>:! xterm -bg ivory -fn 7x14 -e latex % &<CR><Space>
inoremenu 50.401 Latex.run\ latex\ \ \ \ Control-Tab <Esc>:w<CR>:! xterm -bg ivory -fn 7x14 -e latex % &<CR><Space>
nnoremenu 50.402 Latex.next\ error\ \ \ Shift-Tab :call <SID>NextTexError()<CR><Space>
inoremenu 50.402 Latex.next\ error\ \ \ Shift-Tab <Esc>:call <SID>NextTexError()<CR><Space>
nnoremenu 50.403 Latex.run\ kdvi\ \ \ \ \ Alt-Tab :call <SID>Kdvi()<CR><Space>
inoremenu 50.403 Latex.run\ kdvi\ \ \ \ \ Alt-Tab <Esc>:call <SID>Kdvi()<CR><Space>
nnoremenu 50.404 Latex.run\ ispell\ \ \ Shift-Ins :w<CR>:! xterm -bg ivory -fn 10x20 -e ispell %<CR><Space>:e %<CR><Space>
inoremenu 50.404 Latex.run\ ispell\ \ \ Shift-Ins <Esc>:w<CR>:! xterm -bg ivory -fn 10x20 -e ispell %<CR><Space>:e %<CR><Space>
nnoremenu 50.405 Latex.run\ engspchk :so .Vim/engspchk.vim<CR>
inoremenu 50.405 Latex.run\ engspchk <C-O>:so .Vim/engspchk.vim<CR>

" Math Abbreviations
iab <buffer> \b \bigskip
iab <buffer> \h \hspace{
iab <buffer> \i \noindent
iab <buffer> \l \newline
iab <buffer> \m \medskip
iab <buffer> \n \nonumber\\
iab <buffer> \p \newpage
iab <buffer> \q \qquad
iab <buffer> \v \vfill

" Personal or Temporary bindings.
inoremap <buffer> ;; ;
inoremap <buffer> ;<CR> <CR>\bigskip<CR>\noindent<CR>\textbf{}<Left>
inoremap <buffer> ;e E\left[\right]<Esc>F\i
inoremap <buffer> ;i \int_{\mathbf{R}^d}
inoremap <buffer> ;I \int_{0}^{\infty}
inoremap <buffer> ;p P\left(\right)<Esc>F\i
inoremap <buffer> ;1 \newline<CR><CR>\noindent<CR>\textbf{}<Left>
