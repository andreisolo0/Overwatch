module HostsHelper
    def get_actions
        @remote_actions=RemoteAction.find(@current_user.id)
    end
end