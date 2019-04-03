#!/bin/bash
if [[ -d "themes/next" ]]; then
  cd themes/next;
  git pull;
  cd ../../;
else
  git clone https://github.com/theme-next/hexo-theme-next themes/next;
fi
cp .travis/theme_config.yml themes/next/_config.yml;