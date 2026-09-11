config_data = configuration_data()
config_data.set_quoted('APP_ID', app_id)
config_data.set_quoted('APP_NAME', 'Flash Cards')
config_data.set_quoted('VERSION', meson.project_version())

config_vala = configure_file(
        input: 'config.vala.in',
       output: 'config.vala',
  configuration: config_data,
)

flash_card_sources = files(
  'main.vala',
  'application.vala',
  'window.vala',
  'card.vala',
  'deck.vala',
  'deck-manager.vala',
  'deck-row.vala',
  'card-row.vala',
  'test-page.vala',
)

flash_card_deps = [
  glib_dep,
  gobject_dep,
  gio_dep,
  gtk_dep,
  adwaita_dep,
  json_glib_dep,
]

executable('flash-card',
  flash_card_sources + [config_vala],
  dependencies: flash_card_deps,
  install: true,
)
