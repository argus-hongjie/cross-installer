install_shellbasedeps() {

  APK_PACKAGES='tar sed vim less findutils git build-base' \
  APTGET_PACKAGES='vim exuberant-ctags less locate git' \
  main install-pkg || return $?

  hascmd apt-get || { main install ctags || return ;}

  main cleanup
}

install_ctags() {
  curl -fsSL http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz | tar -zxC /tmp && \
  (cd /tmp/ctags-5.8 && ./configure && make && make install && cd && apk del build-base && rm -rf /tmp/*)
}

install_shellbase() {
  local version="$1"; shift

  curl -fsSL https://github.com/elifarley/shellbase/archive/"$version".tar.gz \
  | tar --exclude README.md --exclude LICENSE --strip=1 --overwrite -zxvC "$HOME" || return $?

  sed -i '/^set listchars=tab/d' "$HOME"/.vimrc || return $?
  
  curl -fsSL https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark \
    > "$HOME"/.dircolors || return $?
  
  printf "PATH=$PATH\n" >> "$HOME"/.ssh/environment || return $?
  printf ". '$HOME'/.ssh/environment\npwd" >> "$HOME"/.bashrc
}

export VIM_EXTRA_URLS='
https://github.com/tpope/vim-eunuch/archive/master.tar.gz
https://github.com/altercation/vim-colors-solarized/archive/master.tar.gz
https://github.com/tpope/vim-obsession/archive/master.tar.gz
https://github.com/justinmk/vim-dirvish/archive/master.tar.gz
https://github.com/tpope/vim-vinegar/archive/master.tar.gz
https://github.com/ervandew/supertab/archive/master.tar.gz
https://github.com/ctrlpvim/ctrlp.vim/archive/master.tar.gz
https://github.com/majutsushi/tagbar/archive/master.tar.gz
https://github.com/tpope/vim-fugitive/archive/master.tar.gz
https://github.com/tpope/vim-rails/archive/master.tar.gz
https://github.com/tpope/vim-bundler/archive/master.tar.gz
'

install_shellbasevimextra() {

  # Install Pathogen - https://github.com/tpope/vim-pathogen
  mkdir -p "$HOME"/.vim/autoload "$HOME"/.vim/bundle "$HOME"/.vim/colors || return $?
  curl -fsSL https://raw.githubusercontent.com/sjl/badwolf/master/colors/badwolf.vim > "$HOME"/.vim/colors/badwolf.vim || return $?
  curl -fsSL https://raw.githubusercontent.com/jnurmine/Zenburn/master/colors/zenburn.vim > "$HOME"/.vim/colors/zenburn.vim || return $?
  curl -fsSL https://tpo.pe/pathogen.vim > "$HOME"/.vim/autoload/pathogen.vim || return $?

  sed -i '1 i\execute pathogen#infect()\ncall pathogen#helptags()\n' "$HOME"/.vimrc || return $?

  ( cd ~/.vim/bundle && mkdir -p csapprox && curl -fsSL https://github.com/godlygeek/csapprox/archive/4.00.tar.gz \
      | tar --strip 1 -zxC csapprox && \
    for url in $(echo $VIM_EXTRA_URLS);
      do echo "Downloading $url..." && curl -fsSL "$url" | tar -zx &
    done && wait && mv vim-vinegar-* vim-vinegar~ || return
  )

  chown -R $_USER:$_USER "$HOME" && updatedb
}
