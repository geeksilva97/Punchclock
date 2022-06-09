# frozen_string_literal: true

module Github
  module Contributions
    class Collect
      Result = Struct.new(:uid, :rid, :pull_request)

      def initialize(company:, client:)
        @company = company
        @client = client
        @repository_id_by_name = {}
        @user_id_by_github = {}
      end

      def repositories_query
        repositories.map do |repository_id, repository_owner, repository_name|
          @repository_id_by_name["#{repository_owner}/#{repository_name}"] = repository_id
          "repo:#{repository_owner}/#{repository_name}"
        end.join(' ')
      end

      def authors_query
        engineers.map do |user_id, github_user|
          @user_id_by_github[github_user] = user_id
          "author:#{github_user}"
        end.join(' ')
      end

      def search_query
        yesterday_date = 1.day.ago.strftime("%Y-%m-%d")
        "created:#{yesterday_date} is:pr #{authors_query} #{repositories_query}"
      end

      def all
        return [] if company.blank? or repositories.empty? or engineers.empty?

        client.search.issues(q: search_query).items.map do | pull_request |
          repository_key = pull_request.html_url.split('/')[-2..-1].join('/')
          user_key = pull_request.user.login

          Result.new(@user_id_by_github[ user_key ], @repository_id_by_name[ repository_key ], pull_request)
        end
      end

      private

      attr_reader :company, :client

      def engineers
        @engineers ||= company.users
                              .engineer
                              .active
                              .pluck(:id, :github)
      end

      def repositories
        @repositories ||= company.repositories
                                 .pluck(:id, :link)
                                 .map { |id, url| [id, url.split('/')[-2..-1]].flatten }
                                 .compact
      end
    end
  end
end
