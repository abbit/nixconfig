{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "mangal-fork";
  version = "2723f39d1bf5c89fa8a9abd4ddff742d0ae61284";

  src = fetchFromGitHub {
    owner = "luevano";
    repo = "mangal";
    rev = version;
    hash = "sha256-2qbflNWdPw9NTzmEOOCGAr6LpuIvxnKKic+noHS5jxY=";
  };

  vendorHash = "sha256-LWtbw/Nf3fU1MPSuHcFDtgbHnqNUlxwjqbTpQ27q7pM=";

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
