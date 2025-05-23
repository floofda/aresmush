$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Manage
    def self.plugin_dir
      File.dirname(__FILE__)
    end
 
    def self.shortcuts
      Global.read_config("manage", "shortcuts")
    end
 
    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "alias"
        return AliasCmd
      when "announce"
        return AnnounceCmd
      when "block"
        case cmd.switch
        when "add"
          return BlockCmd
        when "remove"
          return BlockCmd
        else
          return BlocksListCmd
        end
      when "db"
        case cmd.switch
        when "backup"
          return BackupCmd
        when "save"
          return DbSaveCmd
        end
      when "config"
        case cmd.switch
        when "check"
          return ConfigCheckCmd
        when "cron"
          return ConfigCronCmd
        when "restore"
          return ConfigRestoreCmd
        when nil
          if (cmd.args)
            return ConfigViewCmd
          else
            return ConfigListCmd
          end
        end
      when "debuglog"
        return DebugLogCmd
      when "server"
        return ServerInfoCmd
      when "destroy"
        case cmd.switch
        when "confirm"
          return DestroyConfirmCmd
        when nil
          return DestroyCmd
        end
      when "examine"
        return ExamineCmd
      when "find"
        return FindCmd
      when "findsite"
        if (cmd.args)
          return FindsiteCmd
        else
          return FindsiteAllCmd
        end
      when "git"
        case cmd.switch
        when "load"
          return LoadGitCmd
        else
          return GitCmd
        end
      when "load"
        case cmd.args
        when "config"
          return LoadConfigCmd
        when "locale"
          return LoadLocaleCmd
        when "all"
          return LoadAllCmd
        when "styles"
          return LoadStylesCmd
        else
          return LoadPluginCmd
        end
      when "migrate"
        return MigrateCmd
      when "plugins"
        return PluginListCmd
      when "plugin"
        case cmd.switch
        when "install"
          return PluginInstallCmd
        end
      when "rename"
        return RenameCmd
      when "ruby"
        return RubyCmd
      when "shutdown"
        return ShutdownCmd
      when "statue", "unstatue"
        return StatueCmd
      when "theme"
        return ThemeInstallCmd
      when "upgrade"
        case cmd.switch
        when "finish"
          return UpgradeFinishCmd
        when "start", nil
          return UpgradeStartCmd
        end
      when "version"
        return VersionCmd
      end
      
      nil
    end

    def self.get_event_handler(event_name) 
      case event_name
      when "CronEvent"
        return CronEventHandler
      end
      nil
    end
    
    def self.get_web_request_handler(request)
      case request.cmd
      when "restoreConfig"
        return RestoreConfigRequestHandler
      when "upgrade"
        return UpgradeRequestHandler
      when "serverStats"
        return ServerStatsRequestHandler
      when "blockList"
        return BlockListRequestHandler
      when "addBlock"
        return AddBlockRequestHandler
      when "removeBlock"
        return RemoveBlockRequestHandler
      end
    end
  end
end
