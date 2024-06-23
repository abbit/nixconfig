{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "mangal-fork";
  version = "v5.9.1";

  src = fetchFromGitHub {
    owner = "luevano";
    repo = "mangal";
    rev = version;
    hash = "sha256-hE4fjGimarlrTtt3mz2TwFnU8FREhoNlzh4wLN/vv1U=";
  };

  vendorHash = "sha256-+rYrzcTEgwoOpv1XtM2UD8IaqA2xh9QmVAO755UG8Lc=";

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
