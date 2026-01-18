{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.license;
in
{
  options.license = {
    enable = mkEnableOption "license generation";

    package = mkOption {
      type = types.functionTo types.package;
      default = license.generate;
      description = "License generator function.";
    };

    lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
    };

    holder = mkOption {
      type = types.str;
      description = "Copyright holder.";
    };

    year = mkOption {
      type = types.str;
      description = "Override year; null lets the generator use the current year.";
    };

    description = mkOption {
      type = types.str;
      description = "Project description to use in the license text (unused for some licenses).";
    };
  };

  config = mkIf cfg.enable {
    license.lib.pkgs = {
      agpl3Only =
        let
          template = builtins.fetchurl {
            url = "https://www.gnu.org/licenses/agpl-3.0.txt";
            sha256 = "1c5wk83xn43pma39yf6xm0mr312iinqi7xrh3xplnvddd3zs95hd";
          };
        in
        {
          year,
          holder,
          description,
        }:
        pkgs.runCommand "LICENSE" { inherit year holder description; } ''
          ${pkgs.gnused}/bin/sed \
            -e "s/<one line to give the program's name and a brief idea of what it does.>/$description/g" \
            -e "s/<year>/$year/g" \
            -e "s/<name of author>/$holder/g" \
            ${template} > $out
        '';

      asl20 =
        let
          template = builtins.fetchurl {
            url = "https://www.apache.org/licenses/LICENSE-2.0.txt";
            sha256 = "0c1xaay1fd00xgri0z447q2i8s3mpxqw9da27hfd6fznjsdp9iyg";
          };
        in
        { year, holder, ... }:
        pkgs.runCommand "LICENSE" { inherit year holder; } ''
          ${pkgs.gnused}/bin/sed \
            -e "s/\[yyyy\]/$year/g" \
            -e "s/\[name of copyright owner\]/$holder/g" \
            ${template} > $out
        '';

      mit =
        let
          template = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/github/choosealicense.com/gh-pages/_licenses/mit.txt";
            sha256 = "1f7m7v5af7pk46m7q2qi3xp51x6hjvclh44dj47k1cxc7jqrv4g6";
          };
        in
        { year, holder, ... }:
        pkgs.runCommand "LICENSE" { inherit year holder; } ''
          ${pkgs.gnused}/bin/sed \
            -e '/^---$/,/^---$/d' \
            -e "s/\[year\]/$year/g" \
            -e "s/\[fullname\]/$holder/g" \
            ${template} > $out
        '';
    };

    tasks."devlib:license:install" = {
      before = [ "devenv:enterShell" ];
      description = "Install LICENSE file";
      exec = ''
        ${pkgs.coreutils}/bin/cat ${cfg.package { inherit (cfg) year holder description; }} > LICENSE
      '';
    };
  };
}
