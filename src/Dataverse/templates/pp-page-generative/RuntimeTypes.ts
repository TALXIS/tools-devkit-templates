// Stub RuntimeTypes — regenerate with: pac model genpage generate-types --data-sources "table1,table2"
// These types provide IDE IntelliSense for the generative page component.

export type TableRow<T> = T & { readonly [key: string]: any };
export type ReadableTableRow<T> = T;

export interface DataTable<T = any> {
  rows: T[];
  hasMoreRows: boolean;
  loadMoreRows?: () => Promise<DataTable<T>>;
}

export interface QueryTableOptions {
  select?: string[];
  filter?: string;
  orderBy?: string;
  pageSize?: number;
}

export interface RetrieveRowOptions {
  id: string;
  select?: string[];
}

export interface UxAgentDataApi {
  createRow(tableName: string, row: object): Promise<string>;
  updateRow(tableName: string, rowId: string, row: object): Promise<void>;
  deleteRow(tableName: string, rowId: string): Promise<void>;
  retrieveRow(tableName: string, options: RetrieveRowOptions): Promise<any>;
  queryTable<T = any>(tableName: string, query: QueryTableOptions): Promise<DataTable<T>>;
  getChoices(enumName: string): Promise<{ label: string; value: number }[]>;
}

export interface PageInput {
  entityName?: string;
  recordId?: string;
  data?: Record<string, unknown>;
}

export interface GeneratedComponentProps {
  dataApi: UxAgentDataApi;
  pageInput: PageInput;
}
