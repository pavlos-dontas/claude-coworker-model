{
  description = "Claude coworker model with OpenRouter";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    pythonEnv = pkgs.python312.withPackages (ps: [
      ps.openai
    ]);
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pythonEnv
        pkgs.git
      ];

      shellHook = ''
        export PATH="$PWD/tools:$PATH"

        # Worker model through OpenRouter
        export WORKER_BASE_URL="https://openrouter.ai/api/v1"
        export WORKER_MODEL="deepseek/deepseek-chat-v3.1"

        echo "Set WORKER_API_KEY before use:"
        echo "  export WORKER_API_KEY=sk-or-..."
      '';
    };
  };
}
