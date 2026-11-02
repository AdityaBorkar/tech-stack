{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";
  home.file = {
    ".aws/config".source = ./files/.aws/config;
    ".docker/config.json".source = ./files/.docker/config.json;
    ".config/htop/htoprc".source = ./files/.config/htop/htoprc;
    ".ssh/known_hosts".source = ./files/.ssh/known_hosts;
    ".config/opencode/AGENTS.md".source = ./files/.config/opencode/AGENTS.md;
    ".config/opencode/agents/ask.md".source = ./files/.config/opencode/agents/ask.md;
    ".config/opencode/agents/codebase-memory.md".source = ./files/.config/opencode/agents/codebase-memory.md;
    ".config/opencode/agents/codebase-memory-auditor.md".source = ./files/.config/opencode/agents/codebase-memory-auditor.md;
    ".config/opencode/agents/codebase-memory-scout.md".source = ./files/.config/opencode/agents/codebase-memory-scout.md;
    ".config/opencode/cli.json".source = ./files/.config/opencode/cli.json;
    ".config/opencode/commands/improve-comments.md".source = ./files/.config/opencode/commands/improve-comments.md;
    ".config/opencode/commands/recommend-packages.md".source = ./files/.config/opencode/commands/recommend-packages.md;
    ".config/opencode/commands/recommend-tools.md".source = ./files/.config/opencode/commands/recommend-tools.md;
    ".config/opencode/plugins/cbm-augment.ts".source = ./files/.config/opencode/plugins/cbm-augment.ts;
    ".config/opencode/plugins/rtk.ts".source = ./files/.config/opencode/plugins/rtk.ts;
    ".config/opencode/skills/codebase-memory/SKILL.md".source = ./files/.config/opencode/skills/codebase-memory/SKILL.md;
    ".config/opencode/skills/use-docucraft/SKILL.md".source = ./files/.config/opencode/skills/use-docucraft/SKILL.md;
    ".config/Code/User/settings.json".source = ./files/.config/Code/User/settings.json;
    ".config/zed/settings.json".source = ./files/.config/zed/settings.json;
  };
}
