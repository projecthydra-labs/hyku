module Hyku
  module Admin
    module Group
      class NavigationPresenter

        def initialize(params:)
          @params = params
          @group_id = params.fetch(group_id_key)
        end

        def tabs
          [
            Tab.new({
              name: I18n.t('hyku.admin.groups.nav.attributes'),
              controller: 'admin/groups',
              action: 'edit',
              path: Rails.application.routes.url_helpers.edit_admin_group_path(group_id),
              context: params
            }),
            Tab.new({
              name: I18n.t('hyku.admin.groups.nav.members'),
              controller: 'admin/group_users',
              action: 'index',
              path: Rails.application.routes.url_helpers.admin_group_users_path(group_id),
              context: params
            }),
            Tab.new({
              name: I18n.t('hyku.admin.groups.nav.delete'),
              controller: 'admin/groups',
              action: 'remove',
              path: Rails.application.routes.url_helpers.remove_admin_group_path(group_id),
              context: params
            })
          ]
        end

        private
          attr_reader :group_id, :params

          def group_id_key
            return :id if params.has_key?(:id)
            return :group_id if params.has_key?(:group_id)
            :key_not_found
          end

        class Tab
          attr_reader :name, :path

          def initialize(name:, controller:, action:, path:, context:)
            @name = name
            @controller = controller
            @action = action
            @path = path
            @context = context
          end

          def css_class
            return 'active' if context.fetch(:controller) == controller && context.fetch(:action) == action
            ''
          end

          private

            attr_reader :controller, :action, :context
        end
      end
    end
  end
end