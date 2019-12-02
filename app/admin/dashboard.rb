# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do

  menu priority: 0, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    panel t('search_fields', scope: 'active_admin'), class: 'search-fields' do
      current_company = current_user.company

      users_collection = current_company.users.active.includes(:office).order(:name).map do |user|
        user_label = "#{user.name.titleize} - #{user.email} - "
        user_label += "#{user.level.humanize} - " if user.engineer?
        user_label += "#{user.office} - #{user.current_allocation.presence || 'Não Alocado'}"

        [user_label, user.id]
      end

      offices_collection = current_company.offices.order(:city).decorate.map do |office|
        [
          "#{office.city.titleize} - #{office.head} - #{office.score}",
          office.id
        ]
      end


      projects_collection = current_company.projects.active.order(:name).map do |project|
        [
          "#{project.name} #{project.client ? " - #{project.client}": '' }",
          project.id
        ]
      end
      tabs do
        tab User.model_name.human do
          render "search_field", search_model: User, url_path: admin_users_path, collection: users_collection
        end

        tab Office.model_name.human do
          render "search_field", search_model: Office, url_path: admin_offices_path, collection: offices_collection
        end

        tab Project.model_name.human do
          render "search_field", search_model: Project, url_path: admin_projects_path, collection: projects_collection
        end
      end
    end

    columns do
      column do
        panel t(I18n.t('average_score'), scope: 'active_admin'), class: 'average-score' do
          table_for User.level.values do
            column(I18n.t('level'), &:humanize)
            column(I18n.t('users_average')) { |level| User.with_level(level).overall_score_average }
          end
        end
      end
      
      column do
        panel t(I18n.t('offices_leaderboard'), scope: 'active_admin') do
          collection = current_user.super_admin? ? ContributionsByOfficeQuery.new : ContributionsByOfficeQuery.new(Office.where(company: current_user.company))
          table_for collection.leaderboard.this_week.approved.to_relation do
            column(Office.human_attribute_name(:city)) { |office| office.city }
            column(I18n.t('this_week_contributions')) { |office| office.number_of_contributions }
            column(I18n.t('last_week_contributions')) { |office| ContributionsByOfficeQuery
                                                                                          .new(Office.where(city: office.city))
                                                                                          .n_weeks_ago(1)
                                                                                          .approved
                                                                                          .to_relation
                                                                                          .first
                                                                                          .number_of_contributions }
          end
        end
                                                                                          
        panel t(I18n.t('contribution_status'), scope: 'active_admin'), class: 'average-score' do
          table_for Contribution.aasm.states.map(&:name) do
            column('status') { |state| I18n.t(state) }
            column(I18n.t('amount')) { |state| Contribution.where("state = ?", state).count }
          end
        end
      end
    end
  end
end
