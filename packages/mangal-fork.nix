{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "mangal-fork";
  version = "a0c476cfa6eff14338f54ed660950c4349a8deff";

  src = fetchFromGitHub {
    owner = "luevano";
    repo = "mangal";
    rev = version;
    hash = "sha256-FH17+z6OZWxhcch68WvtWHZe4bE60chfqNheY3gIrgQ=";
  };

  vendorHash = "sha256-flbykyrx0+0NBNgLFQhNJA/X0U21KTOVWxAf4qaFfG4=";

  ldflags = ["-s" "-w"];

  # supress error about embedding web/ui/dist folder
  preBuild = ''
    mkdir -p web/ui/dist
    echo "mangal web ui :)" > web/ui/dist/index.html
  '';

  doCheck = false; # test fail because of sandbox

  meta = with lib; {
    homepage = "https://github.com/luevano/mangal";
    description = "Mangal fork. 📖 Advanced CLI manga downloader. Lua scrapers, export formats, anilist integration, fancy TUI and more.";
    license = licenses.mit;
    mainProgram = "mangal";
  };
}
