#-- encoding: UTF-8
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

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Queries
      class QueryRepresenter < ::API::Decorators::Single
        self_link

        attr_accessor :results,
                      :params

        def initialize(model,
                       current_user:,
                       results: nil,
                       embed_links: false,
                       params: {})

          self.results = results
          self.params = params

          super(model, current_user: current_user, embed_links: embed_links)
        end

        link :results do
          path = if represented.project
                   api_v3_paths.work_packages_by_project(represented.project.id)
                 else
                   api_v3_paths.work_packages
                 end

          url_query = ::API::V3::Queries::QueryParamsRepresenter
                      .new(represented)
                      .to_h
                      .merge(params.slice(:offset, :pageSize))
          {
            href: [path, url_query.to_query].join('?')
          }
        end

        links :columns do
          represented.columns.map do |column|
            {
              href: api_v3_paths.query_column(convert_attribute(column.name)),
              title: column.caption
            }
          end
        end

        link :groupBy do
          column = represented.group_by_column

          if column
            {
              href: api_v3_paths.query_group_by(convert_attribute(column.name)),
              title: column.caption
            }
          else
            {
              href: nil,
              title: nil
            }
          end
        end

        links :sortBy do
          map_with_sort_by_as_decorated do |sort_by|
            {
              href: api_v3_paths.query_sort_by(sort_by.converted_name, sort_by.direction_name),
              title: sort_by.name
            }
          end
        end

        link :schema do
          href = if represented.project
                   api_v3_paths.query_project_schema(represented.project.identifier)
                 else
                   api_v3_paths.query_schema
                 end
          {
            href: href
          }
        end

        link :update do
          href = if represented.project
                   api_v3_paths.query_project_form(represented.project.identifier)
                 else
                   api_v3_paths.query_form
                 end
          {
            href: href,
            method: :post
          }
        end

        linked_property :user
        linked_property :project

        property :id
        property :name
        property :filters,
                 exec_context: :decorator,
                 getter: ->(*) {
                   represented.filters.map do |filter|
                     ::API::V3::Queries::Filters::QueryFilterInstanceRepresenter.new(filter)
                   end
                 }
        property :public, getter: -> (*) { is_public }

        property :sort_by,
                 exec_context: :decorator,
                 getter: ->(*) {
                   return unless represented.sort_criteria

                   map_with_sort_by_as_decorated do |sort_by|
                     ::API::V3::Queries::SortBys::QuerySortByRepresenter.new(sort_by)
                   end
                 },
                 embedded: true,
                 if: ->(*) {
                   embed_links
                 }

        property :display_sums,
                 as: :sums

        property :starred

        property :columns,
                 exec_context: :decorator,
                 getter: ->(*) {
                   represented.columns.map do |column|
                     ::API::V3::Queries::Columns::QueryColumnRepresenter.new(column)
                   end
                 },
                 embedded: true,
                 if: ->(*) {
                   embed_links
                 }

        property :group_by,
                 exec_context: :decorator,
                 getter: ->(*) {
                   return unless represented.grouped?

                   column = represented.group_by_column

                   ::API::V3::Queries::GroupBys::QueryGroupByRepresenter.new(column)
                 },
                 embedded: true,
                 if: ->(*) {
                   embed_links
                 },
                 render_nil: true

        property :results,
                 exec_context: :decorator,
                 render_nil: true,
                 embedded: true,
                 if: ->(*) {
                   results
                 }

        self.to_eager_load = [:query_menu_item,
                              project: { work_package_custom_fields: :translations }]

        private

        def convert_attribute(attribute)
          ::API::Utilities::PropertyNameConverter.from_ar_name(attribute)
        end

        def map_with_sort_by_as_decorated
          represented.sort_criteria.map do |attribute, order|
            decorated = ::API::V3::Queries::SortBys::SortByDecorator.new(attribute,
                                                                         order)

            yield decorated
          end
        end

        def _type
          'Query'
        end

        def self_v3_path(*_args)
          if represented.new_record? && represented.project
            api_v3_paths.query_project_default(represented.project.id)
          elsif represented.new_record?
            api_v3_paths.query_default
          else
            super
          end
        end
      end
    end
  end
end
