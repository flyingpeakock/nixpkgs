{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
  qbit_manage,
  nixosTests,
}:
python3Packages.buildPythonApplication rec {
  pname = "qbit_manage";
  version = "4.6.5";

  src = fetchFromGitHub {
    owner = "flyingpeakock";
    repo = "qbit_manage";
    hash = "sha256-+tSbPedhdNLyo06l4hxqbaeszCFJ34bnE+Y7ThPDYmA=";
    # tag = "v${version}";
    rev = "5e3025c83c654a2d500ddd490005fd89f4c001f7";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];
  # pythonRelaxDeps is not relaxing ruamel-yaml version constraint, disable completely instead
  # dontCheckRuntimeDeps = true;
  pythonRelaxDeps = [
    "fastapi"
    "gitpython"
    "humanize"
    "ruamel.yaml"
    "uvicorn"
  ];

  dependencies = with python3Packages; [
    argon2-cffi
    bencode-py
    croniter
    fastapi
    gitpython
    humanize
    pytimeparse2
    qbittorrent-api
    requests
    retrying
    ruamel-yaml
    slowapi
    uvicorn
  ];

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      version =
        runCommand "qbit_manage-test-version"
          {
            buildInputs = [ qbit_manage ];
          }
          ''
            export HOME=$TMPDIR # Needed since qbit-manage creates config files in home dir
            outver="$(qbit-manage --version)"
            echo "$outver" | grep -q "${version}" \
              || (echo "Version mismatch: $outver" >&2; exit 1)
            touch $out
          '';

      testService = nixosTests.qbit_manage;
    };
  };

  meta = {
    description = "This tool will help manage tedious tasks in qBittorrent and automate them";
    homepage = "https://github.com/StuffAnThings/qbit_manage";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flyingpeakock ];
    platforms = lib.platforms.all;
    mainProgram = "qbit-manage";
  };
}
