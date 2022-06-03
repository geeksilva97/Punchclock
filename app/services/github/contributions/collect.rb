# frozen_string_literal: true

module Github
  module Contributions
    class Collect
      Result = Struct.new(:uid, :rid, :pull_request)

      def initialize(company:, client:)
        @company = company
        @client = client
      end

      def all
        return [] if company.blank?
        repo_regex = /https?\:\/\/github.com\//

        repository_links = Set.new()
        repository_id_by_link = {}

        company.repositories.each do |repository|
          repository_base_url = repository.link.gsub(repo_regex, "")

          repository_links.add( repository_base_url )
          repository_id_by_link[repository_base_url] = repository.id
        end

        test_users = Set.new ['geeksilva97', 'joaoGabriel55', 'wenderjean']
        # current_date = Time.now.strftime("%Y-%m-%d")
        current_date = '2022-04-29'
        pull_requests = []

        engineers.select { | e | test_users.member? e.github }.each do |engineer|
        # engineers.each do |engineer|
          found_prs = client.search.issues(q: "author:#{engineer.github} is:pr created:#{current_date}")
          pull_requests.concat( found_prs.items )
        end
        
        pull_requests.select do |pr|
          partial_url = pr.html_url.gsub(repo_regex, '').split('/').slice(0,2).join('/')
          repository_links.member? partial_url
        end.map do |pull_request|
          partial_url = pull_request.html_url.gsub(repo_regex, '').split('/').slice(0,2).join('/')
          Result.new(3, repository_id_by_link[partial_url], pull_request)
        end

        # repositories.flat_map do |repository_id, repository_owner, repository_name|
        #   client.pull_requests
        #         .list(repository_owner, repository_name)
        #         .map do |pull_request|
        #           uuid, = engineers.select { |_, username| username ==  pull_request.user.login }
        #                            .flatten

        #           Result.new(uuid, repository_id, pull_request) if uuid.present?
        #         end.compact
        # end
      end

      private

      attr_reader :company, :client

      def engineers
        @engineers ||= company.users.engineer.active
      end

      # def engineers
      #   @engineers ||= company.users
      #                         .engineer
      #                         .active
      #                         .pluck(:id, :github)
      # end

      def repositories_set
        Set.new rep
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
