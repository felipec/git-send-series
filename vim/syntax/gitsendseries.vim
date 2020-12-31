if exists('b:current_syntax')
  finish
endif

syn include @gssYaml syntax/yaml.vim
syn region gssHeader start="\%^" matchgroup=gssSubject end="^\n.\+\n$" keepend transparent contains=@gssYaml

hi def link gssSubject title

let b:current_syntax='gitsendseries'
