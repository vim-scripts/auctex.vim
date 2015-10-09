" Vim filetype plugin
" Language:	LaTeX
" Maintainer: Carl Mueller, math at carlm e4ward c o m
" Last Change:	October 9, 2015
" Version:  2.2.17
" Website: http://www.math.rochester.edu/people/faculty/cmlr/Latex/index.html

" "========================================================================="
" Explanation and Customization   {{{

let b:AMSLatex = 0
let b:DoubleDollars = 0
" prefix for the "Greek letter" macros (For personal macros, it is ';')
let mapleader = '`'

" Set b:AMSLatex to 1 if you are using AMSlatex.  Otherwise, the program will 
" attempt to automatically detect the line \usepackage{...amsmath...} 
" (uncommented), which would indicate AMSlatex.  This is mainly for the 
" function keys F1 - F5, which insert the most common environments, and 
" C-F1 - C-F5, which change them.  See "Inserting and Changing Environments"
" for information.
" Set b:DoubleDollars to 1 if you use $$...$$ instead of \[...\]
" With b:DoubleDollars = 1, C-F1 - C-F5 will not work in nested environments.

" Auctex-style macros for Latex typing.
" You will have to customize the functions RunLatex(), Xdvi(), 
" and the maps for inserting template files, on lines 168 - 169

" Thanks to Peppe Guldberg for important suggestions.
"
" Please read the comments in the file for an explanation of all the features.
" One of the main features is that the "mapleader" (set to "`" see above),
" triggers a number of macros (see "Embrace the visual region" and 
" "Greek letters".  For example, `a would result in \alpha.  
" There are many other features;  read the file.
"
" The following templates are inserted with <F1> - <F4>, in normal mode.
" The first 2 are for latex documents, which have "\title{}"
let b:template_1 = '~/.Vim/latex'
let b:template_2 = '~/.Vim/min-latex'
" The next template is for a letter, which has "\opening{}"
let b:template_3 = '~/.Vim/letter'
" The next template is for a miscellaneous document.
let b:template_4 = '~/Storage/Latex/exam.tex'

" Vim commands to run latex and the dvi viewer.
" Must be of the form "! ... % ..."
" The following command may make xdvi automatically update.
"let b:latex_command = "! xterm -bg ivory -fn 7x14 -e latex \\\\nonstopmode \\\\input\\{%\\}; cat %<.log"
"let b:latex_command = "! xterm -e latex \\\\nonstopmode \\\\input\\{%\\}"
let b:latex_command = "!latex \\\\nonstopmode \\\\input\\{%\\}"
let b:dvi_viewer_command = "! xdvi -expert -s 6 -margins 2cm -geometry 750x950 %< &"
"let b:dvi_viewer_command = "! kdvi %< &"

" Switch to the directory of the tex file.  Thanks to Fritz Mehner.
" This is useful for starting xdvi, or going to the next tex error.
" autocmd BufEnter *.tex :cd %:p:h

" The following is necessary for TexFormatLine() and TexFill()
set tw=0
" substitute text width
let b:tw = 79

" If you are using Windows, modify b:latex_command above, and set 
" b:windows below equal to 1
let b:windows = 0

" }}}
" "========================================================================="
" Mapping for Xdvi Search   {{{

noremap <buffer> <C-LeftMouse> :execute "!xdvi -name -xdvi -sourceposition ".line(".").expand("%")." ".expand("%:r").".dvi"<CR><CR>

" }}}
" "========================================================================="
" Tab key mapping   {{{
" In a math environment, the tab key moves between {...} braces, or to the end
" of the line or the end of the environment.  Otherwise, it does word
" completion.  But if the previous character is a blank, or if you are at the
" end of the line, you get a tab.  If the previous characters are \ref{
" then a list of \label{...} completions are displayed.  Choose one by
" clicking on it and pressing Enter.  q quits the display.  Ditto for 
" \cite{, except you get to choose from either the bibitem entries, if any,
" or the bibtex file entries.
" This was inspired by the emacs package Reftex.

inoremap <buffer><silent> <Tab> <C-R>=<SID>TexInsertTabWrapper('backward')<CR>

function! s:TexInsertTabWrapper(direction) 

    " Check to see if you're in a math environment.  Doesn't work for $$...$$.
    let line = getline('.')
    let len = strlen(line)
    let column = col('.') - 1
    let ending = strpart(line, column, len)
    let n = 0

    let dollar = 0
    while n < strlen(ending)
	if ending[n] == '$'
	    let dollar = 1 - dollar
	endif
	let n = n + 1
    endwhile

    let math = 0
    let ln = line('.')
    while ln > 1 && getline(ln) !~ '\\begin\|\\end\|\\\]\|\\\['
	let ln = ln - 1
    endwhile
    if getline(ln) =~ 'begin{\(eq\|arr\|align\|mult\)\|\\\['
	let math = 1
    endif

    " Check to see if you're between brackets in \ref{} or \cite{}.
    " Inspired by RefTex.
    " Typing q returns you to editing
    " Typing <CR> or Left-clicking takes the data into \ref{} or \cite{}.
    " Within \cite{}, you can enter a regular expression followed by <Tab>,
    " Only the citations with matching authors are shown.
    " \cite{c.*mo<Tab>} will show articles by Mueller and Moolinar, for example.
    " Once the citation is shown, you type <CR> anywhere within the citation.
    " The bibtex files listed in \bibliography{} are the ones shown.
    if strpart(line,column-5,5) == '\ref{'
	let name = bufname(1)
	let short = substitute(name, ".*/", "", "")
	let aux = strpart(short, 0, strlen(short)-3)."aux"
	if filereadable(aux)
	    let tmp = tempname()
	    execute "below split ".tmp
	    execute "0read ".aux
	    g!/^\\newlabel{/delete
	    g/^\\newlabel{tocindent/delete
	    g/./normal 3f{lyt}0Pf}D0f\cf{       
	    execute "write! ".tmp

	    noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>RefInsertion("aux")<CR>zza
	    noremap <buffer> <CR> :call <SID>RefInsertion("aux")<CR>zza
	    noremap <buffer> q :bwipeout!<CR>zzi
	    return "\<Esc>"
	else
	    let tmp = tempname()
	    vertical 15split
	    execute "write! ".tmp
	    execute "edit ".tmp
	    g!/\\label{/delete
	    %s/.*\\label{//e
	    %s/}.*//e
	    noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>RefInsertion("")<CR>zza
	    noremap <buffer> <CR> :call <SID>RefInsertion("")<CR>zza
	    noremap <buffer> q :bwipeout!<CR>zzi
	    return "\<Esc>"
	endif
    elseif strpart(line,column-6,6) == '\cite{'
	let tmp = tempname()
        execute "write! ".tmp
        execute "split ".tmp

	if 0 != search('\\begin{thebibliography}')
	    bwipeout!
	    execute "below split ".tmp
	    call search('\\begin{thebibliography}')
	    normal kdgg
	    noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>CiteInsertion('\\bibitem')<CR>zza
	    vnoremap <buffer> <RightRelease> <C-c><Left>:call <SID>CommaCiteInsertion('\\bibitem')<CR>
	    noremap <buffer> <CR> :call <SID>CiteInsertion('\\bibitem')<CR>zza
	    noremap <buffer> , :call <SID>CommaCiteInsertion('\\bibitem')<CR>
	    noremap <buffer> q :bwipeout!<CR>f}zzi
	    return "\<Esc>"
	else
	    let l = search('\\bibliography{')
	    bwipeout!
	    if l == 0
		return ''
	    else
		let s = getline(l)
		let beginning = matchend(s, '\\bibliography{')
		let ending = matchend(s, '}', beginning)
		let f = strpart(s, beginning, ending-beginning-1)
		let tmp = tempname()
		execute "below split ".tmp
		let file_exists = 0

		let name = bufname(1)
		let base = substitute(name, "[^/]*$", "", "")
		while f != ''
		    let comma = match(f, ',[^,]*$')
		    if comma == -1
			let file = base.f.'.bib'
			if filereadable(file)
			    let file_exists = 1
			    execute "0r ".file
			endif
			let f = ''
		    else
			let file = strpart(f, comma+1)
			let file = base.file.'.bib'
			if filereadable(file)
			    let file_exists = 1
			    execute "0r ".file
			endif
			let f = strpart(f, 0, comma)
		    endif
		endwhile

		noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>CiteInsertion("@")<CR>zza
		vnoremap <buffer> <RightRelease> <C-c><Left>:call <SID>CommaCiteInsertion("@")<CR>
		noremap <buffer> <CR> :call <SID>CiteInsertion("@")<CR>zza
		noremap <buffer> , :call <SID>CommaCiteInsertion("@")<CR>
		noremap <buffer> q :bwipeout!<CR>zzi
		return "\<Esc>"

	    endif
	endif
    elseif dollar == 1   " If you're in a $..$ environment
	if ending[0] =~ ')\|]\||'
	    return "\<Right>"
	elseif ending =~ '^\\}\|\\|'
	    return "\<Right>\<Right>"
	elseif ending =~ '^\\right\\'
	    return "\<Esc>8la"
	elseif ending =~ '^\\right'
	    return "\<Esc>7la"
	elseif ending =~ '^}\(\^\|_\|\){'
	    return "\<Esc>f{a"
	elseif ending[0] == '}'
	    return "\<Right>"
	else
	    return "\<Esc>f$a"
	end
	"return "\<Esc>f$a"
    elseif math == 1    " If you're in a regular math environment.
	if ending =~ '^\s*&'
	    return "\<Esc>f&a"
        elseif ending[0] =~ ')\|]\||'
	    return "\<Right>"
	elseif ending =~ '^\\}\|\\|'
	    return "\<Right>\<Right>"
	elseif ending =~ '^\\right\\'
	    return "\<Esc>8la"
	elseif ending =~ '^\\right'
	    return "\<Esc>7la"
	elseif ending =~ '^}\(\^\|_\|\){'
	    return "\<Esc>f{a"
	elseif ending[0] == '}'
	    if line =~ '\\label'
		return "\<Down>"
	    else
		return "\<Esc>f}a"
	    endif
	elseif column == len    "You are at the end of the line.
	    call search("\\\\end\\|\\\\]")
	    return "\<Esc>o"
	else
	    return "\<C-O>$"
	endif
    else   " If you're not in a math environment.
	" Thanks to Benoit Cerrina (modified)
	if ending[0] =~ ')\|}'  " Go past right parentheses.
	    return "\<Right>"
	elseif !column || line[column - 1] !~ '\k' 
	    return "\<Tab>" 
	elseif a:direction == 'backward'
	    return "\<C-P>" 
	else 
	    return "\<C-N>" 
	endif 

    endif
endfunction 

" Inspired by RefTex
function! s:RefInsertion(x)
    if a:x == "aux"
	normal 0Wy$
    else
	normal 0y$
    endif
    bwipeout!
    let thisline = getline('.')
    let thiscol  = col('.')
    normal Pl
    if thisline[thiscol] == ')'
        normal l
    endif
endfunction

" Inspired by RefTex
" Get one citation from the .bib file or from the bibitem entries.
function! s:CiteInsertion(x)
    +
    "if search('@','b') != 0
    if search(a:x, 'b') != 0
	if a:x == "@"
	    normal f{lyt,
	else
	    normal f{lyt}
	endif
        bwipeout!
	normal Pf}
    else
        bwipeout!
    endif
endfunction

" Inspired by RefTex
" Get one citation from the .bib file or from the bibitem entries
" and be ready to get more.
function! s:CommaCiteInsertion(x)
    +
    if search(a:x, 'b') != 0
	if a:x == "@"
	    normal f{lyt,
	else
	    normal f{lyt}
	endif
	normal Pa,f}
    else
        bwipeout!
    endif
endfunction

" }}}
" "========================================================================="
" Insert Templates   {{{

" In normal mode, F1 inserts a latex template.
" F2 inserts a minimal latex template
" F3 inserts a letter template
" F4 inserts an exam template
execute "map <buffer> <F1> :if strpart(getline(1),0,9) != \"\\\\document\"<CR>0read " . b:template_1 . "<CR>call search(\"title\")<CR>endif<Esc><Space>f}i"
execute "map <buffer> <F2> :if strpart(getline(1),0,9) != \"\\\\document\"<CR>0read " . b:template_2 . "<CR>call search(\"title\")<CR>endif<Esc><Space>f}i"
execute "map <buffer> <F3> :if strpart(getline(1),0,9) != \"\\\\document\"<CR>0read " . b:template_3 . "<CR>call search(\"opening\")<CR>endif<Esc><Space>f}i"
execute "map <buffer> <F4> :if strpart(getline(1),0,9) != \"\\\\document\"<CR>0read " . b:template_4

"       dictionary
" set dictionary+=(put filename and path here)

" }}}
" "========================================================================="
" Run Latex, View, Ispell   {{{

" Key Bindings  {{{

" Run Latex;  change these bindings if you like.
noremap <buffer><silent> K :call <SID>RunLatex()<CR><Esc>:!pkill -USR1 xdvi<CR><Esc>
noremap <buffer><silent> <C-K> :call <SID>NextTexError()<CR>

noremap <buffer><silent> \lr :call <SID>CheckReferences('Reference', 'ref')<CR><Space>
noremap <buffer><silent> \lc :call <SID>CheckReferences('Citation', 'cite')<CR><Space>
noremap <buffer><silent> \lg :call <SID>LookAtLogFile()<CR>gg/LaTeX Warning\\|^!<CR>

" Run the Latex viewer;  change these bindings if you like.
noremap <buffer><silent> <S-Esc> :call <SID>Xdvi()<CR><Space>
inoremap <buffer><silent> <S-Esc> <Esc>:call <SID>Xdvi()<CR><Space>

" Run Ispell on either the buffer, or the visually selected word.
noremap <buffer><silent> <S-Insert> :w<CR>:!xterm -bg ivory -fn 10x20 -e ispell %<CR><Space>:e %<CR>:redraw<CR>:echo "No (more) spelling errors."<CR>
inoremap <buffer><silent> <S-Insert> <Esc>:w<CR>:!xterm -bg ivory -fn 10x20 -e ispell %<CR><Space>:e %<CR>:redraw<CR>:echo "No (more) spelling errors."<CR>
vnoremap <buffer><silent> <S-Insert> <C-C>`<v`>s<Space><Esc>mq<C-W>s:e ispell.tmp<CR>i<C-R>"<Esc>:w<CR>:!xterm -bg ivory -fn 10x20 -e ispell %<CR><CR>:e %<CR><CR>ggVG<Esc>`<v`>s<Esc>:bwipeout!<CR>:!rm ispell.tmp*<CR>`q"_s<C-R>"<Esc>:redraw<CR>:echo "No (more) spelling errors."<CR>

" Run Ispell (Thanks the Charles Campbell)
" The first set is for vim, the second set for gvim.
"noremap <buffer> <S-Insert> :w<CR>:silent !ispell %<CR>:e %<CR><Space>
"inoremap <buffer> <S-Insert> <Esc>:w<CR>:silent !ispell %<CR>:e %<CR><Space>
"vnoremap <buffer> <S-Insert> <C-C>'<c'><Esc>:e ispell.tmp<CR>p:w<CR>:silent !ispell %<CR>:e %<CR><CR>ggddyG:bwipeout!<CR>:silent !rm ispell.tmp*<CR>pkdd
"vnoremap <buffer> <S-Insert> <C-C>`<v`>s<Space><Esc>mq:e ispell.tmp<CR>i<C-R>"<Esc>:w<CR>:silent !ispell %<CR>:e %<CR><CR>ggVG<Esc>`<v`>s<Esc>:bwipeout!<CR>:!rm ispell.tmp*<CR>`q"_s<C-R>"<Esc>

" }}}

" Functions  {{{

function! s:RunLatex()
    update
    execute 'silent ' . b:latex_command
    if b:windows != 1
	call <SID>NextTexError()
    endif
endfunction

" Stop warnings, since the log file is modified externally and then 
" read again.
au BufRead *.log    set bufhidden=unload

function! s:NextTexError()
    silent only
    let name = bufname(1)
    let short = substitute(name, ".*/", "", "")
    let log = strpart(short, 0, strlen(short)-3)."log"
    execute "above split ".log
    if search('^l\.\d') == 0
        if search('LaTeX Warning: .* multiply') == 0
	    bwipeout
	    normal zz
	else
	    syntax clear
	    syntax match err /^LaTeX Warning: .*/
	    highlight link err ToDo

	    if getline('.') =~ 'multiply'

		let multiply = matchstr(getline('.'), 'Label .* multiply')
		let multiply = strpart(multiply, 7, strlen(multiply)-17)
		let command = "normal! \<C-W>w1G/\\label{" . multiply . "}\<CR>6l\<C-W>Kzz\<C-W>wzz\<C-W>w"
	    else
		let command = "normal! \<C-W>Kzz\<C-W>wzz\<C-W>w"
	    endif

	    execute command
	endif
    else
	syntax clear
	syntax match err /! .*/
	syn match err /^ l\.\d.*\n.*$/
	highlight link err ToDo
        let thisline = getline('.')
	let linenumber = matchstr(thisline, '\d\+')
        let endofline = strpart(thisline, 3 + strlen(linenumber))

        if strpart(endofline, 0, 3) == '...'
            let newend = strpart(endofline, 3)
                "Put a space in the .log file so that you can see where you were,
                "and move on to the next latex error.
            s/^/ /
            write
            wincmd x
            let errorposition = stridx(getline(linenumber), newend) + strlen(endofline) - 4
        else
            let errorposition = col('$') - strlen(linenumber) - 5
                "Put a space in the .log file so that you can see where you were,
                "and move on to the next latex error.
            s/^/ /
            write
            wincmd x
        endif

        if errorposition < 1
            execute 'normal! ' . linenumber . "Gzz\<C-W>wzz\<C-W>w"
        else
            execute 'normal! ' . linenumber . 'G' . errorposition . "lzz\<C-W>wzz\<C-W>w"
        endif

    endif
endfunction

" Run xdvi
function! s:Xdvi()
    update
    execute 'silent ' . b:latex_command
    execute 'silent ' . b:latex_command
    execute b:dvi_viewer_command 
endfunction

function! s:CheckReferences(name, ref)
    "execute "noremap \<buffer> \<C-L> :call \<SID>CheckReferences(\"" . a:name . "\",\"" . a:ref . "\")\<CR>\<Space>"
    only
    edit +1 %<.log
    syntax clear
    syntax match err /LaTeX Warning/
    highlight link err ToDo
    if search('^LaTeX Warning: ' . a:name) == 0
	edit #
	redraw
	call input('No (More) ' . a:name . ' Errors Found.')
    else
	let linenumber = matchstr(getline('.'), '\d\+\.$')
	let linenumber = strpart(linenumber, 0, strlen(linenumber)-1)
	let reference = matchstr(getline('.'), "`.*\'")
	let reference = strpart(reference, 1, strlen(reference)-2)
	    "Put a space in the .log file so that you can see where you were,
	    "and move on to the next latex error.
	s/^/ /
	write
	split #
	execute "normal! " . linenumber . "Gzz\<C-W>wzz\<C-W>w"
	execute "normal! /\\\\" . a:ref . "{" . reference . "}\<CR>"
	execute "normal! /" . reference . "\<CR>"
    endif
endfunction

function! s:LookAtLogFile()
    only
    edit +1 %<.log
    syntax clear
    syntax match err /LaTeX Warning/
    syntax match err /! .*/
    syntax match err /^Overfull/
    syntax match err /^Underfull/
    highlight link err ToDo
    noremap <buffer> K :call <SID>GetLineFromLogFile()<CR>
    split #
    wincmd b
    /LaTeX Warning\|^\s*!\|^Overfull\|^Underfull
    let @/='LaTeX Warning\|^\s*!\|^Overfull\|^Underfull'
    echo "\nGo to the line in the log file which mentions the error\nthen type K to go to the line\nn to go to the next warning\n"
endfunction

function! s:GetLineFromLogFile()
    let line = matchstr(getline('.'), 'line \d\+')
    wincmd t
    execute strpart(line, 5, strlen(line)-5)
endfunction

" }}}

" }}}
" "========================================================================="
" Inserting and Changing Environments   {{{

" Bindings               {{{

" \begin{...}...\end{...}
" F1 - F5 inserts various environments (insert mode).
" Shift-F1 through Shift-F5 replaces the current environment
"     with \begin-\end{equation} through \begin-\end{}.

" The next function searches until \begin{document}
" \usepackage{...amsmath...}, and takes this to mean that the file is 
" an amslatex file.  But a commented line such as
" % \usepackage{...amsmath...} is ignored.  To adjust the number of 
" lines searched, change the variable b:LinesToSearch below.
" The function keys have the following mappings.  These include 
" \begin{...}...\end{...}, except for \[...\]
"
"  KEY         LATEX                    AMSLATEX
" 
"  F1          equation                 equation
"  F2          \[...\]                  equation*
"  F3          eqnarray                 align
"  F4          eqnarray*                align*
"  F5          asks for environment     asks for environment
"
" and S-F1 - S-F5, which are used to change environments, are similar.

inoremap <buffer><silent> <F1> \begin{equation}<CR>\label{}<CR><CR>\end{equation}<Esc>2k$i
inoremap <buffer><silent> <F2> <C-R>=<SID>FTwo(<SID>AmsLatex(b:AMSLatex))<CR>
inoremap <buffer><silent> <F3> <C-R>=<SID>FThree(<SID>AmsLatex(b:AMSLatex))<CR>
inoremap <buffer><silent> <F4> <C-R>=<SID>FFour(<SID>AmsLatex(b:AMSLatex))<CR>

noremap <buffer><silent> <C-S-F1> :silent call <SID>Change('equation', 1, '&\\|\\lefteqn{\\|\\nonumber\\|\\\\', 0)<CR>i
inoremap <buffer><silent> <C-S-F1> <Esc>:silent call <SID>Change('equation', 1, '&\\|\\lefteqn{\\|\\nonumber\\|\\\\', 0)<CR><Esc>i
noremap <buffer><silent> <C-S-F2> :silent call <SID>CFTwo(<SID>AmsLatex(b:AMSLatex))<CR>
inoremap <buffer><silent> <C-S-F2> <Esc>:silent call <SID>CFTwo(<SID>AmsLatex(b:AMSLatex))<CR>
noremap <buffer><silent> <C-S-F3> :silent call <SID>CFThree(<SID>AmsLatex(b:AMSLatex))<CR>i
inoremap <buffer><silent> <C-S-F3> <Esc>:silent call <SID>CFThree(<SID>AmsLatex(b:AMSLatex))<CR>i
noremap <buffer><silent> <C-S-F4> :silent call <SID>CFFour(<SID>AmsLatex(b:AMSLatex))<CR>
inoremap <buffer><silent> <C-S-F4> <Esc>:silent call <SID>CFFour(<SID>AmsLatex(b:AMSLatex))<CR>

inoremap <buffer><silent> <F6> \left\{\begin{array}{ll}<CR>&\mbox{$$} \\<CR>&\mbox{}<CR>\end{array}<CR>\right.<Up><Up><Up><Home>
"inoremap <buffer><silent> <F7> \textbf{Proof.}<CR><CR><CR>\qed<Up><Up>
inoremap <buffer><silent> <F7> <C-R>=<SID>Proof(<SID>AmsLatex(b:AMSLatex))<CR>

" The next idea came from a contributed NEdit macro.
" typing the name of the environment followed by <F5> results in 
" \begin{environment} \end{environment}
" But, typing <F5> at the beginning of the line results in a prompt
" for the name of the environment.
inoremap <buffer><silent> <F5> <C-O>:call <SID>DoEnvironment()<CR>

" Due to Ralf Arens <ralf.arens@gmx.net>
"inoremap <buffer> <F5> <C-O>:call <SID>PutEnvironment(input('Environment? '))<CR>
inoremap <buffer><silent> <C-S-F5> <C-O>:call <SID>ChangeEnvironment(input('Environment? '))<CR>
noremap <buffer><silent> <C-S-F5> :call <SID>ChangeEnvironment(input('Environment? '))<CR>

" }}}

" Functions         {{{

let b:searchmax = 100
function! s:AmsLatex(var)
    let amslatex = a:var
    if amslatex == 0
	let n = 1
	let line = getline(n)
	while line !~ '\\begin{document}' && amslatex == 0 && n < b:searchmax
	    if line =~ '^[^%]*\\usepackage{.*amsmath.*}'
		let amslatex = 1
	    endif
	    let n = n + 1
	    let line = getline(n)
	endwhile
    endif
    return amslatex
endfunction

function! s:FTwo(var)
    if a:var == 0
	if b:DoubleDollars == 0
	    return "\\[\<CR>\<CR>\\]\<Up>"
	else
	    return "$$\<CR>\<CR>$$\<Up>"
	endif
    else
	return "\\begin{equation*}\<CR>\<CR>\\end{equation*}\<Up>"
    endif
endfunction
function! s:FThree(var)
    if a:var == 0
	return "\\begin{eqnarray}\<CR>\\label{}\<CR>\<CR>\\end{eqnarray}\<Esc>2k$i"
    else
	return "\\begin{align}\<CR>\\label{}\<CR>\<CR>\\end{align}\<Esc>2k$i"
    endif
endfunction
function! s:FFour(var)
    if a:var == 0
	return "\\begin{eqnarray*}\<CR>\<CR>\\end{eqnarray*}\<Up>"
    else
	return "\\begin{align*}\<CR>\<CR>\\end{align*}\<Up>"
    endif
endfunction
function! s:Proof(var)
    if a:var == 0
        return "\\textbf{Proof.}\<CR>\<CR>\<CR>\\qed\<Up>\<Up>"
    else
	return "\\begin{proof}\<CR>\<CR>\\end{proof}\<Up>"
    endif
endfunction
function! s:CFTwo(var)
    if a:var == 0
	call <SID>Change('[', 0, '&\|\\lefteqn{\|\\nonumber\|\\\\', 0)
    else
	call <SID>Change('equation*', 0, '&\|\\lefteqn{\|\\nonumber\|\\\\', 0)
    endif
endfunction
function! s:CFThree(var)
    if a:var == 0
	call <SID>Change('eqnarray', 1, '', 1)
    else
	call <SID>Change('align', 1, '', 1)
    endif
endfunction
function! s:CFFour(var)
    if a:var == 0
	call <SID>Change('eqnarray*', 0, '\\nonumber', 0)
    else
	call <SID>Change('align*', 0, '\\nonumber', 0)
    endif
endfunction

function! s:Change(env, label, delete, putInNonumber)
    if a:env == '['
	if b:DoubleDollars == 0
	    let first = '\['
	    let second = '\]'
	else
	    let first = '$$'
	    let second = '$$'
	endif
    else
	let first = '\begin{' . a:env . '}'
	let second = '\end{' . a:env . '}'
    endif
    if b:DoubleDollars == 0
	let bottom = searchpair('\\\[\|\\begin{','','\\\]\|\\end{','')
	s/\\\]\|\\end{.\{-}}/\=second/
	let top = searchpair('\\\[\|\\begin{','','\\\]\|\\end{','b')
	s/\\\[\|\\begin{.\{-}}/\=first/
    else
	let bottom = search('\$\$\|\\end{')
	s/\$\$\|\\end{.\{-}}/\=second/
	let top = search('\$\$\|\\begin{','b')
	s/\$\$\|\\begin{.\{-}}/\=first/
    endif
    if a:delete != ''
	execute top . ',' . bottom . 's/' . a:delete . '//e'
    endif
    if a:putInNonumber == 1
        execute top
	call search('\\end\|\\\\')
	if line('.') != bottom
	    execute '.+1,' . bottom . 's/\\\\/\\nonumber\\\\/e'
	    execute (bottom-1) . 's/\s*$/  \\nonumber/'
	endif
    endif
    if a:label == 1
	execute top
	if getline(top+1) !~ '.*label.*'
	    put ='\label{}'
	    normal! $
	endif
    else
	execute top . ',' . bottom . 'g/\\label/delete'
    endif
endfunction

function! s:DoEnvironment()
    let l = getline('.')
    let env = strpart(l, 0, col('.'))
    if env =~ '^\s*$'
	call <SID>PutEnvironment(l, input('Environment? '))
    else
	normal! 0D
	call <SID>SetEnvironment(env)
    endif
    startinsert
endfunction

function! s:SetEnvironment(env) 
  let indent = strpart(a:env, 0, match(a:env, '\S')) 
  let env = strpart(a:env, strlen(indent))
  put! =indent . '\begin{' . env . '}'
  +put =indent . '\end{' . env . '}'
  -s/^/\=indent/
  normal $
  if env == 'array'
    -s/$/{}/
    normal $
    startinsert
  elseif env =~# '^\(theorem\|lemma\|equation\|eqnarray\|align\|multline\|gather\)$'
    put!=indent . '\label{}'
    normal! f}
    startinsert
  elseif env =~# '^\(description\|enumerate\|itemize\)$'
    delete
    put!=indent . '\item '
    startinsert!
  endif
endfunction

function! s:PutEnvironment(indent, env)
  let indent = strpart(a:env, 0, match(a:env, '\S')) 
  put! =a:indent . '\begin{' . a:env . '}'
  +put =a:indent . '\end{' . a:env . '}'
  normal! k$
  if a:env=='array'
    call <SID>ArgumentsForArray(input("{rlc}? "))
  elseif a:env =~# '^\(theorem\|lemma\|equation\|eqnarray\|align\|multline\|gather\)$'
    execute "normal! O\\label\<C-V>{" . input("Label? ") . "}\<Esc>j"
  elseif a:env =~# '^\(description\|enumerate\|itemize\)$'
    delete
    put!=indent . '\item '
    startinsert!
  endif
endfunction

function! s:ArgumentsForArray(arg)
    put! = '{' . a:arg . '}'
    normal! kgJj
endfunction

function! s:ChangeEnvironment(env)
    if b:DoubleDollars == 0
	call searchpair('\\\[\|\\begin{','','\\\]\|\\end{','')
    else
	call search('\$\$\|\\end{')
    endif
    let l = getline('.')
    let indent = strpart(l, 0, match(l, '\S'))
    if b:DoubleDollars == 0
	s/\\\]\|\\end{.\{-}}/\='\end{' . a:env . '}'/
	call searchpair('\\\[\|\\begin{','','\\\]\|\\end{','b')
	s/\\\[\|\\begin{.\{-}}/\='\begin{' . a:env . '}'/
    else
	s/\$\$\|\\end{.\{-}}/\='\end{' . a:env . '}'/
	call search('\$\$\|\\begin{','b')
	s/\$\$\|\\begin{.\{-}}/\='\begin{' . a:env . '}'/
    endif
    +
    if a:env =~# '^\(theorem\|lemma\|equation\|eqnarray\|align\|multline\|gather\)$'
	if (-1 == match(getline('.'),"\\label"))
	    let label = input('Label? ')
	    if label != ''
		put! = indent . '\label{' . label . '}'
	    endif
	endif
    elseif a:env[strlen(a:env)-1] == '*'
	if (-1 != match(getline('.'),"\\label"))
	    delete
	endif
    endif
    echo ''
endfunction

function! s:PutInNonumber()
    call search('\\end\|\\\\')
    if getline('.')[col('.')] != 'e'
        .+1,'>s/\\\\/\\nonumber\\\\/e
        normal! `>k
        s/\s*$/  \\nonumber/
    endif
endfunction

" }}}

" }}}
" "========================================================================="
" Greek letters, AucTex style bindings   {{{

" No timeout.  Applies to mappings such as `a for \alpha
set notimeout

inoremap <buffer> <Leader><Leader> <Leader>
inoremap <buffer> <Leader>a \alpha
inoremap <buffer> <Leader>b \beta
inoremap <buffer> <Leader>c \chi
inoremap <buffer> <Leader>d \delta
inoremap <buffer> <Leader>e \varepsilon
inoremap <buffer> <Leader>f \varphi
inoremap <buffer> <Leader>g \gamma
inoremap <buffer> <Leader>h \eta
inoremap <buffer> <Leader>i \int_{}^{}<Esc>F}i
	    " Or \iota or \infty or \in
inoremap <buffer> <Leader>k \kappa
inoremap <buffer> <Leader>l \lambda
inoremap <buffer> <Leader>m \mu
inoremap <buffer> <Leader>n \nu
inoremap <buffer> <Leader>o \omega
inoremap <buffer> <Leader>p \pi
inoremap <buffer> <Leader>q \theta
inoremap <buffer> <Leader>r \rho
inoremap <buffer> <Leader>s \sigma
inoremap <buffer> <Leader>t \tau
inoremap <buffer> <Leader>u \upsilon
inoremap <buffer> <Leader>v \vee
inoremap <buffer> <Leader>w \wedge
inoremap <buffer> <Leader>x \xi
inoremap <buffer> <Leader>y \psi
inoremap <buffer> <Leader>z \zeta
inoremap <buffer> <Leader>D \Delta
inoremap <buffer> <Leader>I \int_{}^{}<Esc>F}i
inoremap <buffer> <Leader>F \Phi
inoremap <buffer> <Leader>G \Gamma
inoremap <buffer> <Leader>L \Lambda
inoremap <buffer> <Leader>N \nabla
inoremap <buffer> <Leader>O \Omega
inoremap <buffer> <Leader>Q \Theta
inoremap <buffer> <Leader>R \varrho
inoremap <buffer> <Leader>S \sum_{}^{}<Esc>F}i
inoremap <buffer> <Leader>U \Upsilon
inoremap <buffer> <Leader>X \Xi
inoremap <buffer> <Leader>Y \Psi
inoremap <buffer> <Leader>0 \emptyset
inoremap <buffer> <Leader>1 \left
inoremap <buffer> <Leader>2 \right
inoremap <buffer> <Leader>3 \Big
inoremap <buffer> <Leader>6 \partial
inoremap <buffer> <Leader>8 \infty
inoremap <buffer> <Leader>/ \frac{}{}<Esc>F}i
inoremap <buffer> <Leader>% \frac{}{}<Esc>F}i
inoremap <buffer> <Leader>@ \circ
inoremap <buffer> <Leader>\| \Big\|
inoremap <buffer> <Leader>= \equiv
inoremap <buffer> <Leader>\ \setminus
inoremap <buffer> <Leader>. \cdot
inoremap <buffer> <Leader>* \times
inoremap <buffer> <Leader>& \wedge
inoremap <buffer> <Leader>- \bigcap
inoremap <buffer> <Leader>+ \bigcup
inoremap <buffer> <Leader>( \subset
inoremap <buffer> <Leader>) \supset
inoremap <buffer> <Leader>< \leq
inoremap <buffer> <Leader>> \geq
inoremap <buffer> <Leader>, \nonumber
inoremap <buffer> <Leader>: \dots
inoremap <buffer> <Leader>~ \tilde{}<Left>
inoremap <buffer> <Leader>^ \hat{}<Left>
inoremap <buffer> <Leader>; \dot{}<Left>
inoremap <buffer> <Leader>_ \bar{}<Left>
inoremap <buffer> <Leader><M-c> \cos
inoremap <buffer> <Leader><C-E> \exp\left(\right)<Esc>F(a
inoremap <buffer> <Leader><C-I> \in
inoremap <buffer> <Leader><C-J> \downarrow
inoremap <buffer> <Leader><C-L> \log
inoremap <buffer> <Leader><C-P> \uparrow
inoremap <buffer> <Leader><Up> \uparrow
inoremap <buffer> <Leader><C-N> \downarrow
inoremap <buffer> <Leader><Down> \downarrow
inoremap <buffer> <Leader><C-F> \to
inoremap <buffer> <Leader><Right> \lim_{}<Left>
inoremap <buffer> <Leader><C-S> \sin
inoremap <buffer> <Leader><C-T> \tan
inoremap <buffer> <Leader><M-l> \ell
inoremap <buffer> <Leader><CR> \nonumber\\<CR><HOME>&&<Left>

" }}}
" "========================================================================="
" Emacs-type bindings  {{{
" vi purists, feel free to delete these!  
inoremap <buffer> <C-A> <Home>
inoremap <buffer> <C-B> <Left>
inoremap <buffer> <C-D> <Del>
inoremap <buffer> <C-E> <End>
inoremap <buffer> <C-F> <Right>
inoremap <buffer> <C-K> <C-R>=<SID>EmacsKill()<CR>
inoremap <buffer> <C-L> <C-O>zz
inoremap <buffer> <C-N> <Down>
inoremap <buffer> <C-P> <Up>
inoremap <buffer> <C-Y> <C-R>"

function! s:EmacsKill()
    if col('.') == strlen(getline('.'))+1
	let @" = "\<CR>"
	return "\<Del>"
    else
	return "\<C-O>D"
    endif
endfunction

" }}}
" "========================================================================="
" Format the paragraph   {{{
" Due to Ralf Aarons
" In normal mode, gw formats the paragraph (without splitting dollar signs).
function! s:TeX_par()
    if (getline('.') != '')
        let par_begin = '^$\|^\s*\\end{\|^\s*\\\]'
        let par_end = '^$\|^\s*\\begin{\|^\s*\\\['
        call search(par_begin, 'bW')
        "call searchpair(par_begin, '', par_end, 'bW')
        +
	let l = line('.')
        normal! V
        call search(par_end, 'W')
        "call searchpair(par_begin, '', par_end, 'W')
        -
	if l == line('.')
	    normal! 
	endif
	normal Q
	"normal! Q
    endif
endfun
map <buffer><silent> gw :call <SID>TeX_par()<CR>

" }}}
" "========================================================================="
" Alt and Insert key Macros   {{{

" We use Alt-v, since Alt-b interferes with the Buffer menu.
" Boldface:  (3 alternative macros)
" In the first, \mathbf{} appears.
" In the second, you type the letter, and it capitalizes the letter
" and surrounds it with \mathbf{}
" In the third, type <M-v>, you're asked for a character to be capitalized.
" inoremap <buffer> <M-v> \mathbf{}<Left>
" inoremap <buffer> <Insert>b \mathbf{}<Left>
inoremap <buffer> <M-v> <Left>\mathbf{<Right>}<Esc>h~a
inoremap <buffer> <Insert>b <Left>\mathbf{<Right>}<Esc>h~a
vnoremap <buffer> <M-v> <C-C>`>a}<Esc>`<i\mathbf{<Esc>
vnoremap <buffer> <Insert>b <C-C>`>a}<Esc>`<i\mathbf{<Esc>
"function! s:mathbf()
"    echo 'Mathbf: '
"    let c = nr2char(getchar())
"    return "\\mathbf{".c."}\<Esc>hvUla"
"endfunction
"inoremap <buffer> <M-b> <C-R>=<SID>mathbf()<CR>
"inoremap <buffer> <Insert>b <C-R>=<SID>mathbf()<CR>

" Cal:  (3 alternative macros:  see Boldface)
" In the first, \mathcal{} appears.
" In the second, you type the letter, and it capitalizes the letter
" and surrounds it with \mathcal{}
" The third one also inserts \cite{}, if the previous character is a blank.
" The fourth asks for a character, capitalizes it, in \mathcal{}
" inoremap <buffer> <M-c> \mathcal{}<Left>
" inoremap <buffer> <M-c> <Left>\mathcal{<Right>}<Esc>h~a
vnoremap <buffer> <M-c> <C-C>`>a}<Esc>`<i\mathcal{<Esc>
vnoremap <buffer> <Insert>c <C-C>`>a}<Esc>`<i\mathcal{<Esc>
inoremap <buffer> <M-c> <C-R>=<SID>MathCal()<CR>
inoremap <buffer> <Insert>c <C-R>=<SID>MathCal()<CR>
function! s:MathCal()
    if getline('.')[col('.')-2] =~ '[a-zA-Z0-9]'
	return "\<Left>\\mathcal{\<Right>}\<Esc>h~a"
    else
	return "\\cite{}\<Left>"
    endif
endfunction
"function! s:mathcal()
"    echo 'Mathcal: '
"    let c = nr2char(getchar())
"    return "\\mathcal{".c."}\<Esc>h~a"
"endfunction
"inoremap <buffer> <M-c> <C-R>=<SID>mathcal()<CR>
"inoremap <buffer> <Insert>c <C-R>=<SID>mathcal()<CR>

"  This macro asks the user for the input to \mathbf{}
"inoremap <buffer> <M-b> <C-R>=<SID>WithBrackets("mathbf")<CR>
"function! s:WithBrackets(string)
"    let user = input(a:string . ': ')
"    return "\\" . a:string . '{' . user . '}'
"endfunction

" Alt-h or Insert-h inserts \widehat{}
inoremap <buffer> <M-h> \widehat{}<Left>
inoremap <buffer> <Insert>h \widehat{}<Left>

" Alt-i or Insert-i inserts \item 
inoremap <buffer> <M-i> <CR>\item 
inoremap <buffer> <Insert>i <CR>\item 

" Alt-m or Insert-m inserts \mbox{}
inoremap <buffer> <M-m> \mbox{}<Left>
inoremap <buffer> <Insert>m \mbox{}<Left>
vnoremap <buffer> <M-m> <C-C>`>a}<Esc>`<i\mbox{<Esc>
vnoremap <buffer> <Insert>m <C-C>`>a}<Esc>`<i\mbox{<Esc>

" Alt-o or Insert-o inserts \overline{}
inoremap <buffer> <M-o> \overline{}<Left>
inoremap <buffer> <Insert>o \overline{}<Left>

" Alt-r or Insert-r inserts (\ref{})
" There are 2 versions.
" The second one inserts \ref{} if the preceding word is Lemma or the like.
"inoremap <buffer> <M-r> (\ref{})<Left><Left>
"inoremap <buffer> <Insert>r (\ref{})<Left><Left>
inoremap <buffer> <M-r> <C-R>=<SID>TexRef()<CR><Esc>F{a
inoremap <buffer> <Insert>r <C-R>=<SID>TexRef()<CR><Esc>F{a
function! s:TexRef()
    let insert = '(\ref{})'
    let lemma = strpart(getline("."),col(".")-7,6)
    if lemma =~# 'Lemma \|emmas \|eorem \|llary '
	let insert = '\ref{}'
    endif
    return insert
endfunction

" Alt-s or Insert-s inserts \sqrt{}
inoremap <buffer> <M-s> \sqrt{}<Left>
inoremap <buffer> <Insert>s \sqrt{}<Left>

" Insert-t or Insert-t inserts Textbf
inoremap <buffer> <Insert>t \textbf{}<Left>
inoremap <buffer> <M-t> \textbf{}<Left>
vnoremap <buffer> <Insert>t <C-C>`>a}<Esc>`<i\textbf{<Esc>
vnoremap <buffer> <M-t> <C-C>`>a}<Esc>`<i\textbf{<Esc>

" This is for _{}^{}.  It gets rid of the ^{} part
inoremap <buffer> <M-x> <Esc>f^cf}
inoremap <buffer> <Insert>x <Esc>f^cf}

" Alt-u or Insert-u inserts \underline
inoremap <buffer> <M-u> \underline{}<Left>
inoremap <buffer> <Insert>u \underline{}<Left>

" Alt- or Insert- (Alt-minus or Insert-minus) inserts _{}^{}
inoremap <buffer> <M--> _{}^{}<Esc>3hi
inoremap <buffer> <Insert>- _{}^{}<Esc>3hi

" Alt-; or Insert-; inserts \dot{}
inoremap <buffer> <M-;> \dot{}<Left>
inoremap <buffer> <Insert>; \dot{}<Left>

" Alt-<Right> or Insert-<Right> inserts \lim_{}
inoremap <buffer> <M-Right> \lim_{}<Left>
inoremap <buffer> <Insert><Right> \lim_{}<Left>

" }}}
" "========================================================================="
" Alt-l or Insert-l inserts \left...\right (3 alternatives)   {{{

" In the first version, you type Alt-l and then the bracket
" In the second version, you type the bracket, and then Alt-l
" It also doubles as a command for inserting \label{}, if the previous
" character is blank.
" The third version is like the second version.  Use it if you have
" disabled automatic bracket completion.
"inoremap <buffer> <M-l>( \left(\right)<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l( \left(\right)<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>\| \left\|\right\|<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l\| \left\|\right\|<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>[ \left[\right]<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l[ \left[\right]<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>{ \left\{\right\}<Left><Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l{ \left\{\right\}<Left><Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>< \langle\rangle<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l< \langle\rangle<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>q \lefteqn{
"inoremap <buffer> <Insert>lq \lefteqn{
function! s:LeftRight()
    let line = getline('.')
    let char = line[col('.')-1]
    let previous = line[col('.')-2]
    if char =~ '(\|\['
        execute "normal! i\\left\<Esc>la\\right\<Esc>6h"
    elseif char == '|'
	if previous == '\'
	    execute "normal! ileft\\\<Esc>"
	else
	    execute "normal! i\\left\<Esc>"
	endif
	execute "normal! la\\right\<Esc>6h"
    elseif char == '{'
	if previous == '\'
	    execute "normal! ileft\\\<Esc>la\\right\<Esc>6h"
	else
	    execute "normal! i\\left\\\<Esc>la\\right\\\<Esc>7h"
	endif
    elseif char == '<'
	execute "normal! s\\langle\\rangle\<Esc>7h"
    elseif char == 'q'
	execute "normal! s\\lefteqn\<C-V>{\<Esc>"
    else
	execute "normal! a\\label\<C-V>{}\<Esc>h"
    endif
endfunction
inoremap <buffer> <M-l> <Esc>:call <SID>LeftRight()<CR>a
inoremap <buffer> <Insert>l <Esc>:call <SID>LeftRight()<CR>a
noremap <buffer> <M-l> :call <SID>PutLeftRight()<CR>
noremap <buffer> <Insert>l :call <SID>PutLeftRight()<CR>
vnoremap <buffer> <M-l> <C-C>`>a\right<Esc>`<i\left<Esc>
vnoremap <buffer> <Insert>l <C-C>`>a\right<Esc>`<i\left<Esc>
"function! s:LeftRight()
"let char = getline('.')[col('.')-1]
"let previous = getline('.')[col('.')-2]
"if char == '('
"	execute "normal! i\\left\<Esc>la\\right)\<Esc>7h"
"elseif char == '['
"	execute "normal! i\\left\<Esc>la\\right]\<Esc>7h"
"elseif char == '|'
"	if previous == '\'
"		execute "normal! ileft\\\<Esc>la\\right\\\|\<Esc>8h"
"	else
"		execute "normal! i\\left\<Esc>la\\right\|\<Esc>7h"
"	endif
"elseif char == '{'
"	if previous == '\'
"		execute "normal! ileft\\\<Esc>la\\right\\}\<Esc>8h"
"	else
"		execute "normal! i\\left\\\<Esc>la\\right\\}\<Esc>8h"
"	endif
"elseif char == '<'
"	execute "normal! s\\langle\\rangle\<Esc>7h"
"elseif char == 'q'
"	execute "normal! s\\lefteqn{\<Esc>lx"
"endif
"endfunction

" }}}
" "========================================================================="
" Smart quotes.   {{{
" Thanks to Ron Aaron <ron@mossbayeng.com>.
function! s:TexQuotes()
    let insert = "''"
    let left = getline('.')[col('.')-2]
    if left =~ '^\(\|\s\)$'
	let insert = '``'
    elseif left == '\'
	let insert = '"'
    endif
    return insert
endfunction
inoremap <buffer> " <C-R>=<SID>TexQuotes()<CR>

" }}}
" "========================================================================="
" Typing .. results in \ldots or \cdots   {{{

" Use this if you want . to result in a just a period, with no spaces.
"function! s:Dots(var)
"    let column = col('.')
"    let currentline = getline('.')
"    let left = strpart(currentline ,column-3,2)
"    let before = currentline[column-4]
"    if left == '..'
"    	if a:var == 0
"	    if before == ','
"		return "\<BS>\<BS>\\ldots"
"	    else
"		return "\<BS>\<BS>\\cdots"
"	    endif
"        else
"	    return "\<BS>\<BS>\\dots"
"	endif
"    else
"       return '.'
"    endif
"endfunction
" Use this if you want . to result in a period followed by 2 spaces.
" To get just one space, see the comment in the function below.
function! s:Dots(var)
    let column = col('.')
    let currentline = getline('.')
    let previous = currentline[column-2]
    let before = currentline[column-3]
    if strpart(currentline,column-4,3) == '.  '
	return "\<BS>\<BS>"
    elseif previous == '.'
    	if a:var == 0
	    if before == ','
		return "\<BS>\\ldots"
	    else
		return "\<BS>\\cdots"
	    endif
        else
	    return "\<BS>\\dots"
	endif
    elseif previous =~ '[\$A-Za-z]' && currentline !~ '@'
	" To get just one space, replace '.  ' with '. ' below.
	return <SID>TexFill(b:tw, '.  ')  "TexFill is defined in Auto-split
    else
	return '.'
    endif
endfunction
" Uncomment the next line, and comment out the line after,
" if you want the script to decide between latex and amslatex.
" This slows down the macro.
"inoremap <buffer><silent> . <C-R>=<SID>Dots(<SID>AmsLatex(b:AMSLatex))<CR>
inoremap <buffer><silent> . <Space><BS><C-R>=<SID>Dots(b:AMSLatex)<CR>
" Note: <Space><BS> makes word completion work correctly.

" }}}
" "========================================================================="
" _{} and ^{}   {{{

" Typing __ results in _{}
function! s:SubBracket()
    let insert = '_'
    let left = getline('.')[col('.')-2]
    if left == '_'
	let insert = "{}\<Left>"
    endif
    return insert
endfunction
inoremap <buffer><silent> _ <C-R>=<SID>SubBracket()<CR>

" Typing ^^ results in ^{}
function! s:SuperBracket()
    let insert = '^'
    let left = getline('.')[col('.')-2]
    if left == '^'
	let insert = "{}\<Left>"
    endif
    return insert
endfunction
inoremap <buffer><silent> ^ <C-R>=<SID>SuperBracket()<CR>

" }}}
" "========================================================================="
" Bracket Completion Macros   {{{

" Key Bindings                {{{

" Typing the symbol a second time (for example, $$) will result in one
" of the symbole (for instance, $).  With {, typing \{ will result in \{\}.
inoremap <buffer><silent> ( <C-R>=<SID>Double('(',')')<CR>
"inoremap <buffer><silent> [ <C-R>=<SID>Double('[',']')<CR>
inoremap <buffer><silent> [ <C-R>=<SID>CompleteSlash('[',']')<CR>
inoremap <buffer><silent> $ <C-R>=<SID>Double('$','$')<CR>
inoremap <buffer><silent> & <C-R>=<SID>DoubleAmpersands()<CR>
inoremap <buffer><silent> { <C-R>=<SID>CompleteSlash('{','}')<CR>
inoremap <buffer><silent> \| <C-R>=<SID>CompleteSlash("\|","\|")<CR>

" If you would rather insert $$ individually, the following macro by 
" Charles Campbell will make the cursor blink on the previous dollar sign,
" if it is in the same line.
" inoremap <buffer> $ $<C-O>F$<C-O>:redraw!<CR><C-O>:sleep 500m<CR><C-O>f$<Right>

" }}}

" Functions         {{{

" For () and $$
function! s:Double(left,right)
    if strpart(getline('.'),col('.')-2,2) == a:left . a:right
	return "\<Del>"
    else
	return a:left . a:right . "\<Left>"
    endif
endfunction

" Complete [, \[, {, \{, |, \|
function! s:CompleteSlash(left,right)
    let column = col('.')
    let first = getline('.')[column-2]
    let second = getline('.')[column-1]
    if first == "\\"
	if a:left == '['
	    return "\[\<CR>\<CR>\\]\<Up>"
	else
	    return a:left . "\\" . a:right . "\<Left>\<Left>"
	endif
    else
	if a:left =~ '\[\|{'
	\ && strpart(getline('.'),col('.')-2,2) == a:left . a:right
	    return "\<Del>"
        else
            return a:left . a:right . "\<Left>"
	endif
    endif
endfunction

" Double ampersands, if you are in an eqnarray or eqnarray* environment.
function! s:DoubleAmpersands()
    let stop = 0
    let currentline = line('.')
    while stop == 0
	let currentline = currentline - 1
	let thisline = getline(currentline)
	if thisline =~ '\\begin' || currentline == 0
	    let stop = 1
	endif
    endwhile
    if thisline =~ '\\begin{eqnarray\**}'
	return "&&\<Left>"
    elseif strpart(getline('.'),col('.')-2,2) == '&&'
	return "\<Del>"
    else
	return '&'
    endif
endfunction

" }}}

" }}}
" "========================================================================="
" Embrace the visual region with the symbol.   {{{

vnoremap <buffer> <Leader>( <C-C>`>a)<Esc>`<i(<Esc>
vnoremap <buffer> <Leader>[ <C-C>`>a]<Esc>`<i[<Esc>
vnoremap <buffer> <Leader>{ <C-C>`>a}<Esc>`<i{<Esc>
vnoremap <buffer> & <C-C>`>a&<Esc>`<i&<Esc>
vnoremap <buffer> <Leader>$ <C-C>`>a$<Esc>`<i$<Esc>
vnoremap <buffer> <M-4> <C-C>`>a$<Esc>`<i$<Esc>
vnoremap <buffer> <Leader>/ <C-C>`>a}{}<Esc>`<i\frac{<Esc>f{a

" }}}
" "========================================================================="
" Auto-split long lines.   {{{

" Key Bindings                {{{

noremap <buffer> gq :call <SID>TexFormatLine(b:tw,getline('.'),col('.'))<CR>
noremap <buffer> Q :call <SID>TexFormatLine(b:tw,getline('.'),col('.'))<CR>
vnoremap <buffer> Q J:call <SID>TexFormatLine(b:tw,getline('.'),col('.'))<CR>
"  With this map, <Space> will split up a long line, keeping the dollar
"  signs together (see the next function, TexFormatLine).
inoremap <buffer><silent> <Space> <Space><BS><C-R>=<SID>TexFill(b:tw, ' ')<CR>
" Note: <Space><BS> makes word completion work correctly.

" }}}

" Functions       {{{

function! s:TexFill(width, string)
    if col('.') > a:width
	" For future use, record the current line and 
	" the number of the current column.
	let current_line = getline('.')
	let current_column = col('.')
	execute 'normal! i'.a:string.'##'
	call <SID>TexFormatLine(a:width,current_line,current_column)
	call search('##', 'b')
	return "\<Del>\<Del>"
    else
	return a:string
    endif
endfunction

function! s:TexFormatLine(width,current_line,current_column)
    " Find the first nonwhitespace character.
    let first = matchstr(a:current_line, '\S')
    normal! $
    let length = col('.')
    let go = 1
    while length > a:width+2 && go
	let between = 0
	let string = strpart(getline('.'),0,a:width)
	" Count the dollar signs
        let number_of_dollars = 0
	let evendollars = 1
	let counter = 0
	while counter <= a:width-1
	    " Pay attention to '$$'.
	    "if string[counter] == '$' && string[counter-1] != '$'
	    if string[counter] == '$' && string[counter-1] !~ '\$\|\\'
	       let evendollars = 1 - evendollars
	       let number_of_dollars = number_of_dollars + 1
	    endif
	    let counter = counter + 1
	endwhile
	" Get ready to split the line.
	execute 'normal! ' . (a:width + 1) . '|'
	if evendollars
	" Then you are not between dollars.
	    call search("\\$\\+\\| ", 'b')
	    normal W
	else
	" Then you are between dollars.
	    normal! F$
	    " Move backward once more if you are at "$$".
	    if getline('.')[col('.')-2] == '$'
		normal h
	    endif
	    if col('.') == 1 || strpart(getline('.'),col('.')-1,1) != '$'
	       let go = 0
	    endif
	endif
	if first == '$' && number_of_dollars == 1
	    let go = 0
	else
	    execute "normal! i\<CR>\<Esc>$"
	    " Find the first nonwhitespace character.
	    let first = matchstr(getline('.'), '\S')
	endif
	let length = col('.')
    endwhile
    if go == 0 && strpart(a:current_line,0,a:current_column) =~ '.*\$.\+\$.*'
	execute "normal! ^f$a\<CR>\<Esc>"
	call <SID>TexFormatLine(a:width,a:current_line,a:current_column)
    endif
endfunction

" }}}

" }}}
" "========================================================================="
" Matching Brackets Macros using <Insert><Insert>.   {{{
" (due to Saul Lubkin).  For normal mode.

" Double insert key macros for working with brackets   {{{
" The cursor must be over a bracket, in normal mode.

function! s:DoubleInsert()
    let c = nr2char(getchar())
    if c == "d"
	call <SID>DeleteBrackets()
    elseif c == "("
	call <SID>ChangeRound()
    elseif c == ")"
	call <SID>ChangeRound()
    elseif c == "["
	call <SID>ChangeSquare()
    elseif c == "]"
	call <SID>ChangeSquare()
    elseif c == "{"
	call <SID>ChangeCurly()
    elseif c == "}"
	call <SID>ChangeCurly()
    elseif c == "l"
	call <SID>PutLeftRight()
    elseif c == "p"
	call <SID>PutBigg()
    elseif c == "c"
	call <SID>ChangeLeftRightBigg()
    endif
endfunction
    
noremap <buffer><silent> <Insert><Insert> :echo "Brackets: d: del  ()[]{}: change  l: \\left  p: prefix  c: change\n\n"<CR>:call <SID>DoubleInsert()<CR>

noremap <buffer><silent> <C-Del> :call <SID>DeleteBrackets()<CR>
inoremap <buffer><silent> <C-BS> <Left><C-O>:call <SID>DeleteBrackets()<CR>

" }}}
" Functions   {{{

" Delete matching brackets.
function! s:DeleteBrackets()
    let bb = getline('.')[col('.') - 2]
    let cc = getline('.')[col('.') - 1]
    if bb == '\' && cc =~ '{\|}'
	normal! X%X%
    endif
    if cc =~ '{\|\[\|('
	normal! %x``x
    elseif cc =~ '}\|\]\|)'
	normal! %%x``x``
    endif
endfunction

" Put \left...\right in front of the matched brackets.
function! s:PutLeftRight()
    let previous = getline('.')[col('.') - 2]
    let char = getline('.')[col('.') - 1]
    if previous == '\'
    if char == '{'
	execute "normal! ileft\\\<Esc>l%iright\\\<Esc>l%"
    elseif char == '}'
	execute "normal! iright\\\<Esc>l%ileft\\\<Esc>l%"
    endif
    elseif char =~ '\[\|('
	execute "normal! i\\left\<Esc>l%i\\right\<Esc>l%"
    elseif char =~ '\]\|)'
	execute "normal! i\\right\<Esc>l%i\\left\<Esc>l%"
    endif
endfunction

" Look at the 'string', and return either 'default' or the string.
function! s:StripSlash(string,default)
    let len = strlen(a:string)
    if a:string[0] == '\'
	return strpart(a:string, 1, len-1)
    elseif len == 0
	return a:default
    else
	return '\' . a:string
    endif
endfunction

" Put \Big (or whatever the reader chooses) in front of the matched brackets.
function! s:PutBigg()
    let in = input("\\big, \\bigg, or what? (default: \\Big):  \\")
    let in = <SID>StripSlash(in,"\\Big")
    let b = getline('.')[col('.') - 2]
    let c = getline('.')[col('.') - 1]
    if b == '\'
	execute "normal! hi" . in . "\<Esc>l%hi" . in . "\<Esc>l%"
    elseif c =~ '{\|\[\|(\|}\|\]\|)'
	execute "normal! i" . in . "\<Esc>l%i" . in . "\<Esc>l%"
    endif
endfunction

" Change \left..\right to \bigg, or whatever the user chooses.
function! s:ChangeLeftRightBigg()
    let in = input("\\Big, \\bigg, or what? (default: nothing):  \\")
    let in = <SID>StripSlash(in,'')
    let b = getline('.')[col('.') - 2]
    let c = getline('.')[col('.') - 1]
    if b == '\'
      if c =~ '{\|}'
	execute "normal! 2F\\xcw" . in . "\<Esc>2l%2F\\xcw" . in . "\<Esc>2l%"
      endif
    elseif c =~ '\[\|(\|\]\|)'
      execute "normal! F\\xcw" . in . "\<Esc>l%F\\xcw" . in . "\<Esc>l%"
    endif
endfunction

" Change the brackets to curly brackets.
function! s:ChangeCurly()
    let c = getline('.')[col('.') - 1]
    if c =~ '\[\|('
	execute "normal! i\\{\<Esc>l%i\\\<Esc>lr}``xh"
    elseif c =~ '\]\|)'
	execute "normal! %i\\{\<Esc>l%i\\\<Esc>lr}``xh%"
    endif
endfunction

" Change the brackets to round brackets.
function! s:ChangeRound()
    let b = getline('.')[col('.') - 2]
    let c = getline('.')[col('.') - 1]
    if b == '\'
	if c == '{'
	    normal! %Xr)``Xr(
	elseif c == '}'
	    normal! %%Xr)``Xr(``
	endif
    elseif c == '['
	normal! %r)``r(
    elseif c == ']'
	normal! %%r)``r(%
    endif
endfunction

" Change the brackets to square brackets.
function! s:ChangeSquare()
    let b = getline('.')[col('.') - 2]
    let c = getline('.')[col('.') - 1]
    if b == '\'
	if c == '{'
	    normal! %Xr]``Xr[
	elseif c == '}'
	    normal! %%Xr]``Xr[``
	endif
    elseif c == '('
	normal! %r]``r[
    elseif c == ')'
	normal! %%r]``r[%
    endif
endfunction

" }}}

" }}}
" "========================================================================="
" Menus   {{{

" Bracket Menus
nnoremenu 40.401 Brac&kets.&delete\ brackets\ \ \ Ctrl+Del,Ctrl+BS,Tab-x :call <SID>DeleteBrackets()<CR>
inoremenu 40.402 Brac&kets.&delete\ brackets\ \ \ Ctrl+Del,Ctrl+BS,Tab-x <Left><C-O>:call <SID>DeleteBrackets()<CR>
nnoremenu 40.403 Brac&kets.change\ to\ &() :call <SID>ChangeRound()<CR>
nnoremenu 40.404 Brac&kets.change\ to\ &() :call <SID>ChangeRound()<CR>
inoremenu 40.404 Brac&kets.change\ to\ &() <Esc>:call <SID>ChangeRound()<CR>a
nnoremenu 40.405 Brac&kets.change\ to\ &[] :call <SID>ChangeSquare()<CR>
inoremenu 40.406 Brac&kets.change\ to\ &[] <Esc>:call <SID>ChangeSquare()<CR>a
nnoremenu 40.407 Brac&kets.change\ to\ \&\{\\} :call <SID>ChangeCurly()<CR>
inoremenu 40.408 Brac&kets.change\ to\ \&\{\\} <Esc>:call <SID>ChangeCurly()<CR>a
nnoremenu 40.409 Brac&kets.insert\ \&\left,\\right :call <SID>PutLeftRight()<CR>
inoremenu 40.410 Brac&kets.insert\ \&\left,\\right <Esc>:call <SID>PutLeftRight()<CR>a
nnoremenu 40.410 Brac&kets.&insert\ (default\ \\Big) :call <SID>PutBigg()<CR>
inoremenu 40.411 Brac&kets.&insert\ (default\ \\Big) <Esc>:call <SID>PutBigg()<CR>a
nnoremenu 40.412 Brac&kets.&change\ \\left,\\right,\\big,\ etc\ to\ (default\ nothing) :call <SID>ChangeLeftRightBigg()<CR>
inoremenu 40.413 &Brackets.&change\ \\left,\\right\,\\big,\ etc\ to\ (default\ nothing) <Esc>:call <SID>ChangeLeftRightBigg()<CR>a

" Menus for running Latex, etc.
nnoremenu 50.401 Latex.run\ latex\ \ \ \ Control-Tab :w<CR>:silent ! xterm -bg ivory -fn 7x14 -e latex % &<CR>
inoremenu 50.401 Latex.run\ latex\ \ \ \ Control-Tab <Esc>:w<CR>:silent ! xterm -bg ivory -fn 7x14 -e latex % &<CR>
nnoremenu 50.402 Latex.next\ math\ error\ \ \ Shift-Tab :call <SID>NextTexError()<CR><Space>
inoremenu 50.402 Latex.next\ math\ error\ \ \ Shift-Tab <Esc>:call <SID>NextTexError()<CR><Space>
nnoremenu 50.403 Latex.next\ ref\ error :call <SID>CheckReferences('Reference', 'ref')<CR><Space>
inoremenu 50.403 Latex.next\ ref\ error <Esc>:call <SID>CheckReferences('Reference', 'ref')<CR><Space>
nnoremenu 50.404 Latex.next\ cite\ error :call <SID>CheckReferences('Citation', 'cite')<CR><Space>
inoremenu 50.404 Latex.next\ cite\ error <Esc>:call <SID>CheckReferences('Citation', 'cite')<CR><Space>
nnoremenu 50.405 Latex.view\ log\ file :call <SID>LookAtLogFile()<CR>
inoremenu 50.405 Latex.view\ log\ file <Esc>:call <SID>LookAtLogFile()<CR>
nnoremenu 50.406 Latex.view\ dvi\ \ \ \ \ Alt-Tab :call <SID>Xdvi()<CR><Space>
inoremenu 50.406 Latex.view\ dvi\ \ \ \ \ Alt-Tab <Esc>:call <SID>Xdvi()<CR><Space>
nnoremenu 50.407 Latex.run\ ispell\ \ \ Shift-Ins :w<CR>:silent ! xterm -bg ivory -fn 10x20 -e ispell %<CR>:e %<CR><Space>
inoremenu 50.407 Latex.run\ ispell\ \ \ Shift-Ins <Esc>:w<CR>:silent ! xterm -bg ivory -fn 10x20 -e ispell %<CR>:e %<CR><Space>
"nnoremenu 50.405 Latex.run\ engspchk :so .Vim/engspchk.vim<CR>
"inoremenu 50.405 Latex.run\ engspchk <C-O>:so .Vim/engspchk.vim<CR>

" }}}
" "========================================================================="
" Math Abbreviations   {{{

iab <buffer> \b \bigskip
iab <buffer> \h \hspace{
iab <buffer> \i \noindent
iab <buffer> \l \newline
iab <buffer> \m \medskip
iab <buffer> \n \nonumber\\
iab <buffer> \p \newpage
iab <buffer> \q \qquad
iab <buffer> \v \vfill

" }}}
" "========================================================================="
" Personal or Temporary bindings.   {{{

inoremap <buffer> ;; ;<Space><Space>

inoremap <buffer> ;e E\left[\right]<Esc>F\i
"inoremap <buffer> ;e \epsilon
inoremap <buffer> ;d \diamond
inoremap <buffer> ;I \int_{\mathbf{R}^d}

" }}}
" "========================================================================="

" vim:fdm=marker
