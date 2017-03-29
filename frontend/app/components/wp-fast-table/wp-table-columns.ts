// -- copyright
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
// ++

import {QueryColumn} from '../api/api-v3/hal-resources/query-resource.service'
import {QueryResource} from '../api/api-v3/hal-resources/query-resource.service'
import {QuerySchemaResourceInterface} from '../api/api-v3/hal-resources/query-schema-resource.service'
import {Observable} from 'rxjs/Observable';

export class WorkPackageTableColumns {

  // Available columns
  public available:QueryColumn[]|undefined;

  // The selected columns state of the current table instance
  public current:QueryColumn[];

  constructor(query:QueryResource, schema?:QuerySchemaResourceInterface) {
    this.update(query, schema);
    //this.current = angular.copy(query.columns);

    //if (schema) {
    //  this.available = angular.copy(schema.columns.allowedValues as QueryColumn[]);
    //}
  }

  public update(query:QueryResource|null, schema?:QuerySchemaResourceInterface) {
    if (query) {
      this.current = angular.copy(query.columns);
    }

    if (schema) {
      this.available = angular.copy(schema.columns.allowedValues as QueryColumn[]);
    }
  }

  /**
   * Retrieve the QueryColumn objects for the selected columns
   */
  public getColumns():any[] {
    return this.current;
  }

  ///**
  // * Return the index of the given column or -1 if it is not contained.
  // */
  //public index(id:string):number {
  //  return _.findIndex(this.current, column => column.id === id);
  //}
}
