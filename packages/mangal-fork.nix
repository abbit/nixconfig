{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:
buildGoModule rec {
  pname = "mangal";
  version = "main";

  src = fetchFromGitHub {
    owner = "luevano";
    repo = "${pname}";
    rev = "c344e3c34a00a0bebe8de3223170b69800648985";
    hash = "sha256-4D6VZP7afMvItR4ElHG6+jUS9v8DLMsEaItX55N9cP0=";
  };

  vendorHash = "sha256-nwWjtg7nJJm8NMjqQcZP1ZsqYjIakxp1Vs79w+aKtFI=";

  ldflags = ["-s" "-w"];

  nativeBuildInputs = [installShellFiles];

  preBuild = ''
    mkdir -p web/ui/dist
    echo "mangal web ui :)" > web/ui/dist/index.html
  '';

  postInstall = lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    # Mangal creates a config file in the folder ~/.config/mangal and fails if not possible
    export MANGAL_CONFIG_PATH=`mktemp -d`
    installShellCompletion --cmd mangal \
      --fish <($out/bin/mangal completion fish)
  '';

  doCheck = false; # test fail because of sandbox

  meta = with lib; {
    homepage = "https://github.com/luevano/mangal";
    description = "Mangal fork. 📖 Advanced CLI manga downloader. Lua scrapers, export formats, anilist integration, fancy TUI and more.";
    license = licenses.mit;
    mainProgram = "mangal";
  };
}
