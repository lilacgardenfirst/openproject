//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
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

import {wpControllersModule} from '../../../angular-modules';
import {States} from '../../states.service';

function ShareModalController(this:any,
                              $scope:any,
                              shareModal:any,
                              states:States,
                              AuthorisationService:any,
                              NotificationsService:any) {
  this.name = 'Share';
  this.closeMe = shareModal.deactivate;

  $scope.query = states.table.query.getCurrentValue()

  $scope.shareSettings = {
    starred: !!$scope.query.unstar
  };

  function closeAndReport(message:any) {
    shareModal.deactivate();
    NotificationsService.addSuccess(message.text);
  }

  $scope.cannot = AuthorisationService.cannot;

//  $scope.saveQuery = () => {
//    var messageObject:any;
//
//    QueryService.saveQuery()
//      .then((data:any) => {
//        messageObject = data.status;
//        if (data.query) {
//          AuthorisationService.initModelAuth('query', data.query._links);
//        }
//
//        if ($scope.query.starred !== $scope.shareSettings.starred) {
//          QueryService.toggleQueryStarred($scope.query)
//            .then((data:any) => {
//              closeAndReport(data.status || messageObject);
//              return $scope.query;
//            });
//        }
//        else {
//          closeAndReport(messageObject);
//        }
//      });
//  };
}

wpControllersModule.controller('ShareModalController', ShareModalController);
