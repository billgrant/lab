" ============================================================================
" SYNTAX AND FILE TYPE SETTINGS
" ============================================================================

" Enable syntax highlighting - colors keywords, strings, comments, etc.
" based on the file type detected
syntax on

" Automatically indent new lines to match the indentation of the previous line
set autoindent

" Enable file type detection and load file type-specific plugins
" This allows vim to recognize different file types (Python, JavaScript, etc.)
filetype plugin on

" Enable file type-specific indentation rules
" Each file type can have its own indentation behavior
filetype indent on

" ============================================================================
" TAB AND INDENTATION SETTINGS
" ============================================================================

" Set the width of a tab character to 2 spaces when displayed
set tabstop=2

" Set the number of spaces to use for each step of autoindent
" This affects >> and << commands, as well as automatic indentation
set shiftwidth=2

" Convert tab keypresses to spaces instead of inserting actual tab characters
" This ensures consistent indentation across different editors and systems
set expandtab

" Set the number of spaces that a <Tab> keypress inserts in insert mode
" When combined with expandtab, pressing Tab will insert 2 spaces
set softtabstop=2

" ============================================================================
" VISUAL HELPERS
" ============================================================================

" Highlight trailing whitespace as an error
" This autocmd runs whenever a file is read or a new file is created
autocmd BufRead,BufNewFile * match error /\s\+$/

" ============================================================================
" EDITING BEHAVIOR
" ============================================================================

" Allow backspace to delete over line breaks, automatically inserted
" indentation, and the start of insert mode
" - indent: allows backspacing over autoindent
" - eol: allows backspacing over line breaks (join lines)
" - start: allows backspacing over the start of insert mode
set backspace=indent,eol,start
