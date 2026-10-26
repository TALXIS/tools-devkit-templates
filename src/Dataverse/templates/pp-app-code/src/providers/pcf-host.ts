// What this code app tells TALXIS base controls about its data and navigation: the parts of a PCF
// context a model-driven app would answer, but a code app has to supply itself.

export type HostEntity = {
  logicalName: string
  displayName: string
  primaryIdAttribute: string
  primaryNameAttribute: string
  /** Route of the app's page for one record; lets controls open it (grid links, lookup tags). */
  formPath?: (id: string) => string
}

const entities = new Map<string, HostEntity>()
let navigate: ((path: string) => void) | undefined

/** Registers the tables controls work with (lookups read their metadata, grids open their records). */
export function registerEntities(...list: HostEntity[]) {
  for (const entity of list) entities.set(entity.logicalName, entity)
}

export function getEntity(logicalName: string) {
  return entities.get(logicalName)
}

/** Called by the router, so opening a record navigates in-app instead of reloading the page. */
export function setHostNavigate(fn: (path: string) => void) {
  navigate = fn
}

// context.utils.getEntityMetadata: answered from the registered entities
export async function getEntityMetadata(entityName: string) {
  const entity = entities.get(entityName)
  if (!entity) {
    throw new Error(`Entity '${entityName}' isn't registered - add it with registerEntities()`)
  }
  return {
    LogicalName: entity.logicalName,
    DisplayName: entity.displayName,
    PrimaryIdAttribute: entity.primaryIdAttribute,
    PrimaryNameAttribute: entity.primaryNameAttribute,
  }
}

// context.navigation.openForm: routes to the entity's page in this app
export async function openForm(options: { entityName: string; entityId?: string }) {
  const path = options.entityId ? entities.get(options.entityName)?.formPath?.(options.entityId) : undefined
  if (!path || !navigate) {
    throw new Error(`No page to open '${options.entityName}' records on - give it a formPath in registerEntities()`)
  }
  navigate(path)
  return { savedEntityReference: [] }
}
