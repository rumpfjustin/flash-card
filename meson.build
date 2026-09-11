project('flash-card', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.62.0',
  default_options: ['warning_level=2', 'werror=false'],
)

app_id = 'io.github.rumpfjustin.FlashCard'

glib_dep      = dependency('glib-2.0', version: '>= 2.66')
gobject_dep   = dependency('gobject-2.0')
gio_dep       = dependency('gio-2.0')
gtk_dep       = dependency('gtk4', version: '>= 4.10')
adwaita_dep   = dependency('libadwaita-1', version: '>= 1.5')
json_glib_dep = dependency('json-glib-1.0', version: '>= 1.6')

# Generated Vala/C code trips a lot of harmless warnings; keep the build quiet.
add_project_arguments('-w', language: 'c')

gnome = import('gnome')

subdir('src')
subdir('data')

gnome.post_install(
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
