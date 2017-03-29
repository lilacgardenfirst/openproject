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

import {QueryResource} from '../../api/api-v3/hal-resources/query-resource.service';
import {QuerySchemaResourceInterface} from '../../api/api-v3/hal-resources/query-schema-resource.service';
import {QueryFilterResource} from '../../api/api-v3/hal-resources/query-filter-resource.service';
import {
  QueryFilterInstanceResource,
} from '../../api/api-v3/hal-resources/query-filter-instance-resource.service';
import {CollectionResource} from '../../api/api-v3/hal-resources/collection-resource.service';
import {opServicesModule} from '../../../angular-modules';
import {States} from '../../states.service';
import {State} from '../../../helpers/reactive-fassade';
import {WorkPackageTableFilters} from '../wp-table-filters';

export class WorkPackageTableFiltersService {
  private state:State<WorkPackageTableFilters>;

  constructor(public states: States,
              private $q: ng.IQService) {
    "ngInject";
    this.state = states.table.filters;
  }

  public initialize(query:QueryResource, schema:QuerySchemaResourceInterface) {
    let filters = _.cloneDeep(query.filters);

    this.loadCurrentFiltersSchemas(filters).then(() => {
      let newState = new WorkPackageTableFilters(filters, schema);

      this.state.put(newState);
    });
  }

  public get currentState():WorkPackageTableFilters {
    return this.state.getCurrentValue() as WorkPackageTableFilters;
  }

  public get current():QueryFilterInstanceResource[]{
    if (this.currentState) {
      return this.currentState.current;
    } else {
      return [];
    }
  }

  public replace(newState:WorkPackageTableFilters) {
    this.state.put(newState);
  }

  public remove(removedFilter:QueryFilterInstanceResource) {
    this.currentState.remove(removedFilter);

    this.state.put(this.currentState);
  }

  public observeOnScope(scope:ng.IScope) {
    return this.state.observeOnScope(scope);
  }

  public onReady(scope:ng.IScope) {
    return this.state.observeOnScope(scope).take(1).mapTo(null).toPromise();
  }

  private loadCurrentFiltersSchemas(filters:QueryFilterInstanceResource[]):ng.IPromise<{}> {
    return this.$q.all(_.map(filters,
                       (filter:QueryFilterInstanceResource) => this.loadFilterSchema(filter)));
  }

  private loadFilterSchema(filter:QueryFilterInstanceResource):ng.IPromise<{}> {
    let deferred = this.$q.defer();

    let promises = [filter.schema.$load()]

    promises[0].then(() => {
      if (filter.values.length && filter.currentSchema && filter.currentSchema.values && filter.currentSchema.values.allowedValues) {
        if ((filter.currentSchema.values.allowedValues as CollectionResource)['$load']) {
          (filter.currentSchema.values.allowedValues as CollectionResource).$load().then((options:CollectionResource) => {
            _.each(filter.values, (value:any, index:number) => {
              let loadedHalResource = _.find(options.elements,
                                             option => option.$href === value.$href);

              if (loadedHalResource) {
                filter.values[index] = loadedHalResource;
              } else {
                throw "HalResource not in list of allowed values.";
              }
            })
            deferred.resolve();
          });

        } else {
          deferred.resolve();
        }
      } else {
        deferred.resolve();
      }
    });

    return deferred.promise;
  }
}

opServicesModule.service('wpTableFilters', WorkPackageTableFiltersService);
