install_data(
  '@0@.desktop'.format(app_id),
  install_dir: get_option('datadir') / 'applications',
)

install_data(
  '@0@.metainfo.xml'.format(app_id),
  install_dir: get_option('datadir') / 'metainfo',
)

install_data(
  'icons' / 'hicolor' / 'scalable' / 'apps' / '@0@.svg'.format(app_id),
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps',
)

install_data(
  'icons' / 'hicolor' / 'symbolic' / 'apps' / '@0@-symbolic.svg'.format(app_id),
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'symbolic' / 'apps',
)

# Validate the desktop file and appstream metadata when the tools are present.
desktop_file_validate = find_program('desktop-file-validate', required: false)
if desktop_file_validate.found()
  test('validate-desktop',
    desktop_file_validate,
    args: [meson.current_source_dir() / '@0@.desktop'.format(app_id)],
  )
endif

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test('validate-metainfo',
    appstreamcli,
    args: ['validate', '--no-net', '--explain',
           meson.current_source_dir() / '@0@.metainfo.xml'.format(app_id)],
  )
endif
