#
# Cookbook Name:: hab_getting_started
# Recipe:: create_first_plan_linux
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

plan_path = '~/habitat-example-plans/mytutorialapp/habitat/plan.sh'

with_snippet_options(lesson: 'create_first_plan')

with_snippet_options(cwd: '~', step: 'clone-the-project') do

  snippet_execute 'cd-home' do
    command 'cd ~'
  end

  snippet_execute 'git-clone-example-plans' do
    command 'git clone https://github.com/habitat-sh/habitat-example-plans'
    not_if 'stat ~/habitat-example-plans'
  end

  snippet_execute 'cd-mytutorialapp-1' do
    command 'cd ~/habitat-example-plans/mytutorialapp'
  end

end

with_snippet_options(cwd: '~/habitat-example-plans/mytutorialapp', step: 'start-with-the-basics') do

  snippet_execute 'cd-mytutorialapp-habitat' do
    command 'cd ~/habitat-example-plans/mytutorialapp/habitat'
  end

  # `$EDITOR plan.sh` not shown

  snippet_code_block 'plan-sh-original' do
    file_path plan_path
    content lazy { ::File.read(::File.expand_path(plan_path)) }
    write_system_file false
  end

end

with_snippet_options(cwd: '~/habitat-example-plans/mytutorialapp/habitat', step: 'modify-the-plan') do

  snippet_code_block 'pkg_deps' do
    file_path plan_path
    source_filename 'pkg_deps'
    write_system_file false
  end

  snippet_code_block 'pkg_expose' do
    file_path plan_path
    source_filename 'pkg_expose'
    write_system_file false
  end

end

with_snippet_options(cwd: '~/habitat-example-plans/mytutorialapp/habitat', step: 'add-in-callbacks') do

  snippet_code_block 'callbacks-1' do
    file_path plan_path
    source_filename 'callbacks-1'
    write_system_file false
  end

  snippet_code_block 'callbacks-2' do
    file_path plan_path
    source_filename 'callbacks-2'
    write_system_file false
  end

  snippet_code_block 'plan-1' do
    file_path plan_path
    source_filename 'plan-1.sh'
  end

end

with_snippet_options(cwd: '~/habitat-example-plans/mytutorialapp/habitat', step: 'do-initial-build') do

  snippet_execute 'cd-mytutorialapp-2' do
    command 'cd ~/habitat-example-plans/mytutorialapp'
  end

  snippet_execute 'hab-studio-run-build-1' do
    command 'hab studio run build'
    cwd '~/habitat-example-plans/mytutorialapp'
  end

end
