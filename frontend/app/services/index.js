//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2017 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

angular.module('openproject.services')
  .service('ActivityService', [
    '$http',
    'I18n',
    'NotificationsService',
    require('./activity-service')
  ])
  .service('GroupService', ['$http', 'PathHelper', require('./group-service')])
  .service('HookService', require('./hook-service'))
  .service('KeyboardShortcutService', [
    '$window',
    '$rootScope',
    '$timeout',
    'PathHelper',
    require('./keyboard-shortcut-service')])
  .service('PaginationService', ['DEFAULT_PAGINATION_OPTIONS', require(
    './pagination-service')])
  .service('PriorityService', ['$http', 'PathHelper', require(
    './priority-service')])
  .service('RoleService', ['$http', 'PathHelper', require('./role-service')])
  .service('SortService', require('./sort-service'))
  .service('StatusService', ['$http', 'PathHelper', require('./status-service')])
  .factory('TextileService', ['$http', 'PathHelper', require('./textile-service')])
  .service('TimezoneService', ['ConfigurationService', 'I18n', require(
    './timezone-service')])
  .service('TypeService', ['$http', 'PathHelper', require('./type-service')])
  .service('UserService', [
    '$http',
    'PathHelper',
    'CacheService',
    require('./user-service')
  ])
  .service('VersionService', ['$http', 'PathHelper', require(
    './version-service')])
  .service('CategoryService', ['$http', 'PathHelper', require(
    './category-service')])
  .service('ApiNotificationsService', [
    'NotificationsService',
    'ApiHelper',
    require('./api-notifications-service.js')
  ])
  .service('ConversionService', require('./conversion-service.js'));
