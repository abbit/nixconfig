{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "mangal-fork";
  version = "c344e3c34a00a0bebe8de3223170b69800648985";

  src = fetchFromGitHub {
    owner = "luevano";
    repo = "mangal";
    rev = version;
    hash = "sha256-4D6VZP7afMvItR4ElHG6+jUS9v8DLMsEaItX55N9cP0=";
  };

  vendorHash = "sha256-nwWjtg7nJJm8NMjqQcZP1ZsqYjIakxp1Vs79w+aKtFI=";

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
