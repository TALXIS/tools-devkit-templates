function makeAttr(initialValue) {
    let _v = initialValue;
    const attr = {
      getValue: jest.fn(() => _v),
      setValue: jest.fn(v => { _v = v; }),
      addOnChange: jest.fn(),
      fireOnChange: jest.fn()
    };
    return attr;
  }
  
  function makeLookup(value) {
    const arr = value ? [{
      id: value.id,
      name: value.name || '',
      entityType: value.entityType
    }] : null;
    return makeAttr(arr);
  }
  
  function makeControl(overrides = {}) {
    return {
      setVisible: jest.fn(),
      getVisible: jest.fn(() => true),
      setDisabled: jest.fn(),
      getDisabled: jest.fn(() => false),
      setFocus: jest.fn(),
      refresh: jest.fn(),
      ...overrides
    };
  }
  
  function makeUI(overrides = {}) {
    return {
      close: jest.fn(),
      setFormNotification: jest.fn(),
      clearFormNotification: jest.fn(),
      ...overrides
    };
  }
  
  function makeForm(attrs = {}, controls = {}, uiOverrides = {}) {
    const attrMap = { ...attrs };
    const ctrlMap = { ...controls };
    const form = {
      getAttribute: jest.fn((name) => attrMap[name]),
      getControl: jest.fn((name) => ctrlMap[name]),
      ui: makeUI(uiOverrides)
    };
    return form;
  }
  
  function makeExecutionContext(formContext) {
    return {
      getFormContext: () => formContext
    };
  }
  
  function makeGridControl(overrides = {}) {
    return {
      refresh: jest.fn(),
      getGrid: jest.fn(() => ({
        getSelectedRows: jest.fn(() => ({ get: () => [] }))
      })),
      ...overrides
    };
  }
  
  module.exports = {
    makeAttr,
    makeLookup,
    makeControl,
    makeUI,
    makeForm,
    makeExecutionContext,
    makeGridControl
  };
  