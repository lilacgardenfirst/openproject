import {TimelineCellBuilder} from "../timeline-cell-builder";
import {States} from "../../../states.service";
import {WorkPackageTableSelection} from "../../state/wp-table-selection.service";
import {CellBuilder} from "../cell-builder";
import {DetailsLinkBuilder} from "../details-link-builder";
import {injectorBridge} from "../../../angular/angular-injector-bridge.functions";
import {WorkPackageResource} from "../../../api/api-v3/hal-resources/work-package-resource.service";
import {QueryColumn} from '../../../api/api-v3/hal-resources/query-resource.service';
import {checkedClassName} from "../ui-state-link-builder";
import {rowId} from "../../helpers/wp-table-row-helpers";
import {Observable} from "rxjs";
import {WorkPackageTable} from "../../wp-fast-table";

export const rowClassName = 'wp-table--row';

export const internalColumnDetails = '__internal-detailsLink';
export const internalColumnTimelines = '__internal-timelines';

export const internalDetailsColumn = {
  id: '__internal-detailsLink'
} as QueryColumn;

export const internalTimelinesColumn = {
  id: '__internal-timelines';
} as QueryColumn;

export class SingleRowBuilder {
  // Injections
  public states:States;
  public wpTableSelection:WorkPackageTableSelection;
  public I18n:op.I18n;

  // Cell builder instance
  protected cellBuilder = new CellBuilder();
  // Details Link builder
  protected detailsLinkBuilder = new DetailsLinkBuilder();
  // Timeline builder
  protected timelineCellBuilder = new TimelineCellBuilder(this.stopExisting$, this.workPackageTable);

  constructor(private stopExisting$: Observable<any>, private workPackageTable: WorkPackageTable) {
    injectorBridge(this);
  }

  /**
   * Returns a shortcut to the current column state.
   * It is not responsible for subscribing to updates.
   */
  public get columns():QueryColumn[] {
    return (this.states.table.columns.getCurrentValue() || []);
  }

  /**
   * Returns the current set of columns, augmented by the internal columns
   * we add for buttons and timeline.
   */
  public get augmentedColumns():string[] {
   const editColums = (this.states.table.columns.getCurrentValue() || []);

   return editColums.concat(internalDetailsColumn, internalTimelinesColumn);
  }

  public buildCell(workPackage:WorkPackageResource, column:QueryColumn):HTMLElement {
    switch (column.id) {
      case internalTimelinesColumn.id:
        return this.timelineCellBuilder.build(workPackage);
      case internalDetailsColumn.id:
        return this.detailsLinkBuilder.build(workPackage);
    }
  }

  /**
   * Build the columns on the given empty row
   */
  public buildEmpty(workPackage:WorkPackageResource):HTMLElement {
    let row = this.createEmptyRow(workPackage);
    let cell = null;

    this.augmentedColumns.forEach((column:QueryColumn) => {
      cell = this.buildCell(workPackage, column);
      row.appendChild(cell);
    });

    // Set the row selection state
    if (this.wpTableSelection.isSelected(<string>workPackage.id)) {
      row.classList.add(checkedClassName);
    }

    return row;
  }

  /**
   * Create an empty unattached row element for the given work package
   * @param workPackage
   * @returns {any}
   */
  public createEmptyRow(workPackage:WorkPackageResource) {
    let tr = document.createElement('tr');
    tr.id = rowId(workPackage.id);
    tr.dataset['workPackageId'] = workPackage.id;
    tr.classList.add(rowClassName, 'wp--row', 'issue');

    return tr;
  }
}


SingleRowBuilder.$inject = ['states', 'wpTableSelection', 'I18n'];
