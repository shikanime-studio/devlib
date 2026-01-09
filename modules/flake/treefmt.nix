{ localSelf' }: _:

{
  treefmt.config.programs.prettier.settings.pluginSearchDirs = [
    "${localSelf'.packages.prettier-plugin-astro}/lib"
    "${localSelf'.packages.prettier-plugin-tailwindcss}/lib"
  ];
}
