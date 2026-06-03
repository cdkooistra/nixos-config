{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;
    defaultEditor = true;
    extensions = [
      "nix"
    ];

    # the idea with mutableUser* is to allow user to override settings without needing to edit this file.
    mutableUserKeymaps = true;
    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-alt-`" = "workspace::NewTerminal";
        };
        unbind = {
          "ctrl-~" = "workspace::NewTerminal";
        };
      }
      {
        context = "!AcpThread > Editor && mode == full";
        unbind = {
          "ctrl-enter" = "assistant::InlineAssist";
        };
      }
      {
        context = "AcpThread > Editor && use_modifier_to_send";
        unbind = {
          "ctrl-enter" = "agent::Chat";
        };
      }
      {
        context = "AcpThread > Editor";
        unbind = {
          "ctrl-enter" = "agent::ChatWithFollow";
        };
      }
      {
        context = "Editor && !edit_prediction";
        bindings = {
          "ctrl-alt-\\" = "editor::ShowEditPrediction";
        };
      }
      {
        context = "Editor && !edit_prediction";
        unbind = {
          "alt-\\" = "editor::ShowEditPrediction";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-\\" = [
            "workspace::MoveItemToPaneInDirection"
            { direction = "right"; }
          ];
        };
      }
      {
        context = "Editor";
        bindings = {
          "alt-\\" = [
            "workspace::MoveItemToPaneInDirection"
            { direction = "left"; }
          ];
        };
      }
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-g" = "git_panel::Toggle";
        };
      }
      {
        context = "Workspace";
        unbind = {
          "ctrl-shift-b" = "outline_panel::ToggleFocus";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-b" = "workspace::ToggleRightDock";
        };
        unbind = {
          "ctrl-alt-b" = "workspace::ToggleRightDock";
        };
      }
      {
        bindings = {
          "ctrl-~" = "workspace::ToggleZoom";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-shift-up" = "editor::AddSelectionAbove";
        };
        unbind = {
          "alt-shift-up" = "editor::AddSelectionAbove";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-shift-down" = "editor::AddSelectionBelow";
        };
        unbind = {
          "alt-shift-down" = "editor::AddSelectionBelow";
        };
      }
    ];

    mutableUserSettings = true;
    userSettings = {
      cli_default_open_behavior = "new_window";
      edit_predictions = {
        mode = "eager";
        provider = "zed";
      };
      project_panel = {
        dock = "left";
      };
      outline_panel = {
        button = false;
        dock = "left";
      };
      collaboration_panel = {
        dock = "left";
      };
      agent = {
        dock = "right";
        favorite_models = [ ];
        model_parameters = [ ];
      };
      git_panel = {
        dock = "right";
      };
      session = {
        trust_all_worktrees = true;
      };
      terminal = {
        font_size = 18.0;
      };
      base_keymap = "VSCode";
      soft_wrap = "editor_width";
      ui_font_size = 16;
      buffer_font_size = 15;
      theme = {
        mode = "system";
        light = "Ayu Light";
        dark = "Ayu Dark";
      };
      format_on_save = "on";
      languages = {
        "Markdown" = {
          show_edit_predictions = false;
        };
        "YAML" = {
          tab_size = 2;
          show_edit_predictions = false;
        };
        "Nix" = {
          language_servers = [
            "nixd"
            "!nil"
          ];
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
        };
      };
    };
  };
}
