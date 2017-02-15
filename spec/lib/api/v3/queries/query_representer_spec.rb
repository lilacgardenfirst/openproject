#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe ::API::V3::Queries::QueryRepresenter do
  include ::API::V3::Utilities::PathHelper

  let(:query) { FactoryGirl.build_stubbed(:query, project: project) }
  let(:project) { FactoryGirl.build_stubbed(:project) }
  let(:representer) do
    described_class.new(query, current_user: double('current_user'), embed_links: true)
  end

  subject { representer.to_json }

  describe 'generation' do
    describe '_links' do
      it_behaves_like 'has a titled link' do
        let(:link) { 'self' }
        let(:href) { api_v3_paths.query query.id }
        let(:title) { query.name }
      end

      it_behaves_like 'has a titled link' do
        let(:link) { 'user' }
        let(:href) { api_v3_paths.user query.user_id }
        let(:title) { query.user.name }
      end

      it_behaves_like 'has a titled link' do
        let(:link) { 'project' }
        let(:href) { api_v3_paths.project query.project_id }
        let(:title) { query.project.name }
      end

      it_behaves_like 'has an untitled link' do
        let(:link) { 'results' }
        let(:href) do
          params = {
            offset: 1,
            pageSize: Setting.per_page_options_array.first
          }
          "#{api_v3_paths.work_packages_by_project(project.id)}?#{params.to_query}"
        end
      end

      it_behaves_like 'has an untitled link' do
        let(:link) { 'schema' }
        let(:href) { api_v3_paths.query_project_schema(project.identifier) }
      end

      it_behaves_like 'has an untitled link' do
        let(:link) { 'update' }
        let(:href) { api_v3_paths.query_project_form(project.identifier) }
      end

      context 'has no project' do
        let(:query) { FactoryGirl.build_stubbed(:query, project: nil) }

        it_behaves_like 'has an empty link' do
          let(:link) { 'project' }
        end

        it_behaves_like 'has an untitled link' do
          let(:link) { 'schema' }
          let(:href) { api_v3_paths.query_schema }
        end

        it_behaves_like 'has an untitled link' do
          let(:link) { 'update' }
          let(:href) { api_v3_paths.query_form }
        end

        it_behaves_like 'has an untitled link' do
          let(:link) { 'results' }
          let(:href) do
            params = {
              offset: 1,
              pageSize: Setting.per_page_options_array.first
            }
            "#{api_v3_paths.work_packages}?#{params.to_query}"
          end
        end
      end

      context 'with filter, sort, group by and pageSize' do
        let(:representer) do
          described_class.new(query,
                              current_user: double('current_user'))
        end

        let(:query) do
          query = FactoryGirl.build_stubbed(:query, project: project)
          query.add_filter('subject', '~', ['bogus'])
          query.group_by = 'author'
          query.sort_criteria = [['assigned_to', 'asc'], ['type', 'desc']]

          query
        end

        let(:expected_href) do
          params = {
            offset: 1,
            pageSize: Setting.per_page_options_array.first,
            filters: JSON::dump([{ subject: { operator: '~', values: ['bogus'] } }]),
            groupBy: 'author',
            sortBy: JSON::dump([['assignee', 'asc'], ['type', 'desc']])
          }

          api_v3_paths.work_packages_by_project(project.id) + "?#{params.to_query}"
        end

        it_behaves_like 'has an untitled link' do
          let(:link) { 'results' }
          let(:href) { expected_href }
        end
      end

      context 'with offset and page size' do
        let(:representer) do
          described_class.new(query,
                              current_user: double('current_user'),
                              params: { offset: 2, pageSize: 25 })
        end

        let(:expected_href) do
          params = {
            offset: 2,
            pageSize: 25
          }

          api_v3_paths.work_packages_by_project(project.id) + "?#{params.to_query}"
        end

        it_behaves_like 'has an untitled link' do
          let(:link) { 'results' }
          let(:href) { expected_href }
        end
      end

      context 'without columns' do
        let(:query) do
          query = FactoryGirl.build_stubbed(:query, project: project)

          # need to write bogus here because the query
          # will otherwise sport the default columns
          query.column_names = ['blubs']

          query
        end

        it 'has an empty columns array' do
          is_expected
            .to be_json_eql([].to_json)
            .at_path('_links/columns')
        end
      end

      context 'with columns' do
        let(:query) do
          query = FactoryGirl.build_stubbed(:query, project: project)

          query.column_names = ['status', 'assigned_to', 'updated_at']

          query
        end

        it 'has an array of columns' do
          status = {
            href: '/api/v3/queries/columns/status',
            title: 'Status'
          }
          assignee = {
            href: '/api/v3/queries/columns/assignee',
            title: 'Assignee'
          }
          subproject = {
            href: '/api/v3/queries/columns/updatedAt',
            title: 'Updated on'
          }

          expected = [status, assignee, subproject]

          is_expected
            .to be_json_eql(expected.to_json)
            .at_path('_links/columns')
        end
      end

      context 'without group_by' do
        it_behaves_like 'has a titled link' do
          let(:href) { nil }
          let(:link) { 'groupBy' }
          let(:title) { nil }
        end
      end

      context 'with group_by' do
        let(:query) do
          query = FactoryGirl.build_stubbed(:query, project: project)

          query.group_by = 'status'

          query
        end

        it_behaves_like 'has a titled link' do
          let(:href) { '/api/v3/queries/group_bys/status' }
          let(:link) { 'groupBy' }
          let(:title) { 'Status' }
        end
      end

      context 'without sort_by' do
        it 'has an empty sortBy array' do
          is_expected
            .to be_json_eql([].to_json)
            .at_path('_links/sortBy')
        end
      end

      context 'with sort_by' do
        let(:query) do
          FactoryGirl.build_stubbed(:query,
                                    sort_criteria: [['subject', 'asc'], ['assigned_to', 'desc']])
        end

        it 'has an array of sortBy' do
          expected = [
            {
              href: api_v3_paths.query_sort_by('subject', 'asc'),
              title: 'Subject (Ascending)'
            },
            {
              href: api_v3_paths.query_sort_by('assignee', 'desc'),
              title: 'Assignee (Descending)'
            }
          ]

          is_expected
            .to be_json_eql(expected.to_json)
            .at_path('_links/sortBy')
        end
      end
    end

    it 'should show an id' do
      is_expected.to be_json_eql(query.id).at_path('id')
    end

    it 'should show the query name' do
      is_expected.to be_json_eql(query.name.to_json).at_path('name')
    end

    it 'should indicate whether sums are shown' do
      is_expected.to be_json_eql(query.display_sums.to_json).at_path('sums')
    end

    it 'should indicate whether the query is publicly visible' do
      is_expected.to be_json_eql(query.is_public.to_json).at_path('public')
    end

    describe 'with filters' do
      let(:query) do
        query = FactoryGirl.build_stubbed(:query)
        query.add_filter('status_id', '=', [filter_status.id.to_s])
        allow(query.filters.last)
          .to receive(:value_objects)
          .and_return([filter_status])
        query.add_filter('assigned_to_id', '!', [filter_user.id.to_s])
        allow(query.filters.last)
          .to receive(:value_objects)
          .and_return([filter_user])
        query
      end

      let(:filter_status) { FactoryGirl.build_stubbed(:status) }
      let(:filter_user) { FactoryGirl.build_stubbed(:user) }

      it 'should render the filters' do
        expected_status = {
          "_type": "StatusQueryFilter",
          "name": "Status",
          "_links": {
            "filter": {
              "href": "/api/v3/queries/filters/status",
              "title": "Status"
            },
            "operator": {
              "href": "/api/v3/queries/operators/=",
              "title": "is"
            },
            "values": [
              {
                "href": api_v3_paths.status(filter_status.id),
                "title": filter_status.name
              }
            ],
            "schema": {
              "href": api_v3_paths.query_filter_instance_schema('status')
            }
          }
        }
        expected_assignee = {
          "_type": "AssigneeQueryFilter",
          "name": "Assignee",
          "_links": {
            "filter": {
              "href": "/api/v3/queries/filters/assignee",
              "title": "Assignee"
            },
            "operator": {
              "href": "/api/v3/queries/operators/!",
              "title": "is not"
            },
            "values": [
              {
                "href": api_v3_paths.user(filter_user.id),
                "title": filter_user.name
              }
            ],
            "schema": {
              "href": api_v3_paths.query_filter_instance_schema('assignee')
            }
          }
        }

        expected = [expected_status, expected_assignee]

        is_expected.to be_json_eql(expected.to_json).at_path('filters')
      end
    end

    describe 'with sort criteria' do
      let(:query) do
        FactoryGirl.build_stubbed(:query,
                                  sort_criteria: [['subject', 'asc'], ['assigned_to', 'desc']])
      end

      it 'has the sort criteria embedded' do
        is_expected
          .to be_json_eql('/api/v3/queries/sort_bys/subject-asc'.to_json)
          .at_path('_embedded/sortBy/0/_links/self/href')

        is_expected
          .to be_json_eql('/api/v3/queries/sort_bys/assignee-desc'.to_json)
          .at_path('_embedded/sortBy/1/_links/self/href')
      end
    end

    describe 'with columns' do
      let(:query) do
        query = FactoryGirl.build_stubbed(:query, project: project)

        query.column_names = ['status', 'assigned_to', 'updated_at']

        query
      end

      it 'has the columns embedded' do
        is_expected
          .to be_json_eql('/api/v3/queries/columns/status'.to_json)
          .at_path('_embedded/columns/0/_links/self/href')
      end

      context 'when not embedding' do
        let(:representer) do
          described_class.new(query, current_user: double('current_user'), embed_links: false)
        end

        it 'has no columns embedded' do
          is_expected
            .not_to have_json_path('_embedded/columns')
        end
      end
    end

    describe 'with group by' do
      let(:query) do
        query = FactoryGirl.build_stubbed(:query, project: project)

        query.group_by = 'status'

        query
      end

      it 'has the group by embedded' do
        is_expected
          .to be_json_eql('/api/v3/queries/group_bys/status'.to_json)
          .at_path('_embedded/groupBy/_links/self/href')
      end

      context 'when not embedding' do
        let(:representer) do
          described_class.new(query, current_user: double('current_user'), embed_links: false)
        end

        it 'has no group bys embedded' do
          is_expected
            .not_to have_json_path('_embedded/groupBy')
        end
      end
    end

    describe 'embedded results' do
      let(:query) { FactoryGirl.build_stubbed(:query) }
      let(:representer) do
        described_class.new(query,
                            current_user: double('current_user'),
                            results: results_representer)
      end

      context 'results are provided' do
        let(:results_representer) do
          {
            _type: 'BogusResultType'
          }
        end

        it 'should embed the results' do
          is_expected
            .to be_json_eql('BogusResultType'.to_json)
            .at_path('_embedded/results/_type')
        end
      end

      context 'no results provided' do
        let(:results_representer) { nil }

        it 'should not embed the results' do
          is_expected
            .not_to have_json_path('_embedded/results')
        end
      end
    end
  end
end
